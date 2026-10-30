-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.ingrediente (
  id_ingrediente character varying(10) NOT NULL,
  id_proveedor character varying(10) NOT NULL,
  nombre_ingrediente character varying(100) NOT NULL,
  stock_actual numeric(10,2) NOT NULL,
  unidad_medida character varying(20) NOT NULL,
  CONSTRAINT chk_ingrediente_stock CHECK ((stock_actual >= (0)::numeric)),
  CONSTRAINT fk_ingrediente_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor),
  CONSTRAINT ingrediente_id_ingrediente_not_null NOT NULL id_ingrediente,
  CONSTRAINT ingrediente_id_proveedor_not_null NOT NULL id_proveedor,
  CONSTRAINT ingrediente_nombre_ingrediente_not_null NOT NULL nombre_ingrediente,
  CONSTRAINT ingrediente_stock_actual_not_null NOT NULL stock_actual,
  CONSTRAINT ingrediente_unidad_medida_not_null NOT NULL unidad_medida,
  CONSTRAINT ingrediente_pkey PRIMARY KEY (id_ingrediente)
);
