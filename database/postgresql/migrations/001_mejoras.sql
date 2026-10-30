-- Compartido por install.sql y upgrade.sql. Aplicar una sola vez.
SET LOCAL search_path = public, pg_catalog;
LOCK TABLE pedido,detalle_pedido,ingrediente,receta,reserva,factura IN ACCESS EXCLUSIVE MODE;
\ir ../tables/v2_schema_version.sql
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
\ir ../tables/v2_mesa.sql
INSERT INTO mesa SELECT numero_mesa,max(cantidad_personas) FROM reserva GROUP BY numero_mesa;
ALTER TABLE reserva ADD COLUMN duracion_minutos integer NOT NULL DEFAULT 120 CHECK(duracion_minutos BETWEEN 15 AND 720);
ALTER TABLE reserva ADD CONSTRAINT reserva_mesa_fk FOREIGN KEY(numero_mesa) REFERENCES mesa;
ALTER TABLE reserva ADD CONSTRAINT reserva_sin_cruces EXCLUDE USING gist
 (int4range(numero_mesa,numero_mesa,'[]') WITH &&,
 tsrange(fecha_reserva,fecha_reserva+make_interval(mins=>duracion_minutos),'[)') WITH &&)
 WHERE (estado_reserva IN ('Pendiente','Confirmada'));
-- Capacidad inferida y duracion asumida requieren confirmacion; diagnostico en docs.
\ir ../tables/v2_detalle_insumo.sql
\ir ../tables/v2_movimiento_inventario.sql
INSERT INTO movimiento_inventario(id_ingrediente,variacion,saldo_resultante,motivo)
 SELECT id_ingrediente,stock_actual,stock_actual,'Saldo inicial al actualizar; consumo anterior no reconstruido' FROM ingrediente;
ALTER TABLE historial_reserva ALTER COLUMN id_historial SET DEFAULT
 ('H'||nextval('public.seq_historial_reserva')::text);
SELECT setval('public.seq_historial_reserva',greatest(
 (SELECT last_value FROM seq_historial_reserva),
 COALESCE((SELECT max(substring(id_historial from '^H([0-9]+)$')::bigint) FROM historial_reserva),0),1),true);
\ir ../tables/v2_integracion_contrato.sql
INSERT INTO integracion_contrato VALUES
 ('plato','id_plato','PostgreSQL es fuente de nombre y precio. MongoDB podra referenciar este ID.'),
 ('pedido','id_pedido','PostgreSQL es fuente de estado, detalles e importes.'),
 ('cliente','id_cliente','PostgreSQL es fuente de identidad operativa.');
\ir ../indexes/001_indices.sql
\ir ../functions/001_negocio.sql
\ir ../procedures/001_operaciones.sql
\ir ../triggers/001_eventos.sql
INSERT INTO schema_version VALUES(2,now());
