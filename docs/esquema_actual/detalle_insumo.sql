-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.detalle_insumo (
  id_detalle character varying(10) NOT NULL,
  id_ingrediente character varying(10) NOT NULL,
  cantidad_por_unidad numeric(10,2) NOT NULL,
  CONSTRAINT detalle_insumo_cantidad_por_unidad_check CHECK ((cantidad_por_unidad > (0)::numeric)),
  CONSTRAINT detalle_insumo_id_detalle_fkey FOREIGN KEY (id_detalle) REFERENCES detalle_pedido(id_detalle) ON DELETE CASCADE,
  CONSTRAINT detalle_insumo_id_ingrediente_fkey FOREIGN KEY (id_ingrediente) REFERENCES ingrediente(id_ingrediente),
  CONSTRAINT detalle_insumo_cantidad_por_unidad_not_null NOT NULL cantidad_por_unidad,
  CONSTRAINT detalle_insumo_id_detalle_not_null NOT NULL id_detalle,
  CONSTRAINT detalle_insumo_id_ingrediente_not_null NOT NULL id_ingrediente,
  CONSTRAINT detalle_insumo_pkey PRIMARY KEY (id_detalle, id_ingrediente)
);
