-- Generado: editar fuentes modulares y recompilar.
BEGIN;
INSERT INTO cliente VALUES('CDEMO','Cliente','Demostracion','000000000','Direccion ficticia');
INSERT INTO empleado VALUES('EDEMO','Empleado','Demostracion','Atencion','000000000');
INSERT INTO proveedor VALUES('PRDEMO','Proveedor ficticio','00000000000','000000000','Contacto ficticio');
INSERT INTO ingrediente VALUES('IDEMO','PRDEMO','Insumo demostracion',100,'unidad');
INSERT INTO plato VALUES('PLDEMO','Plato demostracion','Principal',25);
INSERT INTO receta VALUES('PLDEMO','IDEMO',2);
INSERT INTO mesa VALUES(999,4);
COMMIT;
