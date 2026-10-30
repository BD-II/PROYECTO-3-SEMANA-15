CREATE TRIGGER proveedor_id_estable BEFORE UPDATE ON proveedor FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_proveedor');
