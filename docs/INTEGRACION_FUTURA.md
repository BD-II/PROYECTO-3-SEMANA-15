# Contrato para integrar posteriormente MongoDB

PostgreSQL conserva los datos operativos. En esta etapa NO se crean colecciones MongoDB, API, frontend ni tareas de sincronización.

## Identificadores

Se conservan los identificadores VARCHAR(10) originales. El backend puede generar nuevos códigos únicos dentro de esa longitud; todavía no existe un generador distribuido de códigos. MongoDB guardará la referencia exacta como string (por ejemplo `platoId: "P001"`), no un ObjectId que pretenda sustituirla. Su documento puede tener además su propio `_id`.

El operador no puede borrar maestros; sus ID son inmutables. En un futuro, bajas de platos/clientes deben diseñarse como baja lógica o coordinar referencias externas. Una referencia MongoDB no queda validada automáticamente por PostgreSQL.

## Propiedad de los datos

| Entidad | Fuente de verdad | Complemento futuro posible |
|---|---|---|
| Plato | PostgreSQL: identificador, nombre, precio y receta | MongoDB: imágenes, descripción, etiquetas |
| Pedido | PostgreSQL: estado, detalles y valores históricos | MongoDB: reseñas validadas por el backend |
| Cliente | PostgreSQL: identidad operativa | MongoDB: preferencias adicionales |

`integracion_contrato` deja documentados esos identificadores en la propia base. Es documentación, no un enlace de red ni una validación entre motores.

## Operaciones para el backend

Crear pedido pendiente; insertar detalles sin enviar precio/subtotal (se calculan); cambiar cantidades o plato mientras pendiente; llamar `sp_cambiar_estado_pedido`; consultar `fn_resumen_pedido`; registrar pago mediante `sp_registrar_pago_pedido`; ajustar stock mediante `sp_actualizar_stock`; actualizar reserva mediante `sp_actualizar_estado_reserva`.

Ejemplo de inserción de detalle:

```sql
INSERT INTO detalle_pedido(id_detalle,id_pedido,id_plato,cantidad)
VALUES ('D0001','PD0001','P001',2);
```

El backend debe parametrizar consultas y manejar errores SQL. No calcular importes confiando en lo enviado por el navegador. Reintentar transacciones completas ante deadlock/serialización cuando proceda; no repetir ciegamente pagos ya confirmados. El UNIQUE por pedido evita dos facturas del mismo pedido, pero no reemplaza un diseño futuro de idempotencia HTTP.

## Límites entre bases

Una transacción SQL no incluye MongoDB. Inicialmente conviene que el backend lea ambas bases para componer el menú y que escribir una reseña requiera validar previamente el pedido entregado. No escribir el mismo precio o stock en dos fuentes principales. Si luego se requieren eventos fiables entre motores, diseñar outbox y consumidor idempotente; no están implementados en esta entrega.
