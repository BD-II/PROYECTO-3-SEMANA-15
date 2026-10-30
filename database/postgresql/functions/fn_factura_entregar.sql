CREATE FUNCTION fn_factura_entregar() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
 UPDATE public.pedido SET estado=2 WHERE id_pedido=NEW.id_pedido; RETURN NEW;
END $$;

