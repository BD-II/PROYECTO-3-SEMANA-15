\set ON_ERROR_STOP on
-- Ejecutar como administrador, despues de install/upgrade. Sin contrasenas publicadas.
BEGIN;
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='usuario_restaurante') THEN CREATE ROLE usuario_restaurante NOLOGIN; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_roles WHERE rolname='usuario_invitados') THEN CREATE ROLE usuario_invitados NOLOGIN; END IF;
END $$;
ALTER ROLE usuario_restaurante NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
ALTER ROLE usuario_invitados NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM usuario_restaurante,usuario_invitados;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM usuario_restaurante,usuario_invitados;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC,usuario_invitados;
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA public FROM PUBLIC,usuario_invitados;
GRANT USAGE ON SCHEMA public TO usuario_restaurante,usuario_invitados;
GRANT SELECT ON plato TO usuario_invitados;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO usuario_restaurante;
GRANT INSERT ON cliente,empleado,plato,proveedor,ingrediente,receta,mesa,pedido,detalle_pedido,reserva TO usuario_restaurante;
GRANT UPDATE ON cliente,empleado,plato,proveedor,receta,reserva TO usuario_restaurante;
GRANT UPDATE(estado) ON pedido TO usuario_restaurante;
GRANT UPDATE(id_plato,cantidad) ON detalle_pedido TO usuario_restaurante;
GRANT DELETE ON detalle_pedido TO usuario_restaurante;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM usuario_restaurante;
REVOKE EXECUTE ON ALL PROCEDURES IN SCHEMA public FROM usuario_restaurante;
GRANT EXECUTE ON FUNCTION fn_calcular_total_pedido(varchar), fn_resumen_pedido(varchar), fn_calcularperdidaporcancelacion(), fn_ingredientes_stock_bajo(numeric) TO usuario_restaurante;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO usuario_restaurante;
ALTER FUNCTION fn_detalle_inventario() SECURITY DEFINER;
ALTER FUNCTION fn_detalle_inventario() SET search_path=pg_catalog,public,pg_temp;
ALTER FUNCTION fn_pedido_validar() SECURITY DEFINER;
ALTER FUNCTION fn_pedido_validar() SET search_path=pg_catalog,public,pg_temp;
ALTER FUNCTION fn_normalizar_estado_reserva() SECURITY DEFINER;
ALTER FUNCTION fn_normalizar_estado_reserva() SET search_path=pg_catalog,public,pg_temp;
ALTER FUNCTION fn_registrar_historial_reserva() SECURITY DEFINER;
ALTER FUNCTION fn_registrar_historial_reserva() SET search_path=pg_catalog,public,pg_temp;
-- Procedimientos encapsulan escrituras que no se conceden directamente al operador.
ALTER PROCEDURE sp_actualizar_stock(varchar,numeric) SECURITY DEFINER;
ALTER PROCEDURE sp_actualizar_stock(varchar,numeric) SET search_path=pg_catalog,public,pg_temp;
ALTER PROCEDURE sp_registrar_pago_pedido(varchar,varchar,integer,varchar,numeric) SECURITY DEFINER;
ALTER PROCEDURE sp_registrar_pago_pedido(varchar,varchar,integer,varchar,numeric) SET search_path=pg_catalog,public,pg_temp;
REVOKE CREATE ON SCHEMA public FROM PUBLIC,usuario_restaurante,usuario_invitados;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT ON TABLES FROM usuario_invitados;
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
COMMIT;
