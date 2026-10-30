\set ON_ERROR_STOP on
BEGIN;
\ir tables/cliente.sql
\ir tables/detalle_pedido.sql
\ir tables/empleado.sql
\ir tables/factura.sql
\ir tables/historial_reserva.sql
\ir tables/ingrediente.sql
\ir tables/pedido.sql
\ir tables/plato.sql
\ir tables/proveedor.sql
\ir tables/receta.sql
\ir tables/reserva.sql
\ir tables/seq_historial_reserva.sql
\ir constraints/001_originales.sql
\ir migrations/001_mejoras.sql
COMMIT;
