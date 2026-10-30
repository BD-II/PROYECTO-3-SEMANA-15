CREATE TRIGGER trg_historial_reserva AFTER UPDATE OF estado_reserva ON reserva FOR EACH ROW EXECUTE FUNCTION fn_registrar_historial_reserva();
