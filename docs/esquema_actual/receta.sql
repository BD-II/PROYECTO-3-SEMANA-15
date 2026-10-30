-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.receta (
  id_plato character varying(10) NOT NULL,
  id_ingrediente character varying(10) NOT NULL,
  cantidad_requerida numeric(10,2) NOT NULL,
  CONSTRAINT chk_receta_cantidad CHECK ((cantidad_requerida > (0)::numeric)),
  CONSTRAINT fk_receta_ingrediente FOREIGN KEY (id_ingrediente) REFERENCES ingrediente(id_ingrediente),
  CONSTRAINT fk_receta_plato FOREIGN KEY (id_plato) REFERENCES plato(id_plato),
  CONSTRAINT receta_cantidad_requerida_not_null NOT NULL cantidad_requerida,
  CONSTRAINT receta_id_ingrediente_not_null NOT NULL id_ingrediente,
  CONSTRAINT receta_id_plato_not_null NOT NULL id_plato,
  CONSTRAINT receta_pkey PRIMARY KEY (id_plato, id_ingrediente)
);
