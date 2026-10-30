CREATE TRIGGER detalle_inventario AFTER INSERT OR UPDATE ON detalle_pedido FOR EACH ROW EXECUTE FUNCTION fn_detalle_inventario();
