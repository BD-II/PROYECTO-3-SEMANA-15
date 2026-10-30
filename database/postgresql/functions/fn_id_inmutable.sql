CREATE FUNCTION fn_id_inmutable() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
 IF to_jsonb(NEW)->TG_ARGV[0] IS DISTINCT FROM to_jsonb(OLD)->TG_ARGV[0] THEN
 RAISE EXCEPTION 'Identificador estable: % no se modifica',TG_ARGV[0]; END IF; RETURN NEW;
END $$;
