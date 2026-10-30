-- VISTA DE LECTURA del esquema final V2, generada desde PostgreSQL.
-- No ejecutar aparte: instalar mediante pgadmin/01_instalar.sql.
CREATE TABLE public.factura (
  id_factura character varying(10) NOT NULL,
  id_pedido character varying(10) NOT NULL,
  numero_comprobante integer NOT NULL,
  metodo_pago character varying(20) NOT NULL,
  total_pagado numeric(8,2) NOT NULL,
  CONSTRAINT factura_importe_valido CHECK ((total_pagado >= (0)::numeric)),
  CONSTRAINT fk_factura_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
  CONSTRAINT factura_id_factura_not_null NOT NULL id_factura,
  CONSTRAINT factura_id_pedido_not_null NOT NULL id_pedido,
  CONSTRAINT factura_metodo_pago_not_null NOT NULL metodo_pago,
  CONSTRAINT factura_numero_comprobante_not_null NOT NULL numero_comprobante,
  CONSTRAINT factura_total_pagado_not_null NOT NULL total_pagado,
  CONSTRAINT factura_pkey PRIMARY KEY (id_factura),
  CONSTRAINT factura_id_pedido_key UNIQUE (id_pedido),
  CONSTRAINT factura_numero_comprobante_key UNIQUE (numero_comprobante)
);
