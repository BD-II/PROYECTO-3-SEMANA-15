CREATE TABLE schema_version(version integer PRIMARY KEY, aplicado_en timestamptz NOT NULL DEFAULT now());
