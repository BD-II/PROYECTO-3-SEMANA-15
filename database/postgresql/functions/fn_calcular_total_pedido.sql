CREATE OR REPLACE FUNCTION fn_calcular_total_pedido(pe_id_pedido varchar) RETURNS numeric
LANGUAGE sql STABLE AS $$ SELECT coalesce(sum(subtotal),0) FROM public.detalle_pedido WHERE id_pedido=pe_id_pedido $$;
