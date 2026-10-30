# Índice del código

Cada enlace abre un archivo legible en GitHub. Las tablas de la carpeta tables representan el punto de partida; migrations aplica las mejoras. Para ver directamente el resultado final de cada tabla, usar la vista de lectura siguiente. Los archivos maestros contienen el orden de ejecución.

## Tablas finales

| Tabla | Columnas y restricciones finales |
|---|---|
| cliente | [cliente.sql](esquema_actual/cliente.sql) |
| detalle_insumo | [detalle_insumo.sql](esquema_actual/detalle_insumo.sql) |
| detalle_pedido | [detalle_pedido.sql](esquema_actual/detalle_pedido.sql) |
| empleado | [empleado.sql](esquema_actual/empleado.sql) |
| factura | [factura.sql](esquema_actual/factura.sql) |
| historial_reserva | [historial_reserva.sql](esquema_actual/historial_reserva.sql) |
| ingrediente | [ingrediente.sql](esquema_actual/ingrediente.sql) |
| integracion_contrato | [integracion_contrato.sql](esquema_actual/integracion_contrato.sql) |
| mesa | [mesa.sql](esquema_actual/mesa.sql) |
| movimiento_inventario | [movimiento_inventario.sql](esquema_actual/movimiento_inventario.sql) |
| pedido | [pedido.sql](esquema_actual/pedido.sql) |
| plato | [plato.sql](esquema_actual/plato.sql) |
| proveedor | [proveedor.sql](esquema_actual/proveedor.sql) |
| receta | [receta.sql](esquema_actual/receta.sql) |
| reserva | [reserva.sql](esquema_actual/reserva.sql) |
| schema_version | [schema_version.sql](esquema_actual/schema_version.sql) |

## Procedimientos almacenados

- [sp_actualizar_estado_reserva.sql](../database/postgresql/procedures/sp_actualizar_estado_reserva.sql)
- [sp_actualizar_stock.sql](../database/postgresql/procedures/sp_actualizar_stock.sql)
- [sp_cambiar_estado_pedido.sql](../database/postgresql/procedures/sp_cambiar_estado_pedido.sql)
- [sp_eliminar_detalle_pedido.sql](../database/postgresql/procedures/sp_eliminar_detalle_pedido.sql)
- [sp_registrar_pago_pedido.sql](../database/postgresql/procedures/sp_registrar_pago_pedido.sql)

## Funciones y funciones de triggers

- [fn_calcular_total_pedido.sql](../database/postgresql/functions/fn_calcular_total_pedido.sql)
- [fn_calcularperdidaporcancelacion.sql](../database/postgresql/functions/fn_calcularperdidaporcancelacion.sql)
- [fn_detalle_inventario.sql](../database/postgresql/functions/fn_detalle_inventario.sql)
- [fn_detalle_validar.sql](../database/postgresql/functions/fn_detalle_validar.sql)
- [fn_factura_entregar.sql](../database/postgresql/functions/fn_factura_entregar.sql)
- [fn_factura_validar.sql](../database/postgresql/functions/fn_factura_validar.sql)
- [fn_id_inmutable.sql](../database/postgresql/functions/fn_id_inmutable.sql)
- [fn_ingredientes_stock_bajo.sql](../database/postgresql/functions/fn_ingredientes_stock_bajo.sql)
- [fn_mover_stock.sql](../database/postgresql/functions/fn_mover_stock.sql)
- [fn_normalizar_estado_reserva.sql](../database/postgresql/functions/fn_normalizar_estado_reserva.sql)
- [fn_pedido_validar.sql](../database/postgresql/functions/fn_pedido_validar.sql)
- [fn_registrar_historial_reserva.sql](../database/postgresql/functions/fn_registrar_historial_reserva.sql)
- [fn_resumen_pedido.sql](../database/postgresql/functions/fn_resumen_pedido.sql)

## Disparadores

- [a_detalle_validar.sql](../database/postgresql/triggers/a_detalle_validar.sql) — tabla `detalle_pedido`, función [fn_detalle_validar](../database/postgresql/functions/fn_detalle_validar.sql)
- [b_detalle_devolver.sql](../database/postgresql/triggers/b_detalle_devolver.sql) — tabla `detalle_pedido`, función [fn_detalle_inventario](../database/postgresql/functions/fn_detalle_inventario.sql)
- [cliente_id_estable.sql](../database/postgresql/triggers/cliente_id_estable.sql) — tabla `cliente`, función [fn_id_inmutable](../database/postgresql/functions/fn_id_inmutable.sql)
- [detalle_inventario.sql](../database/postgresql/triggers/detalle_inventario.sql) — tabla `detalle_pedido`, función [fn_detalle_inventario](../database/postgresql/functions/fn_detalle_inventario.sql)
- [empleado_id_estable.sql](../database/postgresql/triggers/empleado_id_estable.sql) — tabla `empleado`, función [fn_id_inmutable](../database/postgresql/functions/fn_id_inmutable.sql)
- [factura_entregar.sql](../database/postgresql/triggers/factura_entregar.sql) — tabla `factura`, función [fn_factura_entregar](../database/postgresql/functions/fn_factura_entregar.sql)
- [factura_validar.sql](../database/postgresql/triggers/factura_validar.sql) — tabla `factura`, función [fn_factura_validar](../database/postgresql/functions/fn_factura_validar.sql)
- [ingrediente_id_estable.sql](../database/postgresql/triggers/ingrediente_id_estable.sql) — tabla `ingrediente`, función [fn_id_inmutable](../database/postgresql/functions/fn_id_inmutable.sql)
- [pedido_validar.sql](../database/postgresql/triggers/pedido_validar.sql) — tabla `pedido`, función [fn_pedido_validar](../database/postgresql/functions/fn_pedido_validar.sql)
- [plato_id_estable.sql](../database/postgresql/triggers/plato_id_estable.sql) — tabla `plato`, función [fn_id_inmutable](../database/postgresql/functions/fn_id_inmutable.sql)
- [proveedor_id_estable.sql](../database/postgresql/triggers/proveedor_id_estable.sql) — tabla `proveedor`, función [fn_id_inmutable](../database/postgresql/functions/fn_id_inmutable.sql)
- [trg_historial_reserva.sql](../database/postgresql/triggers/trg_historial_reserva.sql) — tabla `reserva`, función [fn_registrar_historial_reserva](../database/postgresql/functions/fn_registrar_historial_reserva.sql)
- [trg_normalizar_estado_reserva.sql](../database/postgresql/triggers/trg_normalizar_estado_reserva.sql) — tabla `reserva`, función [fn_normalizar_estado_reserva](../database/postgresql/functions/fn_normalizar_estado_reserva.sql)

## Datos originales

- [01_cliente.sql](../database/postgresql/seeds/originales/01_cliente.sql)
- [02_empleado.sql](../database/postgresql/seeds/originales/02_empleado.sql)
- [03_proveedor.sql](../database/postgresql/seeds/originales/03_proveedor.sql)
- [04_ingrediente.sql](../database/postgresql/seeds/originales/04_ingrediente.sql)
- [05_plato.sql](../database/postgresql/seeds/originales/05_plato.sql)
- [06_receta.sql](../database/postgresql/seeds/originales/06_receta.sql)
- [07_pedido.sql](../database/postgresql/seeds/originales/07_pedido.sql)
- [08_detalle_pedido.sql](../database/postgresql/seeds/originales/08_detalle_pedido.sql)
- [09_factura.sql](../database/postgresql/seeds/originales/09_factura.sql)
- [10_reserva.sql](../database/postgresql/seeds/originales/10_reserva.sql)
- [11_historial_reserva.sql](../database/postgresql/seeds/originales/11_historial_reserva.sql)

## Orden y configuración

- [Instalación modular](../database/postgresql/install.sql)
- [Cambios V2](../database/postgresql/migrations/001_mejoras.sql)
- [Claves originales](../database/postgresql/constraints/001_originales.sql)
- [Índices](../database/postgresql/indexes/001_indices.sql)
- [Roles y permisos](../database/postgresql/security/001_roles.sql)
- [Maestro de recuperación de originales](../database/postgresql/seeds/009_originales_completos.sql)
- [Archivos listos para pgAdmin](../database/postgresql/pgadmin/)
- [Reglas y pruebas](../database/postgresql/tests/)

Las instantáneas en esquema_actual ayudan a leer el diseño final. No son una segunda ruta de instalación ni deben ejecutarse junto con el instalador. Regenerarlas si cambia el modelo.
