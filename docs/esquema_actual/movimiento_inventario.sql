-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.movimiento_inventario (
  id_movimiento bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  id_ingrediente character varying(10) NOT NULL,
  id_pedido character varying(10),
  variacion numeric(12,2) NOT NULL,
  saldo_resultante numeric(12,2) NOT NULL,
  motivo text NOT NULL,
  registrado_en timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT movimiento_inventario_saldo_resultante_check CHECK ((saldo_resultante >= (0)::numeric)),
  CONSTRAINT movimiento_inventario_id_ingrediente_fkey FOREIGN KEY (id_ingrediente) REFERENCES ingrediente(id_ingrediente),
  CONSTRAINT movimiento_inventario_id_pedido_fkey FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
  CONSTRAINT movimiento_inventario_id_ingrediente_not_null NOT NULL id_ingrediente,
  CONSTRAINT movimiento_inventario_id_movimiento_not_null NOT NULL id_movimiento,
  CONSTRAINT movimiento_inventario_motivo_not_null NOT NULL motivo,
  CONSTRAINT movimiento_inventario_registrado_en_not_null NOT NULL registrado_en,
  CONSTRAINT movimiento_inventario_saldo_resultante_not_null NOT NULL saldo_resultante,
  CONSTRAINT movimiento_inventario_variacion_not_null NOT NULL variacion,
  CONSTRAINT movimiento_inventario_pkey PRIMARY KEY (id_movimiento)
);
