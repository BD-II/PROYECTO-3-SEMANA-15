ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (id_cliente);

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT detalle_pedido_pkey PRIMARY KEY (id_detalle);

ALTER TABLE ONLY public.empleado
    ADD CONSTRAINT empleado_pkey PRIMARY KEY (id_empleado);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_id_pedido_key UNIQUE (id_pedido);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_numero_comprobante_key UNIQUE (numero_comprobante);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT factura_pkey PRIMARY KEY (id_factura);

ALTER TABLE ONLY public.historial_reserva
    ADD CONSTRAINT historial_reserva_pkey PRIMARY KEY (id_historial);

ALTER TABLE ONLY public.ingrediente
    ADD CONSTRAINT ingrediente_pkey PRIMARY KEY (id_ingrediente);

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (id_pedido);

ALTER TABLE ONLY public.plato
    ADD CONSTRAINT plato_pkey PRIMARY KEY (id_plato);

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_pkey PRIMARY KEY (id_proveedor);

ALTER TABLE ONLY public.proveedor
    ADD CONSTRAINT proveedor_ruc_key UNIQUE (ruc);

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_plato, id_ingrediente);

ALTER TABLE ONLY public.reserva
    ADD CONSTRAINT reserva_pkey PRIMARY KEY (id_reserva);

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT fk_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido);

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT fk_empleado FOREIGN KEY (id_empleado) REFERENCES public.empleado(id_empleado);

ALTER TABLE ONLY public.factura
    ADD CONSTRAINT fk_factura_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedido(id_pedido);

ALTER TABLE ONLY public.historial_reserva
    ADD CONSTRAINT fk_historial_reserva FOREIGN KEY (id_reserva) REFERENCES public.reserva(id_reserva);

ALTER TABLE ONLY public.ingrediente
    ADD CONSTRAINT fk_ingrediente_proveedor FOREIGN KEY (id_proveedor) REFERENCES public.proveedor(id_proveedor);

ALTER TABLE ONLY public.detalle_pedido
    ADD CONSTRAINT fk_plato FOREIGN KEY (id_plato) REFERENCES public.plato(id_plato);

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT fk_receta_ingrediente FOREIGN KEY (id_ingrediente) REFERENCES public.ingrediente(id_ingrediente);

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT fk_receta_plato FOREIGN KEY (id_plato) REFERENCES public.plato(id_plato);

ALTER TABLE ONLY public.reserva
    ADD CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES public.cliente(id_cliente);
