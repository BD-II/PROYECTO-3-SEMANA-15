CREATE TABLE mesa(numero_mesa integer PRIMARY KEY CHECK(numero_mesa>0), capacidad integer NOT NULL CHECK(capacidad>0));
