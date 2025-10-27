--3.1
CREATE OR REPLACE PACKAGE employees_pkg AS
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
    );
    
    FUNCTION get_employee_by_id
    (
        p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE
    ) RETURN EMPLOYEES%ROWTYPE;
    
    FUNCTION get_employees_by_dept
    (
        p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE
    ) RETURN SYS_REFCURSOR;
    
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
    );
    
    PROCEDURE delete_employee
    (
      p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE  
    );
    
    --3.1.1
    PROCEDURE top4_employess_with_most_rotations;
    
    --3.1.2
    FUNCTION avg_hirings_by_month
        RETURN NUMBER;
        
    --3.1.3
    PROCEDURE info_regional_level
    (
        p_region_id IN REGIONS.REGION_ID%TYPE
    );
    
    --3.1.4
    FUNCTION get_total_service_cost
        RETURN NUMBER;
    
    --3.1.5   
    FUNCTION total_hours_worked 
    (
        p_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE,
        p_month_num   NUMBER,
        p_year_num    NUMBER
    ) RETURN NUMBER;
    
    --3.1.6
    FUNCTION total_hours_missed
    (
        p_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE,
        p_month_num   NUMBER,
        p_year_num    NUMBER
    ) RETURN NUMBER;
    
    --3.1.7
    PROCEDURE get_employees_salary 
    (
        p_month_num NUMBER,
        p_year_num  NUMBER
    );
    
    --3.1.1
    FUNCTION employees_hours_in_capacitation
        RETURN SYS_REFCURSOR;
    
    --3.1.2
    PROCEDURE get_capacitations_employees_hours;
END employees_pkg;
/

/*Escriba las sentencias para crear las tablas de Horario, Empleado_Horario y 
Asistencia_Empleado. Además de ingresar un conjunto de 10 registros por tabla 
como mínimo.*/
CREATE TABLE Horario 
(
    dia_semana   VARCHAR2(15) NOT NULL,
    turno        VARCHAR2(10) NOT NULL,
    hora_inicio  VARCHAR2(5)  NOT NULL,
    hora_termino VARCHAR2(5)  NOT NULL
);

ALTER TABLE Horario ADD 
(
    CONSTRAINT horario_pk PRIMARY KEY (dia_semana, turno),
    CONSTRAINT horario_dia_chk CHECK (dia_semana IN (
        'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 
        'Domingo')),
    CONSTRAINT horario_turno_chk CHECK (turno IN (
        'Mañana', 'Tarde', 'Noche', 'Completo'))
);

CREATE TABLE Empleado_Horario (
    dia_semana  VARCHAR2(15) NOT NULL,
    turno       VARCHAR2(10) NOT NULL,
    EMPLOYEE_ID NUMBER(6)    NOT NULL
);

ALTER TABLE Empleado_Horario ADD
(
    CONSTRAINT emp_hor_pk PRIMARY KEY (EMPLOYEE_ID, dia_semana, turno),
    CONSTRAINT emphor_hor_fk FOREIGN KEY (dia_semana, turno) 
        REFERENCES Horario(dia_semana, turno),
    CONSTRAINT emphor_empleado_fk FOREIGN KEY (EMPLOYEE_ID) 
        REFERENCES EMPLOYEES(EMPLOYEE_ID)
);

CREATE TABLE Asistencia_Empleado (
    EMPLOYEE_ID       NUMBER(6)    NOT NULL,
    dia_semana        VARCHAR2(15) NOT NULL,
    fecha_real        DATE         NOT NULL,
    hora_inicio_real  TIMESTAMP,
    hora_termino_real TIMESTAMP
);

ALTER TABLE Asistencia_Empleado ADD
(
    CONSTRAINT asistencia_pk PRIMARY KEY (EMPLOYEE_ID, fecha_real),
    CONSTRAINT asistencia_empleado_fk FOREIGN KEY (EMPLOYEE_ID) 
        REFERENCES EMPLOYEES(EMPLOYEE_ID),
    CONSTRAINT assistencia_dia_chk CHECK (dia_semana IN (
        'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 
        'Domingo'))
);

INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Lunes', 'Mañana', '09:00', '17:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Martes', 'Mañana', '09:00', '17:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Miércoles', 'Mañana', '09:00', '17:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Jueves', 'Mañana', '09:00', '17:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Viernes', 'Mañana', '09:00', '17:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Lunes', 'Tarde', '13:00', '21:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Martes', 'Tarde', '13:00', '21:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Miércoles', 'Tarde', '13:00', '21:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Jueves', 'Tarde', '13:00', '21:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Viernes', 'Tarde', '13:00', '21:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Lunes', 'Part-Time', '09:00', '13:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Martes', 'Part-Time', '09:00', '13:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Miércoles', 'Part-Time', '09:00', '13:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Sábado', 'Weekend', '10:00', '16:00');
INSERT INTO Horario (dia_semana, turno, hora_inicio, hora_termino) 
VALUES ('Domingo', 'Weekend', '10:00', '16:00');

INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (100, 'Lunes', 'Mañana');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (100, 'Martes', 'Mañana');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (100, 'Miércoles', 'Mañana');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (100, 'Jueves', 'Mañana');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (100, 'Viernes', 'Mañana');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno)
VALUES (101, 'Lunes', 'Part-Time');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (101, 'Martes', 'Part-Time');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (101, 'Miércoles', 'Part-Time');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (102, 'Sábado', 'Weekend');
INSERT INTO Empleado_Horario (EMPLOYEE_ID, dia_semana, turno) 
VALUES (102, 'Domingo', 'Weekend');

INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (100, 'Lunes', TO_DATE('2025-10-27', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-10-27 09:02:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-10-27 17:01:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (101, 'Lunes', TO_DATE('2025-10-27', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-10-27 09:15:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-10-27 13:00:00', 'YYYY-MM-DD HH24:MI:SS')); 
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (100, 'Martes', TO_DATE('2025-10-28', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-10-28 08:55:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-10-28 16:30:00', 'YYYY-MM-DD HH24:MI:SS')); 
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (100, 'Jueves', TO_DATE('2025-10-30', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-10-30 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-10-30 17:00:00', 'YYYY-MM-DD HH24:MI:SS')); 
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (100, 'Viernes', TO_DATE('2025-10-31', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-10-31 09:05:00', 'YYYY-MM-DD HH24:MI:SS'), 
        NULL);
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (102, 'Sábado', TO_DATE('2025-10-25', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-10-25 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-10-25 16:00:00', 'YYYY-MM-DD HH24:MI:SS')); 
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (102, 'Domingo', TO_DATE('2025-10-26', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-10-26 10:10:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-10-26 16:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (102, 'Sábado', TO_DATE('2025-11-01', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-11-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-11-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Asistencia_Empleado (EMPLOYEE_ID, dia_semana, fecha_real, 
                                 hora_inicio_real, hora_termino_real) 
VALUES (102, 'Domingo', TO_DATE('2025-11-02', 'YYYY-MM-DD'), 
        TO_TIMESTAMP('2025-11-02 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
        TO_TIMESTAMP('2025-11-02 16:00:00', 'YYYY-MM-DD HH24:MI:SS'));

/*Escriba un script que me permita crear las tablas de Capacitacion con las 
columnas (código de capacitación, nombre de la capacitación, horas de 
capacitacion y una descripción de la capacitación) y la tabla 
EmpleadoCapacitacion con las columnas (código de empleado y código de 
capacitación). Además de ingresar un conjunto de 10 registros por tabla.*/
CREATE TABLE Capacitacion (
    codigo_capacitacion      NUMBER(6)     NOT NULL,
    nombre_capacitacion      VARCHAR2(100) NOT NULL,
    horas_capacitacion       NUMBER(3)     NOT NULL,
    descripcion_capacitacion VARCHAR2(500)
);

ALTER TABLE Capacitacion 
    ADD CONSTRAINT capacitacion_pk PRIMARY KEY (codigo_capacitacion);

CREATE TABLE EmpleadoCapacitacion (
    EMPLOYEE_ID         NUMBER(6) NOT NULL,
    codigo_capacitacion NUMBER(6) NOT NULL
);

ALTER TABLE EmpleadoCapacitacion ADD (
    CONSTRAINT empleado_capacitacion_pk PRIMARY KEY (EMPLOYEE_ID, codigo_capacitacion),
    CONSTRAINT empcap_empleado_fk FOREIGN KEY (EMPLOYEE_ID) 
        REFERENCES EMPLOYEES(EMPLOYEE_ID),
    CONSTRAINT empcap_capacitacion_fk FOREIGN KEY (codigo_capacitacion) 
        REFERENCES Capacitacion(codigo_capacitacion)
);

INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1001, 'Introducción a SQL', 16, 'Fundamentos de SQL, SELECT, JOINs.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1002, 'PL/SQL Avanzado', 24, 'Paquetes, Triggers y Colecciones en Oracle.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1003, 'Gestión de Proyectos (PMP)', 40, 'Metodología PMI para la gestión de proyectos.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1004, 'Seguridad Informática Básica', 8, 'Conceptos de ciberseguridad y buenas prácticas.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1005, 'Metodologías Ágiles (Scrum)', 16, 'Introducción a Scrum, roles y artefactos.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1006, 'Liderazgo y Gestión de Equipos', 24, 'Habilidades blandas para managers.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1007, 'Inteligencia de Negocios (BI)', 32, 'Uso de herramientas de BI como PowerBI y Tableau.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1008, 'Excel para Finanzas', 16, 'Funciones financieras avanzadas y tablas dinámicas.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1009, 'Comunicación Efectiva', 8, 'Técnicas de oratoria y presentación.');
INSERT INTO Capacitacion (codigo_capacitacion, nombre_capacitacion, horas_capacitacion, descripcion_capacitacion)
VALUES (1010, 'Oracle Database Administration', 40, 'Administración de bases de datos Oracle.');

INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (100, 1001); 
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (100, 1002); 
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (100, 1005); 
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (101, 1001);
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (101, 1004); 
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (102, 1003); 
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (102, 1009); 
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (103, 1007);
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (103, 1010); 
INSERT INTO EmpleadoCapacitacion (employee_id, codigo_capacitacion) VALUES (104, 1001);