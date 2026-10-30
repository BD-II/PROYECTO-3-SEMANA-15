CREATE OR REPLACE PROCEDURE sp_actualizar_stock(IN p_id_ingrediente varchar,IN p_nuevo_stock numeric)
LANGUAGE plpgsql AS $$ DECLARE saldo numeric; BEGIN
 IF p_nuevo_stock IS NULL OR p_nuevo_stock<0 THEN RAISE EXCEPTION 'Stock invalido'; END IF;
 SELECT stock_actual INTO saldo FROM public.ingrediente WHERE id_ingrediente=p_id_ingrediente FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ingrediente inexistente'; END IF;
 PERFORM public.fn_mover_stock(p_id_ingrediente,p_nuevo_stock-saldo,'Ajuste manual conciliado');
END $$;
