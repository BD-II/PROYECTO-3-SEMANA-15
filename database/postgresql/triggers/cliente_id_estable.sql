CREATE TRIGGER cliente_id_estable BEFORE UPDATE ON cliente FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_cliente');
