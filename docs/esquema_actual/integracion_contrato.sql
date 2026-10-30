-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.integracion_contrato (
  entidad text NOT NULL,
  columna_id text NOT NULL,
  descripcion text NOT NULL,
  CONSTRAINT integracion_contrato_columna_id_not_null NOT NULL columna_id,
  CONSTRAINT integracion_contrato_descripcion_not_null NOT NULL descripcion,
  CONSTRAINT integracion_contrato_entidad_not_null NOT NULL entidad,
  CONSTRAINT integracion_contrato_pkey PRIMARY KEY (entidad)
);
