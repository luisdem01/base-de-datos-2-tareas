--1. Ejercicio 1 – Control básico de transacciones
BEGIN
    UPDATE EMPLOYEES
    SET SALARY = SALARY * 1.1
    WHERE DEPARTMENT_ID = 90;
    SAVEPOINT punto1;
    
    UPDATE EMPLOYEES
    SET SALARY = SALARY * 1.05
    WHERE DEPARTMENT_ID = 60;
    
    ROLLBACK TO punto1;
    COMMIT;
END;
/

/*Preguntas:
a. ¿Qué departamento mantuvo los cambios?
    El departamento 90 mantuvo sus cambios.
b. ¿Qué efecto tuvo el ROLLBACK parcial?
    Revirtio todos los cambios posteriores a la creacion del SAVEPOINT punto1.
c. ¿Qué ocurriría si se ejecutara ROLLBACK sin especificar SAVEPOINT? 
    Este desharia todos los cambios del bloque, ya sean las actualizaciones del
    departamento 90 como los del 60.*/

--2. Ejercicio 2 – Bloqueos entre sesiones
--Paso 1: En sesion 1
UPDATE EMPLOYEES
SET SALARY = SALARY + 500
WHERE EMPLOYEE_ID = 103;

--Paso 2: En sesion 2
UPDATE EMPLOYEES
SET SALARY = SALARY + 100
WHERE EMPLOYEE_ID = 103;

--Paso 3: En sesion 1
ROLLBACK;

/*Preguntas:
a. ¿Por qué la segunda sesión quedó bloqueada?
    La sesion 1 ejecutó un UPDATE en la fila con EMPLOYEE_ID = 103 y no terminó
    su transacción, por eso Oracle aplicó un bloqueo en esa fila. La sesion 2
    intento hacer un UPDATE pero tuvo que esperar a que la sesion 1 libere el 
    bloqueo haciendo ROLLBACK.
b. ¿Qué comando libera los bloqueos?
    Los comandos COMMIT y ROLLBACK.
c. ¿Qué vistas del diccionario permiten verificar sesiones bloqueadas?
    Las más comunes son: V$LOCK, V$SESSION y V$LOCKED_OBJECT.*/

--Ejercicio 3 – Transacción controlada con bloque PL/SQL
DECLARE
    v_old_job_id  EMPLOYEES.JOB_ID%TYPE;
    v_old_dept_id EMPLOYEES.DEPARTMENT_ID%TYPE;
    v_hire_date   EMPLOYEES.HIRE_DATE%TYPE;
    v_start_date  DATE;
BEGIN
    SELECT JOB_ID, DEPARTMENT_ID, HIRE_DATE
    INTO v_old_job_id, v_old_dept_id, hire_date
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = 104;
    
    SELECT MAX(END_DATE) + 1
    INTO v_start_date
    FROM JOB_HISTORY
    WHERE EMPLOYEE_ID = 104;
    
    IF v_start_date IS NULL THEN
        v_start_date := v_hire_date;
    END IF;
    
    UPDATE EMPLOYEES
    SET DEPARTMENT_ID = 110
    WHERE EMPLOYEE_ID = 104;
    
    INSERT INTO JOB_HISTORY (EMPLOYEE_ID, START_DATE, END_DATE, JOB_ID, DEPARTMENT_ID)
    VALUES (104, v_start_date, SYSDATE, v_old_job_id, v_old_dept_id);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
/

/*Preguntas:
a. ¿Por qué se debe garantizar la atomicidad entre las dos operaciones?
    Se debe garantizar la atomicidad para mantener consistencia de los datos. Si
    solo la transferencia del empleados es exitosa y el registro de su puesto
    anterior no (o viceversa) entonces la base de datos quedaría inconsistente.
    La atomicidad asegura que se completen ambas transacciones o ninguna.
b. ¿Qué pasaría si se produce un error antes del COMMIT?
    Si hay un error se pasaría a la sección de EXCEPTION, allí el comando
    ROLLBACK revertiría todos los cambios hechos.
c. ¿Cómo se asegura la integridad entre EMPLOYEES y JOB_HISTORY?
    Mediante restricciones, JOB_HISTORY tiene llaves foráneas que apuntan a
    EMPLOYEES y DEPARTMENTS. Esto impide ingresar un registgro con un EMPLOYEE_ID
    o DEPARTMENT_ID inexistentes.*/
    
--Ejercicio 4 – SAVEPOINT y reversión parcial
BEGIN
    UPDATE EMPLOYEES
    SET SALARY = SALARY * 1.08
    WHERE DEPARTMENT_ID = 100;
    SAVEPOINT savepoint_a;
    
    UPDATE EMPLOYEES
    SET SALARY = SALARY * 1.05
    WHERE DEPARTMENT_ID = 80;
    SAVEPOINT savepoint_b;
    
    DELETE FROM EMPLOYEES
    WHERE DEPARTMENT_ID = 50;
    
    ROLLBACK TO savepoint_b;
    COMMIT;
END;
/

/*Preguntas:
a. ¿Qué cambios quedan persistentes?
    Los aumentos de salarios a los empleados de los departamentos 100 y 80.
b. ¿Qué sucede con las filas eliminadas?
    Son revertidas gracias al ROLLBACK al SAVEPOINT B.
c. ¿Cómo puedes verificar los cambios antes y después del COMMIT?
    Mediante una segunda sesión iniciada. Si hacemos un SELECT de las filas
    afectadas por los cambios en la primera sesion antes del COMMIT, no veremos 
    ninguno de los aumentos de salarios ni las elminaciones. Si hacemos un SELECT
    después del COMMIT en la segunda sesión entonces veremos las actualizaciones
    a los salarios de los departamentos 100 y 80.*/