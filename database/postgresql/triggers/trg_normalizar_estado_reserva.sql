CREATE TRIGGER trg_normalizar_estado_reserva BEFORE INSERT OR UPDATE ON reserva FOR EACH ROW EXECUTE FUNCTION fn_normalizar_estado_reserva();
