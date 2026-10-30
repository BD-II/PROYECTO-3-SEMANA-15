CREATE TABLE public.receta (
    id_plato character varying(10) NOT NULL,
    id_ingrediente character varying(10) NOT NULL,
    cantidad_requerida numeric(10,2) NOT NULL,
    CONSTRAINT chk_receta_cantidad CHECK ((cantidad_requerida > (0)::numeric))
);
