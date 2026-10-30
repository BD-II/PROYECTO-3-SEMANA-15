CREATE FUNCTION fn_mover_stock(p_ingrediente varchar,p_delta numeric,p_motivo text,p_pedido varchar DEFAULT NULL)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE saldo numeric;
BEGIN
 IF p_delta IS NULL OR p_motivo IS NULL OR btrim(p_motivo)='' THEN RAISE EXCEPTION 'Movimiento incompleto'; END IF;
 UPDATE public.ingrediente SET stock_actual=stock_actual+p_delta
 WHERE id_ingrediente=p_ingrediente AND stock_actual+p_delta>=0 RETURNING stock_actual INTO saldo;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ingrediente inexistente o stock insuficiente: %',p_ingrediente; END IF;
 INSERT INTO public.movimiento_inventario(id_ingrediente,id_pedido,variacion,saldo_resultante,motivo)
 VALUES(p_ingrediente,p_pedido,p_delta,saldo,p_motivo);
END $$;

