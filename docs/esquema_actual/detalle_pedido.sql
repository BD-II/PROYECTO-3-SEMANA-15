-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.detalle_pedido (
  id_detalle character varying(10) NOT NULL,
  id_pedido character varying(10) NOT NULL,
  id_plato character varying(10) NOT NULL,
  cantidad integer NOT NULL,
  subtotal numeric(8,2) NOT NULL,
  precio_unitario numeric(12,2) NOT NULL,
  CONSTRAINT detalle_cantidad_positiva CHECK ((cantidad > 0)),
  CONSTRAINT detalle_precio_valido CHECK ((precio_unitario >= (0)::numeric)),
  CONSTRAINT detalle_subtotal_coherente CHECK ((subtotal = round(((cantidad)::numeric * precio_unitario), 2))),
  CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
  CONSTRAINT fk_plato FOREIGN KEY (id_plato) REFERENCES plato(id_plato),
  CONSTRAINT detalle_pedido_cantidad_not_null NOT NULL cantidad,
  CONSTRAINT detalle_pedido_id_detalle_not_null NOT NULL id_detalle,
  CONSTRAINT detalle_pedido_id_pedido_not_null NOT NULL id_pedido,
  CONSTRAINT detalle_pedido_id_plato_not_null NOT NULL id_plato,
  CONSTRAINT detalle_pedido_precio_unitario_not_null NOT NULL precio_unitario,
  CONSTRAINT detalle_pedido_subtotal_not_null NOT NULL subtotal,
  CONSTRAINT detalle_pedido_pkey PRIMARY KEY (id_detalle)
);
