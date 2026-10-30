\set ON_ERROR_STOP on
-- Ejecutar SOLO en una copia restaurada de PC1, sin backend conectado.
BEGIN;
\ir migrations/001_mejoras.sql
COMMIT;
