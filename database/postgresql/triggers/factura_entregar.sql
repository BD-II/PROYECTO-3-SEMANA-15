CREATE TRIGGER factura_entregar AFTER INSERT ON factura FOR EACH ROW EXECUTE FUNCTION fn_factura_entregar();
