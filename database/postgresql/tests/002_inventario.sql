\set ON_ERROR_STOP on
BEGIN;
DO $$ BEGIN
 INSERT INTO plato VALUES('PLTEST2','Segundo plato','Prueba',10);
 INSERT INTO receta VALUES('PLTEST2','IDEMO',3);
 INSERT INTO pedido VALUES('PTEST2','EDEMO','CDEMO',now(),'Local',0,false);
 INSERT INTO detalle_pedido(id_detalle,id_pedido,id_plato,cantidad,subtotal) VALUES('DTEST2','PTEST2','PLDEMO',2,0);
 UPDATE detalle_pedido SET id_plato='PLTEST2' WHERE id_detalle='DTEST2';
 IF (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>94 OR fn_calcular_total_pedido('PTEST2')<>20 THEN RAISE EXCEPTION 'Fallo cambio plato'; END IF;
 UPDATE receta SET cantidad_requerida=9 WHERE id_plato='PLTEST2';
 DELETE FROM detalle_pedido WHERE id_detalle='DTEST2';
 IF (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>100 THEN RAISE EXCEPTION 'No uso instantanea receta'; END IF;
 INSERT INTO detalle_pedido(id_detalle,id_pedido,id_plato,cantidad,subtotal) VALUES('DTEST2','PTEST2','PLDEMO',2,0);
 CALL sp_cambiar_estado_pedido('PTEST2',3);
 IF (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>100 THEN RAISE EXCEPTION 'Cancelacion pendiente no devolvio'; END IF;
 INSERT INTO pedido VALUES('PTEST3','EDEMO','CDEMO',now(),'Local',0,false);
 INSERT INTO detalle_pedido(id_detalle,id_pedido,id_plato,cantidad,subtotal) VALUES('DTEST3','PTEST3','PLDEMO',2,0);
 CALL sp_cambiar_estado_pedido('PTEST3',1);
 CALL sp_cambiar_estado_pedido('PTEST3',3);
 IF (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>96 THEN RAISE EXCEPTION 'Devolvio ingredientes preparados'; END IF;
 CALL sp_actualizar_stock('IDEMO',105);
 IF (SELECT stock_actual FROM ingrediente WHERE id_ingrediente='IDEMO')<>105 THEN RAISE EXCEPTION 'Fallo ajuste'; END IF;
END $$;
ROLLBACK;
