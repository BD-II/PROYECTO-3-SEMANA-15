# Cambios detallados respecto de la PC1

## 1. Organización e instalación

Antes: respaldo binario y documentación con SQL mezclado. Ahora: una definición por archivo para tablas, funciones, procedimientos y triggers; maestros explícitos para respetar dependencias. Índices, restricciones, permisos, seeds, actualización y pruebas separados. No se requiere MongoDB para ejecutar esta entrega.

Las tablas de PC1 se crean con su estructura original y se aplica después la misma mejora que recibe una base restaurada. Esto evita mantener dos implementaciones independientes. `schema_version` registra la versión 2. No es todavía un gestor general de migraciones.

## 2. Precio de venta y subtotales

`detalle_pedido.precio_unitario NUMERIC(12,2) NOT NULL` es nuevo. El trigger lo obtiene de `plato.precio` al agregar un detalle o cambiar de plato. Si solo cambia cantidad, conserva el precio histórico. No se permite modificar directamente el precio histórico. El subtotal se calcula con cantidad por precio; una restricción comprueba su coherencia.

En registros existentes se reconstruye como subtotal/cantidad, solo si puede expresarse exactamente en céntimos. La actualización se detiene antes de modificar datos si detecta cantidades inválidas, subtotales negativos o reconstrucción incoherente. No usa precios actuales para inventar precios antiguos.

Ejemplo: 2 platos vendidos a S/25 conservan S/50 aunque el precio de carta suba a S/30. Ambas funciones `fn_calcular_total_pedido` y `fn_resumen_pedido` suman los subtotales históricos. La segunda ya no utiliza el precio actual de Plato.

Se mantienen NUMERIC(8,2) en subtotal, precio original y total pagado por compatibilidad; cantidades/importes demasiado grandes se rechazan por desbordamiento y revierten la operación.

## 3. Inventario por detalle y movimientos

Los antiguos triggers `trg_descontar_stock` y `trg_ajustar_stock_actualizado`, y sus dos funciones, se retiran. Los reemplazan `fn_detalle_validar`, `fn_detalle_inventario` y sus triggers.

Nueva tabla `detalle_insumo`: instantánea de los ingredientes y cantidades unitarias usados al agregar el plato. Se mantiene aunque posteriormente cambie Receta. Al modificar cantidad conserva esa instantánea; al cambiar de plato devuelve lo anterior y toma una nueva receta. Al eliminar devuelve lo descontado. Si una operación no dispone de stock, toda la sentencia se revierte, incluidas devoluciones intermedias y registros de movimiento.

Nueva tabla `movimiento_inventario`: ingrediente, pedido opcional, variación, saldo resultante, motivo y fecha. `fn_mover_stock` hace una actualización condicionada a saldo no negativo y registra el resultado. La actualización incluye bloqueo de fila por PostgreSQL; no se usa una lectura desprotegida seguida de escritura.

Al actualizar PC1 se registra un saldo inicial con el stock actual, sin recalcular consumos del pasado. Los ingredientes incorporados posteriormente por el operador pueden entrar con saldo inicial; el registro automatizado de ese alta inicial es una mejora pendiente. Los posteriores cambios por pedidos y el procedimiento de ajustes sí se registran. No se implementa todavía un módulo de compras ni costos de mermas.

El procedimiento compatible `sp_actualizar_stock` ahora bloquea el ingrediente y registra la diferencia como ajuste manual. El operador no puede modificar stock directamente.

## 4. Estados de pedido y cancelaciones

Transiciones: pendiente → preparación o cancelado; preparación → entregado o cancelado. Entregado requiere factura. Pedidos cerrados no se editan. El trigger del detalle bloquea la fila del pedido para coordinar edición, cambio de estado y pago.

Cancelación pendiente: devuelve el consumo guardado por detalle una sola vez. Cancelación en preparación: conserva la salida de stock. Se asume que al entrar en preparación todos esos ingredientes se consumieron. Esta regla es explícita y puede ajustarse al negocio.

`fn_calcularperdidaporcancelacion` se conserva por compatibilidad, con comentario que aclara que mide valor de ventas canceladas, no costo real de pérdida.

Nueva marca `pedido.legado`: los 50 pedidos del respaldo quedan protegidos contra cambios y nuevas facturas. No se fabrican instantáneas de sus consumos antiguos. Permanecen consultables. Si necesitan continuar uno pendiente, un administrador debe conciliar físicamente inventario, receta utilizada y facturación; esta entrega no incluye un procedimiento automático de desbloqueo.

## 5. Facturación

`sp_registrar_pago_pedido` inserta el comprobante. El trigger verifica que el pedido exista, sea nuevo, esté en preparación, tenga detalles y el importe sea exactamente igual al total histórico. Después de insertar factura, otro trigger marca entregado. Un fallo revierte factura y cambio de estado en la misma operación.

La validación funciona también si el propietario inserta directamente una factura. El operador debe usar el procedimiento. UPDATE y DELETE de facturas se rechazan. Se conservan las restricciones UNIQUE de pedido y número de comprobante.

Ejemplo: pedido total S/30, intento pagar S/1 → error, sin factura y con pedido todavía en preparación. Pago S/30 → factura creada y pedido entregado.

Los comprobantes previos no se modifican. Las cuatro discrepancias del respaldo se muestran en el diagnóstico.

## 6. Reservas y mesas

Nueva tabla `mesa(numero_mesa, capacidad)`. Reserva obtiene FK a Mesa y `duracion_minutos` de 15 a 720. Para conservar datos previos se crean mesas usando la mayor cantidad de personas histórica como capacidad provisional. Esto NO verifica la capacidad física real: debe confirmarse antes de utilizarlo en el restaurante.

La duración previa se asume de 120 minutos y se valida que las reservas activas no se superpongan. Si otro respaldo tiene cruces, la actualización se detiene; no cancela reservas automáticamente.

Una restricción EXCLUDE con rangos GiST evita cruces incluso entre transacciones concurrentes. Usa rangos enteros para la mesa, sin extensión btree_gist. El trigger además comprueba capacidad, normaliza el estado y proporciona un error descriptivo. No se validan todavía todas las transiciones de estado de reservas ni cambios administrativos de capacidad frente a reservas ya guardadas.

12:00–14:00 y 13:00–15:00 en la misma mesa se rechazan; 12:00–14:00 y 14:00–16:00 se permiten.

## 7. Historial de reservas

`fn_registrar_historial_reserva` compara estado anterior y nuevo con IS DISTINCT FROM. Una actualización al mismo estado ya no genera ruido. El identificador utiliza la secuencia sin LPAD de tres dígitos, evitando truncamiento al crecer. Se ajusta la secuencia para superar los identificadores históricos encontrados.

La función se ejecuta con derechos de propietario y search_path controlado; el operador no necesita acceso directo de escritura al historial ni a la secuencia.

## 8. Restricciones e índices

Se agregan controles de cantidad positiva, precio no negativo, coherencia del subtotal y pago no negativo. Se mantienen estados válidos, stock no negativo, receta positiva y controles originales de reservas.

Índices nuevos en referencias usadas para listar pedidos por cliente/fecha, empleado, detalles por pedido/plato, ingrediente por proveedor, receta por ingrediente, reservas por cliente/mesa/fecha, historial y movimientos. No se declara una mejora de rendimiento medida: no hubo benchmark de carga.

## 9. Seguridad e identificadores

El invitado consulta exclusivamente Plato. El operador puede atender el negocio, pero no escribir directamente en facturas, historial, instantáneas ni movimientos; los procedimientos y triggers autorizados realizan esas tareas. Ver SEGURIDAD.md.

Los ID de cliente, empleado, plato, ingrediente y proveedor no pueden modificarse mediante UPDATE; pedido, detalle y reserva tienen protección en sus validadores. Se conserva VARCHAR(10), sin convertir a ObjectId o UUID y sin mezclar IDs de motores. El operador no puede borrar entidades maestras, lo que reduce referencias externas huérfanas.

## 10. Validación y límites

Se ejecutaron instalación limpia, datos demo, regresiones de stock/pagos/reservas, mismas operaciones bajo rol operativo, pruebas negativas de permisos y actualización de estructura/datos extraídos del respaldo. Ver registros de validación.

Se utilizó PostgreSQL 18.6 embebido en PGlite. No se ejecutó pg_restore nativo ni una prueba con varias conexiones reales; el control de cruces depende de una restricción nativa, pero todavía corresponde una comprobación de concurrencia y restauración en su PostgreSQL local. La aplicación debe poder reintentar transacciones abortadas por deadlock o serialización. No se desarrolló autenticación de usuarios del frontend.

## Distribución para GitHub

La entrega para el equipo incluye los datos ficticios originales por tabla y un maestro transaccional para importarlos. El contenido de catálogo ya cargado con 08 no se duplica. Durante la importación histórica solo se suspenden triggers de negocio y se restaura su estado previo; las restricciones de integridad permanecen activas. No se inventan consumos ni se alteran las cuatro discrepancias facturadas. El antiguo 09 de nuevos datos operativos fue sustituido por la recuperación de originales.
