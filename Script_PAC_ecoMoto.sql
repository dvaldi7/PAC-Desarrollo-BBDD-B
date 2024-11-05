DROP TABLE ecoAlquileres;
DROP TABLE ecoClientes;
DROP TABLE ecoMotos;

-- Crear tabla Clientes_eco
CREATE TABLE ecoClientes (
    Dni VARCHAR2(9) PRIMARY KEY,
    Nombre VARCHAR2(50),
    Apellido VARCHAR2(50),
    ecoPuntos NUMBER DEFAULT 0
);

-- Crear tabla Motos_eco
CREATE TABLE ecoMotos (
    Matricula VARCHAR2(10) PRIMARY KEY,
    Modelo VARCHAR2(50),
    PrecioDia NUMBER(10, 2),
    Disponible CHAR(2)DEFAULT 'SI' CHECK (Disponible IN ('SI', 'NO')) 
);

-- Crear tabla Alquileres_eco
CREATE TABLE ecoAlquileres (
    Dni VARCHAR2(20),
    FechaIni DATE,
    Matricula VARCHAR2(10) NOT NULL,
    FechaFin DATE NOT NULL,
    DiasAlquiler NUMBER,
    PrecioAlquiler NUMBER(10, 2) NOT NULL,
    PRIMARY KEY (Dni, FechaIni),
    FOREIGN KEY (Dni) REFERENCES ecoClientes(Dni),
    FOREIGN KEY (Matricula) REFERENCES ecoMotos(Matricula)
);

-- Insertar 10 registros en la tabla ecoClientes
INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('12345678A', 'Juan', 'Pérez');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('87654321B', 'María', 'González');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('11223344C', 'Carlos', 'López');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('33445566D', 'Laura', 'Fernández');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('99887766E', 'Ana', 'Martínez');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('44556677F', 'David', 'Ramírez');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('55667788G', 'Sofía', 'Sánchez');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('66778899H', 'Miguel', 'García');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('77889900I', 'Lucía', 'Morales');

INSERT INTO ecoClientes (Dni, Nombre, Apellido)
VALUES ('88990011J', 'José', 'Ruiz');



-- Insertar 10 registros en la tabla ecoMotos
INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('XYZ123', 'Yamaha MT-07', 50);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('ABC456', 'Honda CBR500R', 60);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('DEF789', 'Kawasaki Z650', 55);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('GHI101', 'Suzuki GSX-S750', 65);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('JKL202', 'Ducati Monster 821', 70);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('MNO303', 'BMW F800R', 75);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('PQR404', 'Harley-Davidson Iron 883', 80);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('STU505', 'Triumph Street Triple', 72);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('VWX606', 'Aprilia Shiver 900', 68);

INSERT INTO ecoMotos (Matricula, Modelo, PrecioDia)
VALUES ('YZA707', 'KTM 790 Duke', 76);


--Crear función categoria_cliente
CREATE OR REPLACE FUNCTION categoria_cliente(p_dni VARCHAR2)
RETURN VARCHAR2 IS
    v_ecoPuntos NUMBER;
    v_categoria VARCHAR2(20);
BEGIN
    -- Obtenemos ecoPuntos del cliente
    SELECT ecoPuntos INTO v_ecoPuntos
    FROM ecoClientes
    WHERE Dni = p_dni;

    -- Categoría del cliente según los ecoPuntos
    IF v_ecoPuntos BETWEEN 0 AND 100 THEN
        v_categoria := 'Eco-Noob';
    ELSIF v_ecoPuntos BETWEEN 101 AND 500 THEN
        v_categoria := 'Eco-Pro';
    ELSIF v_ecoPuntos BETWEEN 501 AND 1000 THEN
        v_categoria := 'Eco-Master';
    ELSE
        v_categoria := 'Eco-God';
    END IF;

    RETURN v_categoria;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'El cliente con dni ' || p_dni || ' no existe');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error inesperado: ' || SQLERRM);
END categoria_cliente;


/*Prueba puntos ecoClientes
UPDATE ecoClientes
SET ecoPuntos = ecoPuntos + 101
WHERE Nombre = 'Laura';

UPDATE ecoClientes
SET ecoPuntos = ecoPuntos + 501
WHERE Nombre = 'María';

UPDATE ecoClientes
SET ecoPuntos = ecoPuntos + 2000
WHERE Nombre = 'Juan';

UPDATE ecoClientes
SET ecoPuntos = ecoPuntos + 101
WHERE Nombre = 'Carlos';
*/
/*Pruebas para ver si suma los puntos correctamente

SELECT * FROM ecoClientes

ALTER FUNCTION categoria_cliente COMPILE;
SHOW ERRORS FUNCTION categoria_cliente;

--Loop para ver si pone las categorías correctamente
SET SERVEROUTPUT ON;

DECLARE
    v_categoria VARCHAR2(20);
BEGIN
    FOR rec IN (SELECT Dni, Nombre, Apellido, ecoPuntos FROM ecoClientes) LOOP
        BEGIN
            v_categoria := categoria_cliente(rec.Dni);
            DBMS_OUTPUT.PUT_LINE('DNI: ' || rec.Dni || ', Nombre: ' 
            || rec.Nombre || ', Apellido: ' || rec.Apellido || ', ecoPuntos: ' 
            || rec.ecoPuntos || ', Categoría: ' || v_categoria);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error al procesar el DNI: ' || rec.Dni ||
                ' - ' || SQLERRM);
        END;
    END LOOP;
END;*/

-- Procedimiento almacenado para registrar alquileres

CREATE OR REPLACE PROCEDURE registrar_alquiler (

  p_dni    IN VARCHAR2,

  p_fechaini IN DATE,

  p_matricula IN VARCHAR2,

  p_fechafin IN DATE

) IS



  v_precio_dia  NUMBER;

  v_dias_alquiler NUMBER;

  v_precio_total NUMBER;

  v_disponible  CHAR(2);

  v_modelo    VARCHAR2(50);

  no_disponible EXCEPTION;

  dias_alquiler EXCEPTION;

BEGIN

  -- Calcular el número de días de alquiler

  v_dias_alquiler := p_fechafin - p_fechaini;



  -- Si el alquiler es menor a 2 días, lanzar excepción

  IF v_dias_alquiler < 2 THEN

    RAISE dias_alquiler;

  END IF;



  -- Verificar si la moto existe y obtener sus datos (precio por día y disponibilidad)

  SELECT    preciodia,    disponible,    modelo

  INTO    v_precio_dia,    v_disponible,    v_modelo

  FROM    ecoMotos

  WHERE    matricula = p_matricula;



    -- Si la moto no está disponible, lanzar excepción

  IF v_disponible = 'NO' THEN

    RAISE no_disponible;

  END IF;



  -- Calcular el precio total del alquiler

  v_precio_total := v_dias_alquiler * v_precio_dia;



  -- Insertar el nuevo alquiler en la tabla ecoAlquileres

  INSERT INTO ecoAlquileres (    dni,    fechaini,    matricula,    fechafin, 
  diasalquiler,    precioalquiler)

VALUES (    p_dni,    p_fechaini,    p_matricula,    p_fechafin,   
v_dias_alquiler,    v_precio_total  );



  DBMS_OUTPUT.PUT_LINE('El Alquiler de la moto '

             || v_modelo

             || ' ha sido registrado correctamente');



EXCEPTION

  WHEN dias_alquiler THEN

    raise_application_error(-20001, 'El Alquiler ha de ser mínimo de 2 días');

  WHEN NO_DATA_FOUND THEN

    raise_application_error(-20002, 'La moto con matricula '

                    || p_matricula

                    || ' no se ha podido encontrar');

  WHEN no_disponible THEN

    raise_application_error(-20003, 'La moto con matricula '

                    || p_matricula

                    || ' y modelo '

                    || v_modelo

                    || ' no está disponible en estos momentos');

  WHEN OTHERS THEN

    raise_application_error(-20004, 'Se ha producido un error inesperado: ' 

                    || sqlerrm);

END registrar_alquiler;

--Trigger actualiza_puntos_disp y mostrar los mensajes de confirmación sobre 
        --los ecoPuntos del cliente y la disponibilidad de la moto.

-- Trigger para actualizar ecoPuntos y disponibilidad

CREATE OR REPLACE TRIGGER actualiza_puntos_disp
AFTER INSERT ON ecoAlquileres
FOR EACH ROW
DECLARE
  v_ecoPuntos NUMBER;
  v_nombre ecoClientes.Nombre%TYPE;
  v_apellido ecoClientes.Apellido%TYPE;
  v_ecopuntos_actuales ecoClientes.ecoPuntos%TYPE;
  v_ecopuntos_suma NUMBER;
BEGIN
  -- Calcular los ecoPuntos obtenidos en este alquiler (1 punto por cada 10 euros)
  v_ecoPuntos := FLOOR(:NEW.PrecioAlquiler / 10);

  -- Obtener el nombre, apellido y ecoPuntos actuales del cliente
  SELECT Nombre, Apellido, ecoPuntos 
  INTO v_nombre, v_apellido, v_ecopuntos_actuales
  FROM ecoClientes
  WHERE Dni = :NEW.Dni;

  -- Sumar los ecoPuntos actuales con los obtenidos en este alquiler
  v_ecopuntos_suma := v_ecopuntos_actuales + v_ecoPuntos;

  -- Actualizar los ecoPuntos del cliente
  UPDATE ecoClientes
  SET ecoPuntos = v_ecopuntos_suma
  WHERE Dni = :NEW.Dni;

  -- Actualizar la moto como no disponible
  UPDATE ecoMotos
  SET Disponible = 'NO'
  WHERE Matricula = :NEW.Matricula;

  -- Mostrar mensaje de confirmación
  DBMS_OUTPUT.PUT_LINE('El cliente con el nombre ' || v_nombre || ' ' || v_apellido || 
                       ' ahora tiene ' || v_ecopuntos_suma || ' ecoPuntos.');

EXCEPTION
  -- Manejo de cualquier error durante la ejecución del trigger
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20001, 'No se pudo completar la actualización de tablas al insertar un nuevo registro de alquiler: ' || SQLERRM);
END actualiza_puntos_disp;

/*--PRUEBAS DEL TRIGGER

-- Habilitar la salida de mensajes en la consola
SET SERVEROUTPUT ON;

-- Bloque anónimo para insertar un nuevo alquiler
BEGIN
  INSERT INTO ecoAlquileres (Dni, FechaIni, Matricula, FechaFin, DiasAlquiler, PrecioAlquiler)
  VALUES ('12345678A', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'XYZ123', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 4, 100);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;


*/

--EJERCICIO DE PRUEBAS (ELEGIR LAS CORRECTAS)


SHOW ERRORS;

EXECUTE registrar_alquiler('77889900I', TO_DATE('2024-11-11', 'YYYY-MM-DD'), 'JKL202', TO_DATE('2024-11-25', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('11223344C', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'DEF789', TO_DATE('2024-11-15', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('33445566D', TO_DATE('2024-11-05', 'YYYY-MM-DD'), 'GHI101', TO_DATE('2024-11-20', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('12345678A', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'XYZ123', TO_DATE('2024-11-05', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('12345678A', TO_DATE('2024-12-01', 'YYYY-MM-DD'), 'STU505', TO_DATE('2024-12-06', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('87654321B', TO_DATE('2024-12-03', 'YYYY-MM-DD'), 'VWX606', TO_DATE('2024-12-08', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('87654321B', TO_DATE('2024-11-03', 'YYYY-MM-DD'), 'YZA707', TO_DATE('2024-11-04', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('87654321B', TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'XYZ123', TO_DATE('2024-11-12', 'YYYY-MM-DD'));

EXECUTE registrar_alquiler('77889900I', TO_DATE('2024-11-11', 'YYYY-MM-DD'), 'PQR404', TO_DATE('2024-11-15', 'YYYY-MM-DD'));

SELECT * FROM ecoCLientes;

SELECT c.Nombre, c.Apellido, a.*
FROM ecoAlquileres a
JOIN ecoClientes c ON a.Dni = c.Dni
WHERE c.Dni = '77889900I';

SELECT Disponible
FROM ecoMotos
WHERE Matricula = 'DEF789';

SELECT *
FROM ecoAlquileres
WHERE PrecioAlquiler = (SELECT MAX(PrecioAlquiler) FROM ecoAlquileres);

SELECT *
FROM ecoAlquileres
WHERE DiasAlquiler = (SELECT MIN(DiasAlquiler) FROM ecoAlquileres);

SELECT *
FROM ecoClientes
WHERE Dni = '12345678A';