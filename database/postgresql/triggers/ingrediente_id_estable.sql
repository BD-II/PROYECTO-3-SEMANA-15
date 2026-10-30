CREATE TRIGGER ingrediente_id_estable BEFORE UPDATE ON ingrediente FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_ingrediente');
