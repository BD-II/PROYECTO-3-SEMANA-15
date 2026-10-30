CREATE TABLE public.factura (
    id_factura character varying(10) NOT NULL,
    id_pedido character varying(10) NOT NULL,
    numero_comprobante integer NOT NULL,
    metodo_pago character varying(20) NOT NULL,
    total_pagado numeric(8,2) NOT NULL
);
