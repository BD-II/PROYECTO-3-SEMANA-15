CREATE TABLE movimiento_inventario(
 id_movimiento bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 id_ingrediente varchar(10) NOT NULL REFERENCES ingrediente,
 id_pedido varchar(10) REFERENCES pedido,
 variacion numeric(12,2) NOT NULL,
 saldo_resultante numeric(12,2) NOT NULL CHECK(saldo_resultante>=0),
 motivo text NOT NULL,
 registrado_en timestamptz NOT NULL DEFAULT now());
