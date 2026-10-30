-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.mesa (
  numero_mesa integer NOT NULL,
  capacidad integer NOT NULL,
  CONSTRAINT mesa_capacidad_check CHECK ((capacidad > 0)),
  CONSTRAINT mesa_numero_mesa_check CHECK ((numero_mesa > 0)),
  CONSTRAINT mesa_capacidad_not_null NOT NULL capacidad,
  CONSTRAINT mesa_numero_mesa_not_null NOT NULL numero_mesa,
  CONSTRAINT mesa_pkey PRIMARY KEY (numero_mesa)
);
