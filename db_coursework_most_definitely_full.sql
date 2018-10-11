CREATE TYPE GENDERS AS ENUM ('male', 'female', 'other');
CREATE TYPE TRANSPORT_TYPE AS ENUM ('land', 'air');

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  name TEXT,
  date_of_birth DATE,
  date_of_death DATE,
  date_of_employment DATE,
  gender GENDERS,
  salary INT,

  CONSTRAINT invalid_death CHECK (date_of_death >= date_of_birth AND date_of_death >= date_of_employment),
  CONSTRAINT invalid_employment CHECK (date_of_employment >= date_of_birth + interval '18 years'),
  CONSTRAINT valid_salary CHECK (salary > 0)
);

CREATE TABLE transport(
  id SERIAL PRIMARY KEY,
  type TRANSPORT_TYPE,
  name TEXT,
  availability BOOLEAN,
  required_access_lvl SMALLINT,

  CONSTRAINT valid_level CHECK (required_access_lvl >= 0 AND required_access_lvl <= 5)
);

CREATE TABLE weaponry(
  id SERIAL PRIMARY KEY,
  name TEXT,
  type TEXT,
  ammo_type TEXT,
  quantity INTEGER,
  required_access_lvl SMALLINT

  CONSTRAINT valid_quantity CHECK (quantity >= 0),
  CONSTRAINT valid_level CHECK (required_access_lvl >= 0 AND required_access_lvl <= 5)
);

CREATE TABLE district_houses (
  id SERIAL PRIMARY KEY,
  shelter_row INTEGER,
  shelter_column INTEGER,
  construction_date DATE,
  UNIQUE (shelter_row, shelter_column)
);

CREATE TABLE prawns (
  id SERIAL PRIMARY KEY,
  house_id INT REFERENCES district_houses (id),
  name TEXT,
  activity_type TEXT,
  date_of_birth DATE,
  date_of_death DATE,
  reason_of_death TEXT,

  CONSTRAINT invalid_death CHECK (date_of_death >= date_of_birth)
);

CREATE TABLE scientist_profiles (
  employee_id INT PRIMARY KEY REFERENCES employees (id),
  supervisor_id INT REFERENCES scientist_profiles (employee_id),
  position TEXT,
  supervising_level SMALLINT,

  CONSTRAINT valid_levels CHECK (supervising_level >= 0 AND supervising_level <= 10)
);

CREATE TABLE security_profiles (
  employee_id INT PRIMARY KEY REFERENCES employees (id),
  supervisor_id INT REFERENCES security_profiles (employee_id),
  transport_id INT REFERENCES transport (id),
  weapon_id INT REFERENCES weaponry (id),
  position TEXT,
  access_level SMALLINT,
  supervising_level SMALLINT,

  CONSTRAINT valid_levels CHECK (access_level >= 0 AND access_level <= 5
                                  AND supervising_level >= 0 AND supervising_level <= 10)
);

CREATE TABLE management_profiles (
  employee_id INT PRIMARY KEY REFERENCES employees (id),
  supervisor_id INT REFERENCES management_profiles (employee_id),
  position TEXT,
  access_level SMALLINT,
  supervising_level SMALLINT,

  CONSTRAINT valid_levels CHECK (access_level >= 0 AND access_level <= 5
                                  AND supervising_level >= 0 AND supervising_level <= 10)
);

CREATE TABLE arms_deals(
  id SERIAL PRIMARY KEY,
  dealer_id INT REFERENCES management_profiles (employee_id),
  date DATE,
  client TEXT,
  earn INT,

  CONSTRAINT valid_earn CHECK (earn > 0)
);

CREATE TABLE experiments (
  id SERIAL PRIMARY KEY,
  examinator_id INT REFERENCES scientist_profiles (employee_id),
  date DATE,
  experiment_name TEXT,
  results TEXT
);

CREATE TABLE weapons_in_arms_deals (
  weapon_id INTEGER NOT NULL REFERENCES weaponry (id),
  deal_id INTEGER NOT NULL REFERENCES arms_deals (id)
);

CREATE TABLE prawns_in_experiments (
  prawn_id INTEGER NOT NULL REFERENCES prawns (id),
  experiment_id INTEGER NOT NULL REFERENCES experiments (id)
);

CREATE FUNCTION check_weapons_before_deal()
  RETURNS TRIGGER AS $$
  DECLARE
    required_access_level SMALLINT;
    employee_access_level SMALLINT;
    deal_id INTEGER;
    weapon_count INTEGER;
    BEGIN
    weapon_count := (SELECT quantity FROM weaponry where id = NEW.weapon_id);
    deal_id := (SELECT id FROM arms_deals WHERE id = NEW.deal_id);
    required_access_level := (SELECT required_access_lvl FROM weaponry WHERE id = NEW.weapon_id);
    employee_access_level := (SELECT access_level FROM management_profiles, arms_deals WHERE
                                (deal_id = arms_deals.id AND
                              arms_deals.dealer_id = management_profiles.employee_id));

    IF employee_access_level < required_access_level THEN
      RAISE EXCEPTION 'Employee''s admission level must be higher to access this weapon.';
    ELSE IF weapon_count = 0 THEN
      RAISE EXCEPTION 'Insufficient quantity of weapons. Try again later.';
      ELSE
        UPDATE weaponry SET quantity = quantity-1 WHERE id = NEW.weapon_id;
      END IF;
    END IF;
  RETURN NEW;
  END;
   $$
LANGUAGE plpgsql;

CREATE FUNCTION check_weapons_before_using()
  RETURNS TRIGGER AS $$
  DECLARE
    required_access_level SMALLINT;
    weapon_count INTEGER;
    BEGIN
    weapon_count := (SELECT quantity FROM weaponry where id = NEW.weapon_id);
    required_access_level := (SELECT required_access_lvl FROM weaponry WHERE id = NEW.weapon_id);
    IF NEW.access_level < required_access_level THEN
      RAISE EXCEPTION 'Employee''s admission level must be higher to access this weapon.';
    ELSE IF weapon_count = 0 THEN
      RAISE EXCEPTION 'Insufficient quantity of weapons. Try again later.';
      ELSE
        UPDATE weaponry SET quantity = quantity-1 WHERE id = NEW.weapon_id;
      END IF;
    END IF;
    RETURN NEW;
  END;
  $$
LANGUAGE plpgsql;

CREATE FUNCTION check_transport_before_using()
  RETURNS TRIGGER AS $$
  DECLARE
    required_access_level SMALLINT;
    transport_availability BOOLEAN;
    BEGIN
    transport_availability := (SELECT availability FROM transport WHERE id = NEW.transport_id);
    required_access_level := (SELECT required_access_lvl FROM transport WHERE id = NEW.transport_id);
    IF NEW.access_level < required_access_level THEN
      RAISE EXCEPTION 'Employee''s admission level must be higher to access this transport.';
    ELSE IF (transport_availability = FALSE) THEN
      RAISE EXCEPTION 'This transport is not available right now. Try again later.';
      ELSE
        UPDATE transport SET availability = FALSE WHERE id = NEW.transport_id;
      END IF;
    END IF;
    RETURN NEW;
  END;
  $$
LANGUAGE plpgsql;

CREATE FUNCTION check_examinator_death_and_enlistment()
  RETURNS TRIGGER AS $$
  DECLARE
    examinator_enlistment date;
    examinator_death date;
    BEGIN
    examinator_enlistment := (SELECT date_of_employment FROM employees WHERE id = NEW.examinator_id);
    examinator_death := (SELECT date_of_death FROM employees WHERE id = NEW.examinator_id);
    IF NEW.date > examinator_death THEN
      RAISE EXCEPTION 'Scientist is already dead by the time of the experiment.';
      ELSE IF NEW.date < examinator_enlistment THEN
        RAISE EXCEPTION 'Scientist has not been enlisted yet by the time of the experiment.';
      END IF;
    END IF;
    RETURN NEW;
  END;
  $$
LANGUAGE plpgsql;

CREATE FUNCTION check_dealer_death_and_enlistment()
  RETURNS TRIGGER AS $$
  DECLARE
    dealer_enlistment date;
    dealer_death date;
    BEGIN
    dealer_enlistment := (SELECT date_of_employment FROM employees WHERE id = NEW.dealer_id);
    dealer_death := (SELECT date_of_death FROM employees WHERE id = NEW.dealer_id);
    IF NEW.date > dealer_death THEN
      RAISE EXCEPTION 'Employee is already dead by the time of the deal.';
      ELSE IF NEW.date < dealer_enlistment THEN
        RAISE EXCEPTION 'Employee has not been enlisted yet by the time of the deal.';
      END IF;
    END IF;
    RETURN NEW;
  END;
  $$
LANGUAGE plpgsql;

CREATE FUNCTION check_for_supervising_validity()
  RETURNS TRIGGER AS $$
  DECLARE
    supervisor_id_old INTEGER;
    supervisor_level SMALLINT;
    table_name TEXT;
    BEGIN
    table_name = quote_ident(tg_table_name);
    IF table_name = 'security_profiles' THEN
      supervisor_id_old := (SELECT supervisor_id FROM security_profiles WHERE employee_id = NEW.supervisor_id);
      supervisor_level := (SELECT supervising_level FROM security_profiles where employee_id = NEW.supervisor_id);

    ELSIF table_name = 'scientist_profiles' THEN
      supervisor_id_old := (SELECT supervisor_id FROM scientist_profiles WHERE employee_id = NEW.supervisor_id);
      supervisor_level := (SELECT supervising_level FROM scientist_profiles where employee_id = NEW.supervisor_id);

    ELSIF table_name = 'management_profiles' THEN
      supervisor_id_old := (SELECT supervisor_id FROM management_profiles WHERE employee_id = NEW.supervisor_id);
      supervisor_level := (SELECT supervising_level FROM management_profiles where employee_id = NEW.supervisor_id);

    END IF;

    IF supervisor_id_old = NEW.employee_id THEN
      RAISE EXCEPTION 'Employees cannot supervise each other.';
    ELSE IF supervisor_level <= NEW.supervising_level THEN
        RAISE EXCEPTION 'Supposed supervisor''s level is not sufficient.';
      END IF;
    END IF;
    RETURN NEW;
  END;
  $$
LANGUAGE plpgsql;


CREATE FUNCTION return_weapon_after_using()
  RETURNS TRIGGER AS $$
    BEGIN
    IF tg_op = 'UPDATE' THEN
      IF (NEW.weapon_id IS NULL AND OLD.weapon_id IS NOT NULL) OR (NEW.weapon_id <> OLD.weapon_id) THEN
        UPDATE weaponry SET quantity = quantity+1 WHERE id = OLD.weapon_id;
      END IF;
      RETURN NEW;
    ELSIF tg_op = 'DELETE' THEN
      IF (OLD.weapon_id IS NOT NULL) THEN
        UPDATE weaponry SET quantity = quantity+1 WHERE id = OLD.weapon_id;
      END IF;
      RETURN old;
    END IF;
  END;
  $$
LANGUAGE plpgsql;

CREATE FUNCTION return_transport_after_using()
  RETURNS TRIGGER AS $$
    BEGIN
    IF tg_op = 'UPDATE' THEN
     IF (NEW.transport_id IS NULL AND OLD.transport_id IS NOT NULL) OR (NEW.transport_id <> OLD.transport_id) THEN
        UPDATE transport SET availability = TRUE WHERE id = OLD.transport_id;
      END IF;
      RETURN NEW;
    ELSIF tg_op = 'DELETE' THEN
      IF (OLD.transport_id IS NOT NULL) THEN
        UPDATE transport SET availability = TRUE WHERE id = OLD.transport_id;
      END IF;
      RETURN old;
    END IF;

  END;
  $$
LANGUAGE plpgsql;


CREATE TRIGGER ability_to_deal_weapons
  BEFORE INSERT
  ON weapons_in_arms_deals
  FOR EACH ROW EXECUTE PROCEDURE check_weapons_before_deal();

CREATE TRIGGER ability_to_use_weapons
  BEFORE INSERT OR UPDATE
  ON security_profiles
  FOR EACH ROW EXECUTE PROCEDURE check_weapons_before_using();

CREATE TRIGGER ability_to_use_transport
  BEFORE INSERT OR UPDATE
  ON security_profiles
  FOR EACH ROW EXECUTE PROCEDURE check_transport_before_using();

CREATE TRIGGER validity_of_experiment
  BEFORE INSERT
  ON experiments
  FOR EACH ROW EXECUTE PROCEDURE check_examinator_death_and_enlistment();

CREATE TRIGGER validity_of_deal
  BEFORE INSERT
  ON arms_deals
  FOR EACH ROW EXECUTE PROCEDURE check_dealer_death_and_enlistment();

CREATE TRIGGER security_supervising
  BEFORE INSERT OR UPDATE
  ON security_profiles
  FOR EACH ROW EXECUTE PROCEDURE check_for_supervising_validity();

CREATE TRIGGER scientist_supervising
  BEFORE INSERT OR UPDATE
  ON scientist_profiles
  FOR EACH ROW EXECUTE PROCEDURE check_for_supervising_validity();

CREATE TRIGGER management_supervising
  BEFORE INSERT OR UPDATE
  ON management_profiles
  FOR EACH ROW EXECUTE PROCEDURE check_for_supervising_validity();

CREATE TRIGGER weapon_return
  BEFORE UPDATE OR DELETE
  ON security_profiles
  FOR EACH ROW EXECUTE PROCEDURE return_weapon_after_using();

CREATE TRIGGER transport_return
  BEFORE UPDATE OR DELETE
  ON security_profiles
  FOR EACH ROW EXECUTE PROCEDURE return_transport_after_using();


CREATE INDEX employee_birth ON employees USING BTREE (date_of_birth);
CREATE INDEX employee_death ON employees USING BTREE (date_of_death);
CREATE INDEX employee_enlist ON employees USING BTREE (date_of_employment);

CREATE INDEX fk_house_id ON prawns USING BTREE (house_id);
CREATE INDEX prawn_birth ON prawns USING BTREE (date_of_birth);
CREATE INDEX prawn_death ON prawns USING BTREE (date_of_death);

CREATE INDEX fk_prawn_in_experiment_id ON prawns_in_experiments USING BTREE (prawn_id);
CREATE INDEX fk_prawn_experiment_id ON prawns_in_experiments USING BTREE (experiment_id);

CREATE INDEX fk_weapon_in_deal_id ON weapons_in_arms_deals USING BTREE (weapon_id);
CREATE INDEX fk_weapon_deal_id ON weapons_in_arms_deals USING BTREE (deal_id);

CREATE INDEX fk_examinator_id ON experiments USING BTREE (examinator_id);
CREATE INDEX experiment_date ON experiments USING BTREE (date);

CREATE INDEX fk_dealer_id ON arms_deals USING BTREE (dealer_id);
CREATE INDEX deal_date ON arms_deals USING BTREE (date);

CREATE INDEX fk_sci_employee_id ON scientist_profiles USING BTREE (employee_id);
CREATE INDEX fk_sec_employee_id ON security_profiles USING BTREE (employee_id);
CREATE INDEX fk_man_employee_id ON management_profiles USING BTREE (employee_id);

CREATE INDEX fk_sci_supervisor_id ON scientist_profiles USING BTREE (supervisor_id);
CREATE INDEX fk_sec_supervisor_id ON security_profiles USING BTREE (supervisor_id);
CREATE INDEX fk_man_supervisor_id ON management_profiles USING BTREE (supervisor_id);

CREATE INDEX fk_transport_id ON security_profiles USING BTREE (transport_id);
CREATE INDEX fk_weapon_id ON security_profiles USING BTREE (weapon_id);

CREATE INDEX tra_access_lvl ON transport USING BTREE (required_access_lvl);
CREATE INDEX wea_access_lvl ON weaponry USING BTREE (required_access_lvl);
