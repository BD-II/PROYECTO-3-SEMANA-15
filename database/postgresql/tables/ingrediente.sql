CREATE TABLE public.ingrediente (
    id_ingrediente character varying(10) NOT NULL,
    id_proveedor character varying(10) NOT NULL,
    nombre_ingrediente character varying(100) NOT NULL,
    stock_actual numeric(10,2) NOT NULL,
    unidad_medida character varying(20) NOT NULL,
    CONSTRAINT chk_ingrediente_stock CHECK ((stock_actual >= (0)::numeric))
);
