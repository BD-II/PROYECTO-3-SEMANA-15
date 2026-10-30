-- 09_recuperar_todos_los_datos_originales.sql
-- Ejecutar COMPLETO en Query Tool, como postgres, en la base V2 ya instalada.
-- Compatible con 04_demo y 08 cargados: conserva esos registros sin duplicarlos.
-- No ejecutar 01 ni 02 otra vez. Recomendacion: guardar backup previo.
-- IMPORTANTE: pedidos PC1 se conservan como historicos protegidos (legado=true).
-- No descuenta stock otra vez ni inventa los consumos antiguos.
-- Las cuatro facturas inconsistentes se conservan y se muestran al final.
-- Si un identificador existente tiene contenido diferente, se aborta toda la carga.
-- No sobrescribe stock existente. Los nuevos ingredientes reciben su saldo PC1.
-- No restaura contrasenas ni rutinas antiguas: conserva las mejoras de V2.
BEGIN;
SET LOCAL search_path=public,pg_catalog;
SET LOCAL standard_conforming_strings=on;
LOCK TABLE public.cliente,public.empleado,public.proveedor,public.ingrediente,
 public.plato,public.receta,public.pedido,public.detalle_pedido,public.factura,
 public.mesa,public.reserva,public.historial_reserva,public.detalle_insumo,
 public.movimiento_inventario IN ACCESS EXCLUSIVE MODE;
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.schema_version WHERE version=2) THEN
 RAISE EXCEPTION 'Se requiere la base mejorada V2'; END IF;
END $$;

-- Importacion historica controlada: suspender SOLO triggers de negocio,
-- conservando PK, FK, CHECK, UNIQUE y exclusion de reservas activas.
-- La transaccion revierte tambien este cambio si falla la carga.
CREATE TEMP TABLE _original_triggers ON COMMIT DROP AS
SELECT n.nspname,c.relname,t.tgname,t.tgenabled
FROM pg_catalog.pg_trigger t
JOIN pg_catalog.pg_class c ON c.oid=t.tgrelid
JOIN pg_catalog.pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relname IN ('pedido','detalle_pedido','factura','reserva','historial_reserva')
AND NOT t.tgisinternal;
DO $$ DECLARE r record; BEGIN
 FOR r IN SELECT * FROM _original_triggers LOOP
 EXECUTE format('ALTER TABLE %I.%I DISABLE TRIGGER %I',r.nspname,r.relname,r.tgname);
 END LOOP;
END $$;

\ir originales/01_cliente.sql
\ir originales/02_empleado.sql
\ir originales/03_proveedor.sql
\ir originales/04_ingrediente.sql
\ir originales/05_plato.sql
\ir originales/06_receta.sql
\ir originales/07_pedido.sql
\ir originales/08_detalle_pedido.sql
\ir originales/09_factura.sql
\ir originales/10_reserva.sql
\ir originales/11_historial_reserva.sql
-- Restaurar exactamente el estado previo de los triggers de negocio.
DO $$ DECLARE r record; accion text; BEGIN
 FOR r IN SELECT * FROM _original_triggers LOOP
 accion=CASE r.tgenabled WHEN 'D' THEN 'DISABLE' WHEN 'R' THEN 'ENABLE REPLICA'
 WHEN 'A' THEN 'ENABLE ALWAYS' ELSE 'ENABLE' END;
 EXECUTE format('ALTER TABLE %I.%I %s TRIGGER %I',r.nspname,r.relname,accion,r.tgname);
 END LOOP;
END $$;

-- Continuar la numeracion del historial sin colisiones con H001 y H002.
SELECT setval('public.seq_historial_reserva',greatest(
 (SELECT last_value FROM public.seq_historial_reserva),
 coalesce((SELECT max(substring(id_historial from '^H([0-9]+)$')::bigint) FROM public.historial_reserva),0),1),true);

-- Cantidades de registros ORIGINALES recuperados (no incluyen los demo).
SELECT 'cliente' tabla,count(*) recuperados,30 esperados FROM public.cliente t JOIN _original_cliente s USING(id_cliente)
UNION ALL SELECT 'empleado',count(*),3 FROM public.empleado t JOIN _original_empleado s USING(id_empleado)
UNION ALL SELECT 'proveedor',count(*),12 FROM public.proveedor t JOIN _original_proveedor s USING(id_proveedor)
UNION ALL SELECT 'ingrediente',count(*),62 FROM public.ingrediente t JOIN _original_ingrediente s USING(id_ingrediente)
UNION ALL SELECT 'plato',count(*),40 FROM public.plato t JOIN _original_plato s USING(id_plato)
UNION ALL SELECT 'receta',count(*),143 FROM public.receta t JOIN _original_receta s USING(id_plato,id_ingrediente)
UNION ALL SELECT 'pedido',count(*),50 FROM public.pedido t JOIN _original_pedido s USING(id_pedido)
UNION ALL SELECT 'detalle_pedido',count(*),150 FROM public.detalle_pedido t JOIN _original_detalle_pedido s USING(id_detalle)
UNION ALL SELECT 'factura',count(*),41 FROM public.factura t JOIN _original_factura s USING(id_factura)
UNION ALL SELECT 'reserva',count(*),101 FROM public.reserva t JOIN _original_reserva s USING(id_reserva)
UNION ALL SELECT 'historial_reserva',count(*),2 FROM public.historial_reserva t JOIN _original_historial_reserva s USING(id_historial);

COMMIT;

-- DIAGNOSTICO: 4 diferencias originales conocidas, conservadas sin inventar causas.
-- No significan fallo de instalacion ni deben corregirse sin revision del equipo.
SELECT f.id_factura,f.id_pedido,f.total_pagado,
 public.fn_calcular_total_pedido(f.id_pedido) total_detalles
FROM public.factura f JOIN public.pedido p USING(id_pedido)
WHERE p.legado AND f.total_pagado<>public.fn_calcular_total_pedido(f.id_pedido)
ORDER BY f.id_factura;

-- Pedidos originales pendientes/en preparacion: quedan consultables y protegidos.
-- Para continuar su atencion hay que conciliar inventario y consumo original.
SELECT id_pedido,estado,legado FROM public.pedido WHERE legado AND estado IN (0,1) ORDER BY id_pedido;

-- Carta original; precios, recetas y stock siguen siendo responsabilidad de PostgreSQL.
SELECT id_plato,nombre_plato,categoria,precio FROM public.plato ORDER BY id_plato;
-- Finalmente, generar un NUEVO backup para incluir los datos recuperados.
