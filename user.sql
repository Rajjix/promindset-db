/*
    To compare passwords in python you can use hashlib as follows
    lambda x: hashlib.sha256(bytes(x, encoding="utf-8")).hexdigest()
    which results in same output.
*/
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
--------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
--------------------------------------------
CREATE TABLE users (
  id SERIAL NOT NULL PRIMARY KEY,
  uuid UUID NOT NULL UNIQUE DEFAULT uuid_generate_v1(),
  lastname VARCHAR(128),
  firstname VARCHAR(128),
  username VARCHAR(64),
  password CHAR(64)
);
--------------------------------------------
-- CREATE A FUNCTION TO HASH PASSWORD ON CREATE AND UPDATE
--------------------------------------------
CREATE
OR REPLACE FUNCTION hash_user_password() RETURNS trigger AS $$ BEGIN IF tg_op = 'INSERT'
OR tg_op = 'UPDATE' THEN NEW.password = encode(digest(NEW.password, 'sha256'), 'hex');
RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;
--------------------------------------------
-- CREATE A TRIGGER TO HASH PASSWORD ON CREATE AND UPDATE
--------------------------------------------
CREATE TRIGGER user_update BEFORE
INSERT
  OR
UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE hash_user_password();