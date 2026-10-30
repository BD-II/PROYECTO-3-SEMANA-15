CREATE TRIGGER empleado_id_estable BEFORE UPDATE ON empleado FOR EACH ROW EXECUTE FUNCTION fn_id_inmutable('id_empleado');
