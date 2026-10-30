-- Generado: editar fuentes modulares y recompilar.
-- Base de pruebas con seed demo. ROLLBACK: no conserva pedidos de prueba.
BEGIN;
DO $$
DECLARE n integer; saldo numeric;
BEGIN
 INSERT INTO pedido VALUES('PTEST','EDEMO','CDEMO',now(),'Local',0,false);
 INSERT INTO detalle_pedido(id_detalle,id_pedido,id_plato,cantidad,subtotal) VALUES('DTEST','PTEST','PLDEMO',2,0);
 IF (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>96 THEN RAISE EXCEPTION 'Fallo descuento'; END IF;
 UPDATE plato SET precio=30 WHERE id_plato='PLDEMO';
 IF fn_calcular_total_pedido('PTEST')<>50 OR (SELECT total_pedido FROM fn_resumen_pedido('PTEST'))<>50 THEN RAISE EXCEPTION 'Fallo historico'; END IF;
 UPDATE detalle_pedido SET cantidad=3 WHERE id_detalle='DTEST';
 IF fn_calcular_total_pedido('PTEST')<>75 OR (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>94 THEN RAISE EXCEPTION 'Fallo cambio cantidad'; END IF;
 CALL sp_eliminar_detalle_pedido('DTEST');
 IF (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>100 THEN RAISE EXCEPTION 'Fallo devolucion'; END IF;
 BEGIN
 INSERT INTO detalle_pedido(id_detalle,id_pedido,id_plato,cantidad,subtotal) VALUES('DBAD','PTEST','PLDEMO',1000,0);
 RAISE EXCEPTION 'No rechazo falta de stock' USING ERRCODE='ZX001';
 EXCEPTION WHEN SQLSTATE 'ZX001' THEN RAISE; WHEN OTHERS THEN NULL; END;
 IF EXISTS(SELECT 1 FROM detalle_pedido WHERE id_detalle='DBAD') OR (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>100 THEN RAISE EXCEPTION 'Fallo atomicidad stock'; END IF;
 INSERT INTO detalle_pedido(id_detalle,id_pedido,id_plato,cantidad,subtotal) VALUES('DTEST','PTEST','PLDEMO',1,0);
 CALL sp_cambiar_estado_pedido('PTEST',1);
 BEGIN
 CALL sp_registrar_pago_pedido('FTEST','PTEST',999001,'Efectivo',1);
 RAISE EXCEPTION 'Acepto pago incorrecto' USING ERRCODE='ZX001';
 EXCEPTION WHEN SQLSTATE 'ZX001' THEN RAISE; WHEN OTHERS THEN NULL; END;
 IF (SELECT estado FROM pedido WHERE id_pedido='PTEST')<>1 THEN RAISE EXCEPTION 'Fallo rollback pago'; END IF;
 CALL sp_registrar_pago_pedido('FTEST','PTEST',999001,'Efectivo',30);
 IF (SELECT estado FROM pedido WHERE id_pedido='PTEST')<>2 THEN RAISE EXCEPTION 'Fallo entrega'; END IF;
 BEGIN
 DELETE FROM detalle_pedido WHERE id_detalle='DTEST';
 RAISE EXCEPTION 'Edito pedido cerrado' USING ERRCODE='ZX001';
 EXCEPTION WHEN SQLSTATE 'ZX001' THEN RAISE; WHEN OTHERS THEN NULL; END;
 INSERT INTO reserva VALUES('RTEST','CDEMO','2030-01-01 12:00',999,2,'pendiente',120);
 CALL sp_actualizar_estado_reserva('RTEST','Confirmada');
 CALL sp_actualizar_estado_reserva('RTEST','Confirmada');
 SELECT count(*) INTO n FROM historial_reserva WHERE id_reserva='RTEST';
 IF n<>1 THEN RAISE EXCEPTION 'Fallo historial'; END IF;
 BEGIN
 INSERT INTO reserva VALUES('RBAD','CDEMO','2030-01-01 13:00',999,2,'Pendiente',120);
 RAISE EXCEPTION 'Acepto cruce' USING ERRCODE='ZX001';
 EXCEPTION WHEN SQLSTATE 'ZX001' THEN RAISE; WHEN OTHERS THEN NULL; END;
 INSERT INTO reserva VALUES('RLIM','CDEMO','2030-01-01 14:00',999,2,'Pendiente',120);
 RAISE NOTICE 'Pruebas principales correctas';
END $$;
ROLLBACK;
