# Trabajo del equipo

1. Leer README e INDICE_CODIGO antes de modificar SQL.
2. Crear una rama por tarea, por ejemplo `fix/validacion-reservas`.
3. Editar archivos modulares, no los archivos compilados de pgadmin.
4. Ejecutar `python scripts/compilar_sql.py` cuando cambie una fuente.
5. Ejecutar `npm ci`, `npm test` y `npm run test:originales` antes de proponer cambios.
6. Subir la rama y abrir un Pull Request para que otro integrante revise el cambio.

No modificar precios/estados del conjunto original para hacer pasar pruebas. Las cuatro facturas inconsistentes se conservan como evidencia historica. Si se corrigen, documentar antes, despues y motivo mediante un script independiente.

Nunca publicar contrasenas. Los datos ficticios originales si forman parte del repositorio. Los archivos `.backup` pueden adjuntarse a una Release como complemento; el codigo SQL sigue siendo la referencia revisable.

Las reglas de aprobacion de ramas y los permisos de colaboradores deben configurarse en GitHub; este paquete no los activa automaticamente.
