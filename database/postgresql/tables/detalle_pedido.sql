CREATE TABLE public.detalle_pedido (
    id_detalle character varying(10) NOT NULL,
    id_pedido character varying(10) NOT NULL,
    id_plato character varying(10) NOT NULL,
    cantidad integer NOT NULL,
    subtotal numeric(8,2) NOT NULL
);
