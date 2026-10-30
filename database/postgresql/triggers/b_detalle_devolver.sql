CREATE TRIGGER b_detalle_devolver BEFORE DELETE ON detalle_pedido FOR EACH ROW EXECUTE FUNCTION fn_detalle_inventario();
