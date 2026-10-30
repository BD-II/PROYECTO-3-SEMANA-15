CREATE OR REPLACE FUNCTION fn_registrar_historial_reserva() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
 IF NEW.estado_reserva IS DISTINCT FROM OLD.estado_reserva THEN
 INSERT INTO public.historial_reserva(id_reserva,estado_anterior,estado_nuevo,fecha_cambio)
 VALUES(NEW.id_reserva,OLD.estado_reserva,NEW.estado_reserva,current_timestamp);
 END IF; RETURN NEW;
END $$;
