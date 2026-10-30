CREATE OR REPLACE PROCEDURE sp_actualizar_estado_reserva(IN p_id_reserva varchar,IN p_nuevo_estado varchar)
LANGUAGE plpgsql AS $$ BEGIN
 UPDATE public.reserva SET estado_reserva=p_nuevo_estado WHERE id_reserva=p_id_reserva;
 IF NOT FOUND THEN RAISE EXCEPTION 'Reserva inexistente'; END IF;
END $$;
