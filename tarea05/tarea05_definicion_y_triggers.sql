CREATE OR REPLACE PACKAGE BODY employees_pkg AS
    /*3.1. Escriba el paquete respectivo para el objeto almacenado employee con 
    los procedimientos y funciones CRUD necesarias.*/
    PROCEDURE create_employee
    (
        p_first_name    IN EMPLOYEES.FIRST_NAME%TYPE,
        p_last_name     IN EMPLOYEES.LAST_NAME%TYPE,
        p_email         IN EMPLOYEES.EMAIL%TYPE,
        p_phone_number  IN EMPLOYEES.PHONE_NUMBER%TYPE,
        p_hire_date     IN EMPLOYEES.HIRE_DATE%TYPE,
        p_job_id        IN EMPLOYEES.JOB_ID%TYPE,
        p_salary        IN EMPLOYEES.SALARY%TYPE,
        p_commission_pct IN EMPLOYEES.COMISSION_PCT%TYPE,
        p_manager_id    IN EMPLOYEES.MANAGER_ID%TYPE,
        p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE
    ) IS
    BEGIN 
        INSERT INTO EMPLOYEES 
        (
            FIRST_NAME, LAST_NAME, EMAIL, PHONE_NUMBER, HIRE_DATE, JOB_ID, 
            SALARY, COMMISSION_PCT, MANAGER_ID, DEPARTMENT_ID
        )
        VALUES 
        (
            p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, 
            p_job_id, p_salary, p_commission_pct, p_manager_id, p_department_id
        );
        COMMIT;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error: Ya existe un empleado con ese email');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al crear empleado' || SQLERRM);
            ROLLBACK;
    END create_employee;
    
    FUNCTION get_employee_by_id
    (
        p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE
    ) RETURN EMPLOYEES%ROWTYPE
    IS
        v_employee EMPLOYEES%ROWTYPE;
    BEGIN
        SELECT *
        INTO v_employee
        FROM EMPLOYEES
        WHERE EMPLOYEE_ID = p_employee_id;
        RETURN v_employee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Empleado no encontrado');
            RETURN NULL;
    END get_employee_by_id;
    
    FUNCTION get_employees_by_dept
    (
        p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE
    ) RETURN SYS_REFCURSOR
    IS
        v_employees_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_employees_cursor FOR
            SELECT *
            FROM EMPLOYEES
            WHERE DEPARTMENT_ID = p_department_id;
        RETURN v_employees_cursor;
    END get_employees_by_dept;
    
    PROCEDURE update_employee
    (
        p_employee_id   IN EMPLOYEES.EMPLOYEE_ID%TYPE,
        p_first_name    IN EMPLOYEES.FIRST_NAME%TYPE    DEFAULT NULL,
        p_last_name     IN EMPLOYEES.LAST_NAME%TYPE     DEFAULT NULL,
        p_email         IN EMPLOYEES.EMAIL%TYPE         DEFAULT NULL,
        p_phone_number  IN EMPLOYEES.PHONE_NUMBER%TYPE  DEFAULT NULL,
        p_job_id        IN EMPLOYEES.JOB_ID%TYPE        DEFAULT NULL,
        p_salary        IN EMPLOYEES.SALARY%TYPE        DEFAULT NULL,
        p_commission_pct IN EMPLOYEES.COMISSION_PCT%TYPE DEFAULT NULL,
        p_manager_id    IN EMPLOYEES.MANAGER_ID%TYPE    DEFAULT NULL,
        p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE DEFAULT NULL
    ) IS
    BEGIN
        UPDATE EMPLOYEES
        SET
            FIRST_NAME    = NVL(p_first_name, FIRST_NAME),
            LAST_NAME     = NVL(p_last_name, LAST_NAME),
            EMAIL         = NVL(p_email, EMAIL),
            PHONE_NUMBER  = NVL(p_phone_number, PHONE_NUMBER),
            JOB_ID        = NVL(p_job_id, JOB_ID),
            SALARY        = NVL(p_salary, SALARY),
            COMISSION_PCT = NVL(p_commission_pct, COMMISSION_PCT),
            MANAGER_ID    = NVL(p_manager_id, MANAGER_ID),
            DEPARTMENT_ID = NVL(p_department_id, DEPARTMENT_ID)
        WHERE EMPLOYEE_ID = p_employee_id;
        IF SQL%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Empleado no encontrado');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Empleado ' || p_employee_id || ' actualizado');
            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHER THEN
            DBMS_OUTPUT.PUT_LINE('Error al actualizar empleado' || SQLERRM);
            ROLLBACK;
    END update_employee;
    
    PROCEDURE delete_employee
    (
      p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE  
    )IS
    BEGIN
        DELETE FROM EMPLOYEES
        WHERE EMPLOYEE_ID = p_employee_id;
        IF SQL%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Empleado no encontrado');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Empleado ' || p_employee_id || ' eliminado');
            COMMIT;
        END IF;
        EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al eliminar empleado' || SQLERRM);
            ROLLBACK;
    END delete_employee;
    
    /*3.1.1. Escriba un procedimiento que muestre el código de empleado, 
    apellido y nombre, código de puesto actual y nombre de puesto actual, de los
    4 empleados que más han rotado de puesto desde que ingresaron a la empresa. 
    Para cada uno de ellos presente como columna adicional el número de veces 
    que han cambiado de puesto.*/
    PROCEDURE top4_employess_with_most_rotations  IS
    CURSOR top4_employees_cursor IS
        SELECT
            e.EMPLOYEE_ID, e.LAST_NAME, e.FIRST_NAME, e.JOB_ID, j.JOB_TITLE,
            jh.cantidad_rotaciones
        FROM
            EMPLOYEES e
        JOIN
            JOBS j ON e.JOB_ID = J.JOB_ID
        JOIN
            (SELECT EMPLOYEE_ID, COUNT(JOB_ID) AS cantidad_rotaciones
             FROM JOB_HISTORY
             GROUP BY EMPLOYEE_ID
             ORDER BY COUNT(JOB_ID) DESC
             FETCH FIRST 4 ROWS ONLY
             ) jh ON e.EMPLOYEE_ID = jh.EMPLOYEE_ID
        ORDER BY jh.cantidad_rotaciones DESC;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Empleados con mas rotaciones de puesto');
        FOR emp_rec IN top4_employees_cursor LOOP
            DBMS_OUTPUT.PUT_LINE(
            'Id empleado: ' || emp_rec.EMPLOYEE_ID || 
            ' - Apellido: ' || emp_rec.LAST_NAME ||
            ' - Nombre: ' || emp_rec.FIRST_NAME || 
            ' - Id puesto: ' || emp_rec.JOB_ID ||
            ' - Nombre puesto: ' || emp_rec.JOB_TITLE ||
            ' - Cantidad rotaciones: ' || emp_rec.cantidad_rotaciones);
        END LOOP;
    END top4_employees_with_most_rotations;
    
    /*3.1.2. Escriba una función que muestre un resumen estadístico del número 
    promedio decontrataciones por cada mes con respecto a todos los años que hay
    información en la base de datos. Debe presentar sólo dos columnas: Nombre 
    del Mes y Número Promedio de Contrataciones en ese Mes. Al final debe 
    retornar por el nombre de la función el total de meses considerados en el 
    listado.*/
    FUNCTION avg_hirings_by_month
        RETURN NUMBER
    IS
    CURSOR avg_hirings_cursor IS
        SELECT
            e.mes, AVG(e.cant_contrataciones) AS prom_contrataciones
        FROM
            (SELECT TO_CHAR(HIRE_DATE, 'FMMonth') AS mes,
                    EXTRACT(MONTH FROM HIRE_DATE) AS num_mes,
                    COUNT(EMPLOYEE_ID) AS cant_contrataciones
            FROM EMPLOYEES
            GROUP BY TO_CHAR(HIRE_DATE, 'FMMonth'),
                     EXTRACT(MONTH FROM HIRE_DATE),
                     EXTRACT(YEAR FROM HIRE_DATE)) e
        GROUP BY
            e.num_mes,
            e.mes
        ORDER BY
            e.num_mes;
    v_conteo_meses NUMBER := 0;
    BEGIN
        FOR hirings_rec IN avg_hirings_cursor LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Mes: ' || hirings_rec.mes || ' - Promedio de contrataciones'
                || hirings_rec.prom_contrataciones);
            v_conteo_meses  := v_conteo_meses + 1;
        END LOOP;
    RETURN v_conteo_meses;
    END avg_hirings_by_month;
    
    /*3.1.3. Escriba un procedimiento que muestre la información de gastos en 
    salario y estadística de empleados a nivel regional. Presente el nombre de 
    la región, la suma de salarios, cantidad de empleados, y fecha de ingreso 
    del empleado más antiguo.*/
    PROCEDURE info_regional_level
    (
        p_region_id IN REGIONS.REGION_ID%TYPE
    ) IS
    v_region_name    REGIONS.REGION_NAME%TYPE;
    v_salary_sum     NUMBER(10,2);
    v_employee_count NUMBER;
    v_oldest_hiring  EMPLOYEES.HIRE_DATE%TYPE;
    BEGIN 
        SELECT
            r.REGION_NAME,
            SUM(e.SALARY),
            COUNT(e.EMPLOYEE_ID),
            MIN(e.HIRE_DATE)
        INTO
            v_region_name,
            v_salary_sum,
            v_employee_count,
            v_oldest_hiring
        FROM
            REGIONS r
        LEFT JOIN
            COUNTRIES c ON r.REGION_ID = c.REGION_ID
        LEFT JOIN
            LOCATIONS l ON c.COUNTRY_ID = l.COUNTRY_ID
        LEFT JOIN
            DEPARTMENTS d ON l.LOCATION_ID = d.LOCATION_ID 
        LEFT JOIN
            EMPLOYEES e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
        WHERE
            r.REGION_ID = p_region_id
        GROUP BY
            r.REGION_ID,
            r.REGION_NAME;
        DBMS_OUTPUT.PUT_LINE(
            'Nombre de region: ' || v_region_name ||
            ' - Suma de salarios: ' || v_salary_sum ||
            ' - Cantidad de empleados: ' || v_employee_count ||
            ' - Contratacion mas antigua: ' || 
            TO_CHAR(v_oldest_hiring), 'DD/MM/YY');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: Region no encontrada');
        WHEN OTHER THEN
            DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
    END info_regional_level;
    
    
    /*3.1.4. Escriba una función para que calcule el tiempo de servicio de cada
    uno de sus empleados, para determinar el tiempo de vacaciones que le 
    corresponde a cada empleado. Sabiendo que por un año de trabajo le 
    corresponde un mes de vacaciones de acuerdo con ley. En el nombre de la 
    función retorne el monto total empleado para el tiempo de servicios.*/
    FUNCTION get_total_service_cost 
        RETURN NUMBER
    IS
        CURSOR employees_cursor IS
            SELECT 
                FIRST_NAME || ' ' || LAST_NAME AS full_name, 
                HIRE_DATE,
                SALARY
            FROM 
                EMPLOYEES;
        v_service_years NUMBER;
        v_total_cost NUMBER(11,2) := 0;
    BEGIN
        FOR emp_rec IN employees_cursor LOOP
            v_service_years := FLOOR(MONTHS_BETWEEN(SYSDATE, emp_rec.HIRE_DATE) / 12);
            DBMS_OUTPUT.PUT_LINE(
                'Nombre empleado: ' || emp_rec.full_name ||
                ' - Años de servicio: ' || v_service_years ||
                ' - Meses de vacaciones: ' || v_service_years);
            v_total_cost := v_total_cost + v_service_years * emp_rec.SALARY;
        END LOOP;
        RETURN v_total_cost;
    END get_total_service_cost;
    
    /*3.1.5. Escriba una función que reciba como parámetro el código de un 
    empleado, el número de mes y el número de año. Calcule la cantidad de horas 
    que laboro en dicho mes. Finalmente, retorne la cantidad de horas por el 
    empleado en el nombre de la función.*/
    FUNCTION total_hours_worked 
    (
        p_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE,
        p_month_num   NUMBER,
        p_year_num    NUMBER
    ) RETURN NUMBER 
    IS
        CURSOR employees_cursor IS
            SELECT 
                EMPLOYEE_ID, fecha_real, hora_inicio_real, hora_termino_real
            FROM
                Asistencia_Empleado
            WHERE
                EMPLOYEE_ID = p_employee_id
                AND EXTRACT(MONTH FROM fecha_real) = p_month_num
                AND EXTRACT(YEAR FROM fecha_real) = p_year_num;
        v_interval      INTERVAL DAY TO SECOND;
        v_hours         NUMBER(2);
        v_minutes       NUMBER(2);
        v_decimal_hours NUMBER(5,2);
        v_total_hours   NUMBER(5,2) := 0;
    BEGIN
        FOR emp_rec IN employees_cursor LOOP
            IF (emp_rec.hora_inicio_real IS NOT NULL 
                AND emp_rec.hora_termino_real IS NOT NULL) THEN
            v_interval      := emp_rec.hora_termino_real - emp_rec.hora_inicio_real;
            v_hours         := EXTRACT(HOUR FROM v_interval);
            v_minutes       := EXTRACT(MINUTE FROM v_interval);
            v_decimal_hours := v_hours + (v_minutes / 60);
            v_total_hours   := v_total_hours + v_decimal_hours;
            END IF;
        END LOOP;
        RETURN v_total_hours;
    END total_hours_worked;
    
    
    /*3.1.6. Escriba una función que reciba como parámetro el código de un 
    empleado, el número de mes y el número de año. Calcule la cantidad de horas 
    que falto el empleado enbase a la función anterior. Finalmente, retorne en 
    el nombre de la función la cantidadde horas que falto el empleado.*/
    FUNCTION total_hours_missed
    (
        p_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE,
        p_month_num   NUMBER,
        p_year_num    NUMBER
    ) RETURN NUMBER
    IS
        CURSOR employees_horary_cursor IS
            SELECT 
                eh.EMPLOYEE_ID, eh.dia_semana, h.hora_inicio, h.hora_termino
            FROM
                Empleado_Horario eh
            JOIN
                Horario h ON eh.dia_semana = h.dia_semana AND eh.turno = h.turno
            WHERE
                eh.EMPLOYEE_ID = p_employee_id;
        v_hours_worked    NUMBER(5,2);
        v_actual_day      DATE;
        v_last_day        DATE;
        v_day_hours       NUMBER(4,2);
        v_hours_assigned  NUMBER(5,2) := 0;
        v_hours_missed    NUMBER(5,2);
    BEGIN
        v_hours_worked := total_hours_worked(
            p_employee_id => p_employee_id,
            p_month_num   => p_month_num,
            p_year_num    => p_year_num
        );
        FOR horary_rec IN employees_horary_cursor LOOP
            v_actual_day := TO_DATE(p_year_num || '-' || p_month_num || '-01', 'YYYY-MM-DD');
            v_last_day := LAST_DAY(v_actual_day);
            WHILE v_actual_day <= v_last_day LOOP
                IF TO_CHAR(v_actual_day, 'FMDay') = horary_rec.dia_semana THEN
                    v_day_hours := (TO_NUMBER(SUBSTR(horary_rec.hora_termino, 1, 2)) 
                        - TO_NUMBER(SUBSTR(horary_rec.hora_inicio, 1, 2)))
                        + (TO_NUMBER(SUBSTR(horary_rec.hora_termino, 4, 2)) 
                        - TO_NUMBER(SUBSTR(horary_rec.hora_inicio, 4, 2))) / 60;
                    v_hours_assigned := v_hours_assigned + v_day_hours;
                END IF;
                v_actual_day := v_actual_day + 1;
            END LOOP;
        END LOOP;
        v_hours_missed := v_hours_assigned - v_hours_worked;
        RETURN v_hours_missed;
    END total_hours_missed;
    
    /*3.1.7. Escriba un procedimiento que reciba como parámetro el número del 
    mes y el número de año. Calcule para cada empleado en dicho mes y año el 
    monto de sueldo que le corresponde de acuerdo con las horas laboradas y las 
    horas de falta utilizando las funciones anteriores. Finalmente, realice un 
    reporte en el que se muestre el nombre del empleado, el apellido del 
    empleado, el salario que le corresponde en el mes y año.*/
    PROCEDURE get_employees_salary 
    (
        p_month_num NUMBER,
        p_year_num  NUMBER
    ) IS
        CURSOR employees_salary_cursor IS
            SELECT
                EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY
            FROM
                EMPLOYEES;
        v_hours_worked    NUMBER(5,2);
        v_hours_assigned  NUMBER(5,2);
        v_hours_missed    NUMBER(5,2);
        v_salary_per_hour EMPLOYEES.SALARY%TYPE;
        v_final_salary    EMPLOYEES.SALARY%TYPE;
    BEGIN
        FOR emp_rec IN employees_salary_cursor LOOP
            v_hours_worked := total_hours_worked(
            p_employee_id => emp_rec.EMPLOYEE_ID,
            p_month_num   => p_month_num,
            p_year_num    => p_year_num
            );
            v_hours_missed := total_hours_missed(
            p_employee_id => emp_rec.EMPLOYEE_ID,
            p_month_num   => p_month_num,
            p_year_num    => p_year_num
            );
            v_hours_assigned := v_hours_worked + v_hours_missed;
            IF v_hours_assigned > 0 THEN
                v_salary_per_hour := emp_rec.SALARY / v_hours_assigned;
                v_final_salary := ROUND((v_hours_worked * v_salary_per_hour), 2);
            ELSE
                v_final_salary := 0;
            END IF;
            DBMS_OUTPUT.PUT_LINE(
                'Nombre: ' || emp_rec.FIRST_NAME || 
                ' - Apellido: ' || emp_rec.LAST_NAME ||
                ' - Salario corespondiente: ' || v_final_salary);
        END LOOP;
    END get_employees_salary;
    
    /*3.1.1. Escriba una función que calcule la cantidad de horas totales que 
    tiene cada empleado en las capacitaciones desarrolladas por la empresa.*/
    FUNCTION employees_hours_in_capacitation
        RETURN SYS_REFCURSOR    
    IS
        v_employees_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_employees_cursor FOR
            SELECT e.FIRST_NAME || ' ' || e.LAST_NAME AS nombre_completo, 
                   SUM(c.horas_capacitacion)
            FROM
                EMPLOYEES e
            JOIN
                EmpleadoCapacitacion ec ON e.EMPLOYEE_ID = ec.EMPLOYEE_ID
            JOIN
                Capacitacion c ON ec.codigo_capacitacion = c.codigo_capacitacion
            GROUP BY
                e.EMPLOYEE_ID,
                e.FIRST_NAME || ' ' || e.LAST_NAME;
        RETURN v_employees_cursor;
    END employees_hours_in_capacitation;
    
    /*3.1.2. Elabore un procedimiento que liste todas las capacitaciones 
    desarrolladas por la empresa y muestre los nombres de los empleados junto 
    con la cantidad total de horas que participo cada empleado en las 
    capacitaciones. El orden del listado debe ser por el total de horas de 
    capacitación.*/
    PROCEDURE get_capacitations_employees_hours IS
        CURSOR capacitations_employees_hours_cursor IS
            SELECT
                c.nombre_capacitacion, 
                e.FIRST_NAME || ' ' || e.LAST_NAME AS full_name, 
                emp_hor.capacitation_hours
            FROM
                Capacitacion c
            LEFT JOIN
                EmpleadoCapacitacion ec ON c.codigo_capacitacion = ec.codigo_capacitacion
            LEFT JOIN
                EMPLOYEES e ON ec.EMPLOYEE_ID = e.EMPLOYEE_ID
            LEFT JOIN
                (SELECT e1.EMPLOYEE_ID, 
                        SUM(c1.horas_capacitacion) AS capacitation_hours
                 FROM EMPLOYEES e1
                 JOIN EmpleadoCapacitacion ec1 ON e1.EMPLOYEE_ID = ec1.EMPLOYEE_ID
                 JOIN Capacitacion c1 ON ec1.codigo_capacitacion = c1.codigo_capacitacion
                 GROUP BY e1.EMPLOYEE_ID) emp_hor ON e.EMPLOYEE_ID = emp_hor.EMPLOYEE_ID
            ORDER BY 
                capacitation_hours DESC NULLS LAST;
    BEGIN
        FOR cap_rec IN capacitations_employees_hours_cursor LOOP
            DBMS_OUTPUT.PUT_LINE(
                'Nombre capacitacion: ' || cap_rec.nombre_capacitacion ||
                'Nombre empleado: ' || cap_rec.full_name ||
                'Total de horas (empleado): ' || cap_rec.capacitation_hours);
        END LOOP;
    END get_capacitations_employees_hours;
END employees_pkg;
/

/*3.2. Escriba un trigger que verifique que sea correcto la inserción de la 
asistencia del empleado en la tabla AsistenciaEmpleado. Donde, la fecha tiene 
correspondencia con el día de la semana, la hora de inicio tiene correspondencia 
con la hora de inicio real, la hora de término corresponda con la hora de 
término real del empleado que se está registrando su asistencia.*/
CREATE OR REPLACE TRIGGER attendance_date_check
    BEFORE INSERT ON Asistencia_Empleado
    FOR EACH ROW
DECLARE
    v_day_name VARCHAR2(15);
BEGIN
    v_day_name := TO_CHAR(:NEW.fecha_real, 'FMDay');
    IF :NEW.dia_semana != v_day_name THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Error: El día de la semana (' || :NEW.dia_semana || 
            ') No coincide con el dia real (' || 
            TO_CHAR(:NEW.fecha_real, 'DD/MM/YYYY') || ')');
    END IF;
END;
/

/*3.3. Escriba un trigger que verifique que el sueldo asignado o actualizado a 
un empleado este dentro del rango del mínimo y máximo de acuerdo con el puesto 
asignado a dicho empleado que se puede validar en la tabla Jobs.*/
CREATE OR REPLACE TRIGGER salary_check
    BEFORE INSERT OR UPDATE OF SALARY, JOB_ID ON EMPLOYEES
    FOR EACH ROW
DECLARE
    v_min_salary JOBS.MIN_SALARY%TYPE;
    v_max_salary JOBS.MAX_SALARY%TYPE;
BEGIN
    SELECT MIN_SALARY, MAX_SALARY
    INTO v_min_salary, v_max_salary
    FROM JOBS
    WHERE JOB_ID = :NEW.JOB_ID;
    IF :NEW.SALARY < v_min_salary OR :NEW.SALARY > v_max_salary THEN
        RAISE_APPLICATION_ERRRO(-20001, 
            'Error: El salario ' || :NEW.SALARY || ' esta fuera del rango
            de salarios para el puesto ' || :NEW.JOB_ID);
    END IF;
END;
/

/*3.4. Escriba un trigger que restringa el acceso al registro del ingreso sea 
media hora antes o media hora después de su hora exacta de ingreso y marque 
inasistencia del empleado, sin que el empleado se dé cuenta.*/
CREATE OR REPLACE TRIGGER entry_restriction
    BEFORE INSERT ON Asistencia_Empleado
    FOR EACH ROW
DECLARE
    v_start_hour_str VARCHAR2(5);
    v_start_hour_ts  TIMESTAMP;
    v_inferior_limit TIMESTAMP;
    v_superior_limit TIMESTAMP;
BEGIN
    SELECT h.hora_inicio
    INTO   v_start_hour_str
    FROM   Empleado_Horario eh
    JOIN   Horario h ON eh.dia_semana = h.dia_semana AND eh.turno = h.turno
    WHERE  eh.employee_id = :NEW.employee_id
            AND eh.dia_semana = :NEW.dia_semana;

    v_hora_programada_ts := TO_TIMESTAMP(TO_CHAR(:NEW.fecha_real, 
                                         'YYYY-MM-DD') || ' ' || 
                                         v_start_hour_str, 'YYYY-MM-DD HH24:MI');
    v_inferior_limit := v_start_hour_ts - INTERVAL '30' MINUTE;
    v_superior_limit := v_start_hour_ts + INTERVAL '30' MINUTE;

    IF :NEW.hora_inicio_real < v_inferior_limit OR 
       :NEW.hora_inicio_real > v_superior_limit 
    THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: Marcación fuera de la ventana de 
                                         30 minutos.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;
END;
/