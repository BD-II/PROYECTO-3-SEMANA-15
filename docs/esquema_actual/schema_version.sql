-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.schema_version (
  version integer NOT NULL,
  aplicado_en timestamp with time zone DEFAULT now() NOT NULL,
  CONSTRAINT schema_version_aplicado_en_not_null NOT NULL aplicado_en,
  CONSTRAINT schema_version_version_not_null NOT NULL version,
  CONSTRAINT schema_version_pkey PRIMARY KEY (version)
);
