CREATE TRIGGER plato_id_estable BEFORE UPDATE ON plato FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_plato');
