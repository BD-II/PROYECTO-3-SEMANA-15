CREATE OR REPLACE PROCEDURE sp_eliminar_detalle_pedido(IN p_id_detalle varchar)
LANGUAGE plpgsql AS $$ BEGIN
 DELETE FROM public.detalle_pedido WHERE id_detalle=p_id_detalle;
 IF NOT FOUND THEN RAISE EXCEPTION 'Detalle inexistente: %',p_id_detalle; END IF;
END $$;
