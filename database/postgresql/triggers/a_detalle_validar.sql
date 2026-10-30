CREATE TRIGGER a_detalle_validar BEFORE INSERT OR UPDATE OR DELETE ON detalle_pedido FOR EACH ROW EXECUTE FUNCTION fn_detalle_validar();
