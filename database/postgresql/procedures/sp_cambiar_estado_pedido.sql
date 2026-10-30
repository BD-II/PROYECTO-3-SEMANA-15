CREATE PROCEDURE sp_cambiar_estado_pedido(IN p_id_pedido varchar,IN p_estado integer)
LANGUAGE plpgsql AS $$ BEGIN
 UPDATE public.pedido SET estado=p_estado WHERE id_pedido=p_id_pedido;
 IF NOT FOUND THEN RAISE EXCEPTION 'Pedido inexistente'; END IF;
END $$;
