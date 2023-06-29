-- drop table departments , employees ;
-- Création des tables avec contraintes d'intégrité
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    CONSTRAINT departments_name_unique UNIQUE (name)
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    department_id INTEGER REFERENCES departments(id) ON DELETE SET NULL,
    CONSTRAINT employees_email_unique UNIQUE (email)
);

-- Créer un index
CREATE INDEX nom_index ON nom_table (colonne);

-- Créer un index sur la table employees
CREATE INDEX idx_employee_lastname ON employees (lastname);

-- Créer un index sur plusieurs colonnes
CREATE INDEX idx_employee_lastname_firstname ON employees (last_name, first_name);


-- Création des vues
CREATE VIEW employee_details AS
SELECT e.id, e.first_name, e.last_name, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.id;

CREATE VIEW recent_employees AS
SELECT *
FROM employees
WHERE hire_date >= CURRENT_DATE - INTERVAL '30 days';


-- Création des procédures stockées
CREATE OR REPLACE FUNCTION get_employee_count() RETURNS INTEGER AS $$
DECLARE
    count INTEGER;
BEGIN
    SELECT COUNT(*) INTO count
    FROM employees;
    RETURN count;
END;
$$ LANGUAGE plpgsql;

-- Création d'une procédure stockée avec paramétre
CREATE OR REPLACE FUNCTION add_numbers(a INTEGER, b INTEGER) RETURNS INTEGER AS $$
DECLARE
    sum INTEGER;
BEGIN
    sum := a + b;
    RETURN sum;
END;
$$ LANGUAGE plpgsql;

--  Création d'une procédure stockée avec paramétre pour mesurer le temps d'execution d'une requete
CREATE OR REPLACE FUNCTION measure_query_execution_time(query_text text) RETURNS void AS $$
DECLARE
    start_time timestamptz;
    end_time timestamptz;
BEGIN
    -- Enregistrer le temps de début
    start_time := clock_timestamp();

    -- Exécuter la requête
    EXECUTE query_text;

    -- Enregistrer le temps de fin
    end_time := clock_timestamp();

    -- Calculer la durée d'exécution
    RAISE NOTICE 'Temps d''exécution : %', end_time - start_time;
END;
$$ LANGUAGE plpgsql;

-- La durée d'exécution est ensuite affichée en utilisant RAISE NOTICE, 
-- mais vous pouvez ajuster la façon dont vous souhaitez traiter cette information, par exemple, 
-- en l'insérant dans une table de journal ou en la renvoyant comme résultat de la procédure.
--
SELECT measure_query_execution_time('SELECT * FROM employees');

-- autre implementation de measure_query_execution_time
DROP FUNCTION measure_query_execution_time(text);
CREATE OR REPLACE FUNCTION measure_query_execution_time(query_text text) RETURNS interval AS $$
DECLARE
    start_time timestamptz;
    end_time timestamptz;
    execution_time interval;
BEGIN
    -- Enregistrer le temps de début
    start_time := clock_timestamp();

    -- Exécuter la requête
    EXECUTE query_text;

    -- Enregistrer le temps de fin
    end_time := clock_timestamp();

    -- Calculer la durée d'exécution
    execution_time := end_time - start_time;

    -- Renvoyer la durée d'exécution
    RETURN execution_time;
END;
$$ LANGUAGE plpgsql;

SELECT measure_query_execution_time('SELECT * FROM employees ');



-- Création des déclencheurs (triggers)
CREATE OR REPLACE FUNCTION update_employee_count() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE departments
        SET employee_count = employee_count + 1
        WHERE id = NEW.department_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE departments
        SET employee_count = employee_count - 1
        WHERE id = OLD.department_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_employee_count_trigger
AFTER INSERT OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION update_employee_count();

-- expiration de temps 
CREATE OR REPLACE FUNCTION delete_after_delay() RETURNS TRIGGER AS $$
BEGIN
    -- Définir la durée de temps en minutes
    -- Dans cet exemple, la durée est de 10 minutes
    -- Vous pouvez ajuster la valeur selon vos besoins
    PERFORM pg_sleep(30); -- 30 secondes
    
    -- Supprimer la ligne de données correspondante
    DELETE FROM employees WHERE id = 'John';
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_trigger AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION delete_after_delay();



-- Jeux de données
INSERT INTO departments (name, location)
VALUES ('HR', 'New York'),
       ('IT', 'San Francisco');

INSERT INTO employees (first_name, last_name, email, hire_date, department_id)
VALUES ('John', 'Doe', 'john.doe@example.com', '2023-01-01', 1),
       ('Jane', 'Smith', 'jane.smith@example.com', '2023-02-15', 2);
	   
-- Appel de la procédure stockée
SELECT get_employee_count();

SELECT add_numbers(5, 10);

-- Utilisation de la procédure stockée dans une requête
SELECT id as department_id, get_employee_count() AS total_employees
FROM departments;

-- Appel de la vue 
select * from employee_details;
-- "id"	"first_name"	"last_name"	"department_name"
--   1	     "John"	          "Doe"	             "HR"
--   2	     "Jane"	        "Smith"	             "IT"

select * from recent_employees ;

select * from employees ;

-- Désactiver un trigger
ALTER TABLE nom_table DISABLE TRIGGER nom_trigger;

-- Réactiver un trigger
ALTER TABLE nom_table ENABLE TRIGGER nom_trigger;


-- Supprimer un trigger sur une table 
DROP TRIGGER nom_trigger ON nom_table;

DROP TRIGGER nom_trigger


-- Récupérer les noms des déclencheurs
SELECT trigger_name, event_object_table
FROM information_schema.triggers;

-- Générer les commandes de suppression
DO $$
DECLARE
    trigger_record RECORD;
BEGIN
    FOR trigger_record IN (
        SELECT trigger_name, event_object_table
        FROM information_schema.triggers
    ) LOOP
        EXECUTE 'DROP TRIGGER ' || trigger_record.trigger_name || ' ON ' || trigger_record.event_object_table || ';';
    END LOOP;
END $$;


-- Supprimer une procédure stockée
DROP FUNCTION nom_procedure([arguments]);


-- Supprimer la procédure stockée get_employee_count
DROP FUNCTION get_employee_count();

-- Supprimer la procédure stockée add_numbers avec des arguments
DROP FUNCTION add_numbers(integer, integer);



