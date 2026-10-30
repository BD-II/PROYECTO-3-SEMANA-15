CREATE TABLE detalle_insumo(
 id_detalle varchar(10) REFERENCES detalle_pedido ON DELETE CASCADE,
 id_ingrediente varchar(10) REFERENCES ingrediente,
 cantidad_por_unidad numeric(10,2) NOT NULL CHECK(cantidad_por_unidad>0),
 PRIMARY KEY(id_detalle,id_ingrediente));
