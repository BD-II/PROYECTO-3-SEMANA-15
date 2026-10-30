-- Generado: editar fuentes modulares y recompilar.
-- Ejecutar SOLO en una copia restaurada de PC1, sin backend conectado.
BEGIN;
-- Compartido por install.sql y upgrade.sql. Aplicar una sola vez.
SET LOCAL search_path = public, pg_catalog;
LOCK TABLE pedido,detalle_pedido,ingrediente,receta,reserva,factura IN ACCESS EXCLUSIVE MODE;
CREATE TABLE schema_version(version integer PRIMARY KEY, aplicado_en timestamptz NOT NULL DEFAULT now());

DO $$ BEGIN
 IF EXISTS(SELECT 1 FROM detalle_pedido WHERE cantidad<=0 OR subtotal<0
   OR round(subtotal/cantidad,2)*cantidad<>subtotal) THEN
  RAISE EXCEPTION 'Detalles invalidos: revisar cantidad y precio reconstruible en centimos; no se modificaron datos';
 END IF;
 IF EXISTS(SELECT 1 FROM plato WHERE precio<0) OR EXISTS(SELECT 1 FROM factura WHERE total_pagado<0) THEN
  RAISE EXCEPTION 'Existen precios o pagos negativos; revisar antes de actualizar';
 END IF;
END $$;
DROP TRIGGER IF EXISTS trg_descontar_stock ON detalle_pedido;
DROP TRIGGER IF EXISTS trg_ajustar_stock_actualizado ON detalle_pedido;
DROP FUNCTION IF EXISTS fn_descontar_stock();
DROP FUNCTION IF EXISTS fn_ajustar_stock_actualizado();
DROP TRIGGER IF EXISTS trg_historial_reserva ON reserva;
DROP TRIGGER IF EXISTS trg_normalizar_estado_reserva ON reserva;
ALTER TABLE pedido ADD COLUMN legado boolean NOT NULL DEFAULT false;
UPDATE pedido SET legado=true;
ALTER TABLE detalle_pedido ADD COLUMN precio_unitario numeric(12,2);
UPDATE detalle_pedido SET precio_unitario=subtotal/cantidad;
ALTER TABLE detalle_pedido ALTER COLUMN precio_unitario SET NOT NULL;
ALTER TABLE detalle_pedido ADD CONSTRAINT detalle_cantidad_positiva CHECK(cantidad>0),
 ADD CONSTRAINT detalle_precio_valido CHECK(precio_unitario>=0),
 ADD CONSTRAINT detalle_subtotal_coherente CHECK(subtotal=round(cantidad*precio_unitario,2));
ALTER TABLE plato ADD CONSTRAINT plato_precio_valido CHECK(precio>=0);
ALTER TABLE factura ADD CONSTRAINT factura_importe_valido CHECK(total_pagado>=0);
-- Los registros previos se conservan como historicos, sin fingir conocer su consumo original.
CREATE TABLE mesa(numero_mesa integer PRIMARY KEY CHECK(numero_mesa>0), capacidad integer NOT NULL CHECK(capacidad>0));

INSERT INTO mesa SELECT numero_mesa,max(cantidad_personas) FROM reserva GROUP BY numero_mesa;
ALTER TABLE reserva ADD COLUMN duracion_minutos integer NOT NULL DEFAULT 120 CHECK(duracion_minutos BETWEEN 15 AND 720);
ALTER TABLE reserva ADD CONSTRAINT reserva_mesa_fk FOREIGN KEY(numero_mesa) REFERENCES mesa;
ALTER TABLE reserva ADD CONSTRAINT reserva_sin_cruces EXCLUDE USING gist
 (int4range(numero_mesa,numero_mesa,'[]') WITH &&,
 tsrange(fecha_reserva,fecha_reserva+make_interval(mins=>duracion_minutos),'[)') WITH &&)
 WHERE (estado_reserva IN ('Pendiente','Confirmada'));
-- Capacidad inferida y duracion asumida requieren confirmacion; diagnostico en docs.
CREATE TABLE detalle_insumo(
 id_detalle varchar(10) REFERENCES detalle_pedido ON DELETE CASCADE,
 id_ingrediente varchar(10) REFERENCES ingrediente,
 cantidad_por_unidad numeric(10,2) NOT NULL CHECK(cantidad_por_unidad>0),
 PRIMARY KEY(id_detalle,id_ingrediente));

CREATE TABLE movimiento_inventario(
 id_movimiento bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 id_ingrediente varchar(10) NOT NULL REFERENCES ingrediente,
 id_pedido varchar(10) REFERENCES pedido,
 variacion numeric(12,2) NOT NULL,
 saldo_resultante numeric(12,2) NOT NULL CHECK(saldo_resultante>=0),
 motivo text NOT NULL,
 registrado_en timestamptz NOT NULL DEFAULT now());

INSERT INTO movimiento_inventario(id_ingrediente,variacion,saldo_resultante,motivo)
 SELECT id_ingrediente,stock_actual,stock_actual,'Saldo inicial al actualizar; consumo anterior no reconstruido' FROM ingrediente;
ALTER TABLE historial_reserva ALTER COLUMN id_historial SET DEFAULT
 ('H'||nextval('public.seq_historial_reserva')::text);
SELECT setval('public.seq_historial_reserva',greatest(
 (SELECT last_value FROM seq_historial_reserva),
 COALESCE((SELECT max(substring(id_historial from '^H([0-9]+)$')::bigint) FROM historial_reserva),0),1),true);
CREATE TABLE integracion_contrato(
 entidad text PRIMARY KEY, columna_id text NOT NULL, descripcion text NOT NULL);

INSERT INTO integracion_contrato VALUES
 ('plato','id_plato','PostgreSQL es fuente de nombre y precio. MongoDB podra referenciar este ID.'),
 ('pedido','id_pedido','PostgreSQL es fuente de estado, detalles e importes.'),
 ('cliente','id_cliente','PostgreSQL es fuente de identidad operativa.');
CREATE INDEX pedido_cliente_fecha_idx ON pedido(id_cliente,fecha);
CREATE INDEX pedido_empleado_idx ON pedido(id_empleado);
CREATE INDEX detalle_pedido_pedido_idx ON detalle_pedido(id_pedido);
CREATE INDEX detalle_pedido_plato_idx ON detalle_pedido(id_plato);
CREATE INDEX ingrediente_proveedor_idx ON ingrediente(id_proveedor);
CREATE INDEX receta_ingrediente_idx ON receta(id_ingrediente);
CREATE INDEX reserva_cliente_idx ON reserva(id_cliente);
CREATE INDEX reserva_mesa_fecha_idx ON reserva(numero_mesa,fecha_reserva);
CREATE INDEX historial_reserva_reserva_idx ON historial_reserva(id_reserva,fecha_cambio);
CREATE INDEX movimiento_ingrediente_idx ON movimiento_inventario(id_ingrediente,registrado_en);

CREATE OR REPLACE FUNCTION fn_calcular_total_pedido(pe_id_pedido varchar) RETURNS numeric
LANGUAGE sql STABLE AS $$ SELECT coalesce(sum(subtotal),0) FROM public.detalle_pedido WHERE id_pedido=pe_id_pedido $$;

CREATE OR REPLACE FUNCTION fn_resumen_pedido(pe_id_pedido varchar)
RETURNS TABLE(id_pedido varchar,id_cliente varchar,fecha timestamp,tipo_pedido varchar,estado integer,cantidad_platos bigint,total_pedido numeric)
LANGUAGE sql STABLE AS $$
 SELECT p.id_pedido,p.id_cliente,p.fecha,p.tipo_pedido,p.estado,coalesce(sum(d.cantidad),0)::bigint,coalesce(sum(d.subtotal),0)
 FROM public.pedido p LEFT JOIN public.detalle_pedido d USING(id_pedido)
 WHERE p.id_pedido=pe_id_pedido GROUP BY p.id_pedido $$;

CREATE OR REPLACE FUNCTION fn_calcularperdidaporcancelacion() RETURNS numeric
LANGUAGE sql STABLE AS $$ SELECT coalesce(sum(d.subtotal),0) FROM public.pedido p JOIN public.detalle_pedido d USING(id_pedido) WHERE p.estado=3 $$;
COMMENT ON FUNCTION fn_calcularperdidaporcancelacion() IS 'Compatibilidad PC1: valor de ventas canceladas, NO costo real de merma.';

CREATE OR REPLACE FUNCTION fn_ingredientes_stock_bajo(p_stock_minimo numeric)
RETURNS TABLE(id_ingrediente varchar,nombre_ingrediente varchar,stock_actual numeric,unidad_medida varchar,id_proveedor varchar)
LANGUAGE sql STABLE AS $$ SELECT id_ingrediente,nombre_ingrediente,stock_actual,unidad_medida,id_proveedor FROM public.ingrediente WHERE stock_actual<=p_stock_minimo ORDER BY stock_actual $$;


CREATE FUNCTION fn_mover_stock(p_ingrediente varchar,p_delta numeric,p_motivo text,p_pedido varchar DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE saldo numeric;
BEGIN
 IF p_delta IS NULL OR p_motivo IS NULL OR btrim(p_motivo)='' THEN RAISE EXCEPTION 'Movimiento incompleto'; END IF;
 UPDATE public.ingrediente SET stock_actual=stock_actual+p_delta
 WHERE id_ingrediente=p_ingrediente AND stock_actual+p_delta>=0 RETURNING stock_actual INTO saldo;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ingrediente inexistente o stock insuficiente: %',p_ingrediente; END IF;
 INSERT INTO public.movimiento_inventario(id_ingrediente,id_pedido,variacion,saldo_resultante,motivo)
 VALUES(p_ingrediente,p_pedido,p_delta,saldo,p_motivo);
END $$;


CREATE FUNCTION fn_detalle_validar() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE p public.pedido%ROWTYPE;
BEGIN
 IF TG_OP='UPDATE' AND (NEW.id_detalle<>OLD.id_detalle OR NEW.id_pedido<>OLD.id_pedido) THEN
 RAISE EXCEPTION 'Identificadores del detalle y pedido son inmutables'; END IF;
 SELECT * INTO p FROM public.pedido WHERE id_pedido=CASE WHEN TG_OP='DELETE' THEN OLD.id_pedido ELSE NEW.id_pedido END FOR UPDATE;
 IF NOT FOUND OR p.legado OR p.estado<>0 THEN RAISE EXCEPTION 'Solo se editan detalles de pedidos nuevos pendientes'; END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 IF TG_OP='INSERT' OR NEW.id_plato IS DISTINCT FROM OLD.id_plato THEN
 SELECT precio INTO NEW.precio_unitario FROM public.plato WHERE id_plato=NEW.id_plato;
 IF NOT FOUND THEN RAISE EXCEPTION 'Plato inexistente'; END IF;
 ELSIF NEW.precio_unitario IS DISTINCT FROM OLD.precio_unitario THEN
 RAISE EXCEPTION 'El precio historico no se edita';
 END IF;
 NEW.subtotal=round(NEW.cantidad*NEW.precio_unitario,2);
 RETURN NEW;
END $$;


CREATE FUNCTION fn_detalle_inventario() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r record;
BEGIN
 -- DELETE se atiende BEFORE para leer la instantanea antes del borrado en cascada.
 IF TG_OP IN ('DELETE','UPDATE') THEN
  FOR r IN SELECT * FROM public.detalle_insumo WHERE id_detalle=OLD.id_detalle ORDER BY id_ingrediente LOOP
   PERFORM public.fn_mover_stock(r.id_ingrediente,r.cantidad_por_unidad*OLD.cantidad,'Devolucion por cambio de detalle',OLD.id_pedido);
  END LOOP;
 END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 IF TG_OP='INSERT' OR NEW.id_plato IS DISTINCT FROM OLD.id_plato THEN
  DELETE FROM public.detalle_insumo WHERE id_detalle=NEW.id_detalle;
  INSERT INTO public.detalle_insumo SELECT NEW.id_detalle,id_ingrediente,cantidad_requerida FROM public.receta WHERE id_plato=NEW.id_plato;
  IF NOT FOUND THEN RAISE EXCEPTION 'El plato % no tiene receta; no se puede controlar su consumo',NEW.id_plato; END IF;
 END IF;
 FOR r IN SELECT * FROM public.detalle_insumo WHERE id_detalle=NEW.id_detalle ORDER BY id_ingrediente LOOP
  PERFORM public.fn_mover_stock(r.id_ingrediente,-r.cantidad_por_unidad*NEW.cantidad,'Reserva de ingredientes por pedido',NEW.id_pedido);
 END LOOP;
 RETURN NEW;
END $$;


CREATE FUNCTION fn_pedido_validar() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE r record;
BEGIN
 IF TG_OP='INSERT' THEN
  IF NEW.estado<>0 OR NEW.legado THEN RAISE EXCEPTION 'Pedido nuevo debe iniciar pendiente y sin marca legado'; END IF;
  RETURN NEW;
 END IF;
 IF OLD.legado THEN RAISE EXCEPTION 'Pedido PC1 protegido: requiere conciliacion manual antes de continuar'; END IF;
 IF NEW.id_pedido<>OLD.id_pedido OR NEW.legado<>OLD.legado THEN RAISE EXCEPTION 'Identificador y marca legado inmutables'; END IF;
 IF OLD.estado IN (2,3) AND NEW IS DISTINCT FROM OLD THEN RAISE EXCEPTION 'Pedido cerrado no editable'; END IF;
 IF NEW.estado IS DISTINCT FROM OLD.estado THEN
  IF NOT ((OLD.estado=0 AND NEW.estado IN (1,3)) OR (OLD.estado=1 AND NEW.estado IN (2,3))) THEN RAISE EXCEPTION 'Transicion de estado no permitida'; END IF;
  IF NEW.estado IN (1,2) AND NOT EXISTS(SELECT 1 FROM public.detalle_pedido WHERE id_pedido=OLD.id_pedido) THEN RAISE EXCEPTION 'Pedido sin detalles'; END IF;
  IF NEW.estado=2 AND NOT EXISTS(SELECT 1 FROM public.factura WHERE id_pedido=OLD.id_pedido) THEN RAISE EXCEPTION 'Registrar pago antes de entregar'; END IF;
  IF OLD.estado=0 AND NEW.estado=3 THEN
   FOR r IN SELECT i.id_ingrediente,sum(i.cantidad_por_unidad*d.cantidad) cantidad
    FROM public.detalle_pedido d JOIN public.detalle_insumo i USING(id_detalle)
    WHERE d.id_pedido=OLD.id_pedido GROUP BY i.id_ingrediente ORDER BY i.id_ingrediente LOOP
    PERFORM public.fn_mover_stock(r.id_ingrediente,r.cantidad,'Cancelacion antes de preparacion',OLD.id_pedido);
   END LOOP;
  END IF;
  -- Cancelar en preparacion NO devuelve ingredientes ya consumidos.
 END IF;
 RETURN NEW;
END $$;


CREATE FUNCTION fn_factura_validar() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE p public.pedido%ROWTYPE;
BEGIN
 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'Comprobante inmutable; anulacion requiere proceso separado'; END IF;
 SELECT * INTO p FROM public.pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 IF NOT FOUND OR p.legado OR p.estado<>1 THEN RAISE EXCEPTION 'Pago requiere pedido nuevo en preparacion'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.detalle_pedido WHERE id_pedido=NEW.id_pedido)
 OR NEW.total_pagado<>public.fn_calcular_total_pedido(NEW.id_pedido) THEN RAISE EXCEPTION 'Importe no coincide con el pedido'; END IF;
 IF btrim(NEW.metodo_pago)='' THEN RAISE EXCEPTION 'Metodo de pago obligatorio'; END IF;
 RETURN NEW;
END $$;

CREATE FUNCTION fn_factura_entregar() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
 UPDATE public.pedido SET estado=2 WHERE id_pedido=NEW.id_pedido; RETURN NEW;
END $$;


CREATE OR REPLACE FUNCTION fn_normalizar_estado_reserva() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE capacidad_mesa integer;
BEGIN
 NEW.estado_reserva=initcap(lower(btrim(NEW.estado_reserva)));
 IF TG_OP='UPDATE' AND NEW.id_reserva<>OLD.id_reserva THEN RAISE EXCEPTION 'ID reserva inmutable'; END IF;
 -- Se serializan reservas de la misma mesa. El backend usara READ COMMITTED.
 IF TG_OP='UPDATE' THEN
  PERFORM 1 FROM public.mesa WHERE numero_mesa IN (OLD.numero_mesa,NEW.numero_mesa) ORDER BY numero_mesa FOR UPDATE;
 END IF;
 SELECT capacidad INTO capacidad_mesa FROM public.mesa WHERE numero_mesa=NEW.numero_mesa FOR UPDATE;
 IF NOT FOUND OR NEW.cantidad_personas>capacidad_mesa THEN RAISE EXCEPTION 'Mesa inexistente o capacidad insuficiente'; END IF;
 IF NEW.estado_reserva IN ('Pendiente','Confirmada') AND EXISTS(
 SELECT 1 FROM public.reserva r WHERE r.numero_mesa=NEW.numero_mesa AND r.id_reserva<>NEW.id_reserva
 AND r.estado_reserva IN ('Pendiente','Confirmada')
 AND tsrange(r.fecha_reserva,r.fecha_reserva+make_interval(mins=>r.duracion_minutos),'[)') &&
 tsrange(NEW.fecha_reserva,NEW.fecha_reserva+make_interval(mins=>NEW.duracion_minutos),'[)')) THEN
 RAISE EXCEPTION 'La mesa tiene otra reserva en ese intervalo'; END IF;
 RETURN NEW;
END $$;

CREATE OR REPLACE FUNCTION fn_registrar_historial_reserva() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
 IF NEW.estado_reserva IS DISTINCT FROM OLD.estado_reserva THEN
 INSERT INTO public.historial_reserva(id_reserva,estado_anterior,estado_nuevo,fecha_cambio)
 VALUES(NEW.id_reserva,OLD.estado_reserva,NEW.estado_reserva,current_timestamp);
 END IF; RETURN NEW;
END $$;

CREATE FUNCTION fn_id_inmutable() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
 IF to_jsonb(NEW)->TG_ARGV[0] IS DISTINCT FROM to_jsonb(OLD)->TG_ARGV[0] THEN
 RAISE EXCEPTION 'Identificador estable: % no se modifica',TG_ARGV[0]; END IF; RETURN NEW;
END $$;


CREATE OR REPLACE PROCEDURE sp_eliminar_detalle_pedido(IN p_id_detalle varchar)
LANGUAGE plpgsql AS $$ BEGIN
 DELETE FROM public.detalle_pedido WHERE id_detalle=p_id_detalle;
 IF NOT FOUND THEN RAISE EXCEPTION 'Detalle inexistente: %',p_id_detalle; END IF;
END $$;

CREATE OR REPLACE PROCEDURE sp_actualizar_stock(IN p_id_ingrediente varchar,IN p_nuevo_stock numeric)
LANGUAGE plpgsql AS $$ DECLARE saldo numeric; BEGIN
 IF p_nuevo_stock IS NULL OR p_nuevo_stock<0 THEN RAISE EXCEPTION 'Stock invalido'; END IF;
 SELECT stock_actual INTO saldo FROM public.ingrediente WHERE id_ingrediente=p_id_ingrediente FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ingrediente inexistente'; END IF;
 PERFORM public.fn_mover_stock(p_id_ingrediente,p_nuevo_stock-saldo,'Ajuste manual conciliado');
END $$;

CREATE OR REPLACE PROCEDURE sp_actualizar_estado_reserva(IN p_id_reserva varchar,IN p_nuevo_estado varchar)
LANGUAGE plpgsql AS $$ BEGIN
 UPDATE public.reserva SET estado_reserva=p_nuevo_estado WHERE id_reserva=p_id_reserva;
 IF NOT FOUND THEN RAISE EXCEPTION 'Reserva inexistente'; END IF;
END $$;

CREATE OR REPLACE PROCEDURE sp_registrar_pago_pedido(IN p_id_factura varchar,IN p_id_pedido varchar,IN p_num_comprobante integer,IN p_metodo_pago varchar,IN p_total_pagado numeric)
LANGUAGE plpgsql AS $$ BEGIN
 INSERT INTO public.factura(id_factura,id_pedido,numero_comprobante,metodo_pago,total_pagado)
 VALUES(p_id_factura,p_id_pedido,p_num_comprobante,p_metodo_pago,p_total_pagado);
END $$;

CREATE PROCEDURE sp_cambiar_estado_pedido(IN p_id_pedido varchar,IN p_estado integer)
LANGUAGE plpgsql AS $$ BEGIN
 UPDATE public.pedido SET estado=p_estado WHERE id_pedido=p_id_pedido;
 IF NOT FOUND THEN RAISE EXCEPTION 'Pedido inexistente'; END IF;
END $$;


CREATE TRIGGER a_detalle_validar BEFORE INSERT OR UPDATE OR DELETE ON detalle_pedido FOR EACH ROW EXECUTE FUNCTION fn_detalle_validar();

CREATE TRIGGER b_detalle_devolver BEFORE DELETE ON detalle_pedido FOR EACH ROW EXECUTE FUNCTION fn_detalle_inventario();

CREATE TRIGGER detalle_inventario AFTER INSERT OR UPDATE ON detalle_pedido FOR EACH ROW EXECUTE FUNCTION fn_detalle_inventario();

CREATE TRIGGER pedido_validar BEFORE INSERT OR UPDATE ON pedido FOR EACH ROW EXECUTE FUNCTION fn_pedido_validar();

CREATE TRIGGER factura_validar BEFORE INSERT OR UPDATE OR DELETE ON factura FOR EACH ROW EXECUTE FUNCTION fn_factura_validar();

CREATE TRIGGER factura_entregar AFTER INSERT ON factura FOR EACH ROW EXECUTE FUNCTION fn_factura_entregar();

CREATE TRIGGER trg_normalizar_estado_reserva BEFORE INSERT OR UPDATE ON reserva FOR EACH ROW EXECUTE FUNCTION fn_normalizar_estado_reserva();

CREATE TRIGGER trg_historial_reserva AFTER UPDATE OF estado_reserva ON reserva FOR EACH ROW EXECUTE FUNCTION fn_registrar_historial_reserva();

CREATE TRIGGER cliente_id_estable BEFORE UPDATE ON cliente FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_cliente');

CREATE TRIGGER plato_id_estable BEFORE UPDATE ON plato FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_plato');

CREATE TRIGGER empleado_id_estable BEFORE UPDATE ON empleado FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_empleado');

CREATE TRIGGER ingrediente_id_estable BEFORE UPDATE ON ingrediente FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_ingrediente');

CREATE TRIGGER proveedor_id_estable BEFORE UPDATE ON proveedor FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_proveedor');


INSERT INTO schema_version VALUES(2,now());

COMMIT;
