\set ON_ERROR_STOP on
BEGIN;
SET LOCAL ROLE usuario_invitados;
SELECT count(*) FROM public.plato;
DO $$ BEGIN
 BEGIN PERFORM 1 FROM public.cliente;
 RAISE EXCEPTION 'Invitado pudo leer clientes' USING ERRCODE='ZX001';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
RESET ROLE;
SET LOCAL ROLE usuario_restaurante;
DO $$ BEGIN
 BEGIN UPDATE public.ingrediente SET stock_actual=999;
 RAISE EXCEPTION 'Operador modifico stock directamente' USING ERRCODE='ZX001';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
 BEGIN INSERT INTO public.movimiento_inventario(id_ingrediente,variacion,saldo_resultante,motivo) VALUES('IDEMO',999,999,'Inyeccion');
 RAISE EXCEPTION 'Operador modifico ledger' USING ERRCODE='ZX001';
 EXCEPTION WHEN insufficient_privilege THEN NULL; END;
END $$;
ROLLBACK;
