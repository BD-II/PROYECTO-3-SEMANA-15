CREATE FUNCTION fn_detalle_validar() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE p public.pedido%ROWTYPE;
BEGIN
 IF TG_OP='UPDATE' AND (NEW.id_detalle<>OLD.id_detalle OR NEW.id_pedido<>OLD.id_pedido) THEN
 RAISE EXCEPTION 'Identificadores del detalle y pedido son inmutables'; END IF;
 SELECT * INTO p FROM public.pedido WHERE id_pedido=CASE WHEN TG_OP='DELETE' THEN OLD.id_pedido ELSE NEW.id_pedido END FOR UPDATE;
 IF NOT FOUND OR p.legado OR p.estado<>0 THEN RAISE EXCEPTION 'Solo se editan detalles de pedidos nuevos pendientes'; END IF;
 IF TG_OP='DELETE' THEN RETURN OLD; END IF;
 IF TG_OP='INSERT' OR NEW.id_plato IS DISTINCT FROM OLD.id_plato THEN
 SELECT precio INTO NEW.precio_unitario FROM public.plato WHERE id_plato=NEW.id_plato;
 IF NOT FOUND THEN RAISE EXCEPTION 'Plato inexistente'; END IF;
 ELSIF NEW.precio_unitario IS DISTINCT FROM OLD.precio_unitario THEN
 RAISE EXCEPTION 'El precio historico no se edita';
 END IF;
 NEW.subtotal=round(NEW.cantidad*NEW.precio_unitario,2);
 RETURN NEW;
END $$;

