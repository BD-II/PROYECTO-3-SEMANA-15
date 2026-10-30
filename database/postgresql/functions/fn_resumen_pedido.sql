CREATE OR REPLACE FUNCTION fn_resumen_pedido(pe_id_pedido varchar)
RETURNS TABLE(id_pedido varchar,id_cliente varchar,fecha timestamp,tipo_pedido varchar,estado integer,cantidad_platos bigint,total_pedido numeric)
LANGUAGE sql STABLE AS $$
 SELECT p.id_pedido,p.id_cliente,p.fecha,p.tipo_pedido,p.estado,coalesce(sum(d.cantidad),0)::bigint,coalesce(sum(d.subtotal),0)
 FROM public.pedido p LEFT JOIN public.detalle_pedido d USING(id_pedido)
 WHERE p.id_pedido=pe_id_pedido GROUP BY p.id_pedido $$;
