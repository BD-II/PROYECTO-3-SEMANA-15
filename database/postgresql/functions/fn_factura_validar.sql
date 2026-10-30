CREATE FUNCTION fn_factura_validar() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE p public.pedido%ROWTYPE;
BEGIN
 IF TG_OP<>'INSERT' THEN RAISE EXCEPTION 'Comprobante inmutable; anulacion requiere proceso separado'; END IF;
 SELECT * INTO p FROM public.pedido WHERE id_pedido=NEW.id_pedido FOR UPDATE;
 IF NOT FOUND OR p.legado OR p.estado<>1 THEN RAISE EXCEPTION 'Pago requiere pedido nuevo en preparacion'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.detalle_pedido WHERE id_pedido=NEW.id_pedido)
 OR NEW.total_pagado<>public.fn_calcular_total_pedido(NEW.id_pedido) THEN RAISE EXCEPTION 'Importe no coincide con el pedido'; END IF;
 IF btrim(NEW.metodo_pago)='' THEN RAISE EXCEPTION 'Metodo de pago obligatorio'; END IF;
 RETURN NEW;
END $$;
