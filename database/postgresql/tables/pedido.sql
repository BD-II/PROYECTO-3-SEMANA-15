CREATE TABLE public.pedido (
    id_pedido character varying(10) NOT NULL,
    id_empleado character varying(10) NOT NULL,
    id_cliente character varying(10) NOT NULL,
    fecha timestamp without time zone NOT NULL,
    tipo_pedido character varying(20) NOT NULL,
    estado integer NOT NULL,
    CONSTRAINT chk_pedido_estado CHECK ((estado = ANY (ARRAY[0, 1, 2, 3])))
);
