/*4.1.1 Obtenga el color y ciudad para las partes que no son de París, con un 
peso mayor de diez.*/
CREATE OR REPLACE PROCEDURE obtener_partes_especificas IS
    CURSOR c_partes_filtradas_cursor IS
        SELECT
            color,
            city
        FROM
            P
        WHERE
            city <> 'Paris'
            AND weight > 10;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Partes no ubicadas en París con peso > 10: ');
    FOR parte_rec IN c_partes_filtradas_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Color: ' || parte_rec.color || ' - Ciudad: ' ||
                             parte_rec.city);
    END LOOP;
END obtener_partes_especificas;
/

/*4.1.2 Para todas las partes, obtenga el número de parte y el peso de dichas 
partes engramos.*/
CREATE OR REPLACE PROCEDURE obtener_num_parte_y_peso_gr IS
    CURSOR num_parte_y_peso_gr_cursor IS
        SELECT 
            P#,
            WEIGHT * 453.592 || ' gr' AS peso_gr
        FROM
            P;
BEGIN
    FOR parte_rec IN num_parte_y_peso_gr_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Numero parte: ' || parte_rec.P# || ' - Peso (gr):
                             ' || parte_rec.peso_gr);
    END LOOP;
END obtener_num_parte_y_peso_gr;
/

--4.1.3 Obtenga el detalle completo de todos los proveedores.
CREATE OR REPLACE PROCEDURE suppliers_details IS
    CURSOR sup_det_cursor IS
        SELECT 
            *
        FROM
            S;
BEGIN
    FOR sup_rec IN sup_det_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Num proveedor: ' || sup_rec.S#
                             || ' - Nombre: ' || sup_rec.SNAME
                             || ' - Status: ' || sup_rec.STATUS
                             || ' - Ciudad: ' || sup_rec.CITY);
    END LOOP;
END suppliers_details;
/

/*4.1.4 Obtenga todas las combinaciones de proveedores y partes para aquellos 
proveedores y partes co-localizados.*/
CREATE OR REPLACE PROCEDURE colocated_supplier_and_parts IS
    CURSOR col_sup_part_cursor IS
        SELECT
            s.S#,
            s.SNAME,
            p.P#,
            p.PNAME
        FROM 
            S s
        JOIN
            P p ON s.CITY = p.CITY;
BEGIN
    FOR sup_rec IN col_sup_part_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Num proveedor: '          || sup_rec.S#
                             || ' - Nombre proveedor: ' || sup_rec.SNAME
                             || ' - Num parte: '        || sup_rec.P#
                             || ' - Nombre parte: '     || sup_rec.PNAME);
    END LOOP;
END colocated_supplier_and_parts;
/

/*4.1.5 Obtenga todos los pares de nombres de ciudades de tal forma que el 
proveedorlocalizado en la primera ciudad del par abastece una parte almacenada 
en la segunda ciudad del par.*/
CREATE OR REPLACE PROCEDURE supplier_part IS
    CURSOR sup_part_cursor IS
        SELECT DISTINCT
            s.CITY AS ciudad_proveedor,
            p.CITY AS ciudad_parte
        FROM 
            S s
        JOIN
            SP sp ON s.S# = sp.S#
        JOIN
            P p ON sp.P# = p.P#;
BEGIN
    FOR sp_rec IN sup_part_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Ciudad proveedor: ' || sp_rec.ciudad_proveedor
                             || 'Ciudad parte: ' || sp_rec.ciudad_parte);
    END LOOP;
END supplier_part;
/

/*4.1.6 Obtenga todos los pares de número de proveedor tales que los dos 
proveedores del par estén co-localizados.*/
CREATE OR REPLACE PROCEDURE colocated_suppliers IS
    CURSOR col_sup_cursor IS
        SELECT DISTINCT
            s1.S# AS prov1,
            s2.S# AS prov2
        FROM
            S s1
        JOIN
            S s2 ON s1.CITY = s2.CITY
        WHERE
            s1.S# < s2.S#;
BEGIN
    FOR sup_rec IN col_sup_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Num proveedor 1: '        || sup_rec.prov1
                             || ' - Num proveedor 2: '  || sup_rec.prov2);
    END LOOP;
END colocated_suppliers;
/

--4.1.7 Obtenga el número total de proveedores.
CREATE OR REPLACE PROCEDURE suppliers_count IS
    v_sup_count NUMBER;
BEGIN
    SELECT COUNT(S#)
    INTO v_sup_count
    FROM S;
    DBMS_OUTPUT.PUT_LINE('Cantidad de proveedores: ' || v_sup_count);
END suppliers_count;
/

--4.1.8 Obtenga la cantidad mínima y la cantidad máxima para la parte P2.
CREATE OR REPLACE PROCEDURE p2_min_max IS
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    SELECT MIN(QTY), MAX(QTY)
    INTO v_min, v_max
    FROM SP
    WHERE P# = 'P2';
    DBMS_OUTPUT.PUT_LINE('Cant minima: ' || v_min
                         || ' - Cant maxima: ' || v_max);
END p2_min_max;
/

/*4.1.9 Para cada parte abastecida, obtenga el número de parte y el total 
despachado.*/
CREATE OR REPLACE PROCEDURE part_num_total IS
    CURSOR part_n_tot_cursor IS
        SELECT 
            P#,
            SUM(QTY) AS suma_total
        FROM 
            SP
        GROUP BY
            P#;
BEGIN
    FOR part_rec IN part_n_tot_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Num parte: ' || part_rec.P#
                             || ' - Cantidad total: ' || part_rec.suma_total);
    END LOOP;
END part_num_total;
/

/*4.1.10 Obtenga el número de parte para todas las partes abastecidas por más de
un proveedor.*/
CREATE OR REPLACE PROCEDURE part_mas_2_sup IS
    CURSOR part_m2_sup_cursor IS
        SELECT
            P#,
            COUNT(DISTINCT S#) AS cant_prov
        FROM
            SP 
        GROUP BY
            P#
        HAVING 
            COUNT(DISTINCT S#) > 1;
BEGIN
    FOR part_rec IN part_m2_sup_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Num parte: ' || parte_rec.P#
                             || '- Cantidad proveedores: ' 
                             || parte_rec.cant_prov);
    END LOOP;
END part_mas_2_sup;
/

/*4.1.11 Obtenga el nombre de proveedor para todos los proveedores que abastecen
la parte P2.*/
CREATE OR REPLACE PROCEDURE suppliers_p2 IS
    CURSOR sup_p2_cursor IS
        SELECT DISTINCT
            s.SNAME
        FROM 
            S s
        JOIN
            SP sp ON s.S# = sp.S#
        WHERE
            sp.P# = 'P2';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen P2');
    FOR sup_rec IN sup_p2_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || sup_rec.SNAME);
    END LOOP;
END suppliers_p2;
/

/*4.1.12 Obtenga el nombre de proveedor de quienes abastecen por lo menos una
parte.*/
CREATE OR REPLACE PROCEDURE suppliers_min_1 IS
    CURSOR sup_min1_cursor IS
        SELECT DISTINCT
            s.SNAME
        FROM
            S s
        JOIN
            SP sp ON s.S# = sp.S#;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen al menos 1 parte');
    FOR sup_rec IN sup_min1_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || sup_rec.SNAME);
    END LOOP;
END suppliers_min_1;
/

/*4.1.13 Obtenga el número de proveedor para los proveedores con estado menor
que el máximo valor de estado en la tabla S.*/
CREATE OR REPLACE PROCEDURE supplier_status_lower_than_max IS
    CURSOR sup_stat_lower_cursor IS
        SELECT 
            S#
        FROM
            S
        WHERE 
            STATUS < (SELECT MAX(STATUS)
                      FROM S);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Numero de proveedores con status menor al maximo');
    FOR sup_rec IN sup_stat_lower_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Numero: ' || sup_rec.S#);
    END LOOP;
END supplier_status_lower_than_max;
/

/*4.1.14 Obtenga el nombre de proveedor para los proveedores que abastecen la
parte P2 (aplicar EXISTS en su solución).*/
CREATE OR REPLACE PROCEDURE suppliers_p2_with_exists
IS
    CURSOR sup_p2_cursor IS
        SELECT
            s.SNAME
        FROM
            S s
        WHERE
            EXISTS (
                SELECT 1 
                FROM SP sp
                WHERE
                    sp.S# = s.S#  
                    AND sp.P# = 'P2'
            );
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen P2');
    FOR sup_rec IN c_p2_suppliers LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || sup_rec.SNAME);
    END LOOP;
END suppliers_p2_with_exists;
/

/*4.1.15 Obtenga el nombre de proveedor para los proveedores que no abastecen la
parte P2.*/
CREATE OR REPLACE PROCEDURE suppliers_not_p2 IS
    CURSOR sup_not_p2_cursor IS
        SELECT DISTINCT
            s.SNAME
        FROM 
            S s
        JOIN
            SP sp ON s.S# = sp.S#
        WHERE
            NOT EXISTS (
                SELECT 1
                FROM SP sp
                WHERE
                    sp.S# = s.S# 
                    AND sp.P# = 'P2'
            );
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que no abastecen P2');
    FOR sup_rec IN sup_not_p2_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || sup_rec.SNAME);
    END LOOP;
END suppliers_not_p2;
/

/*4.1.16 Obtenga el nombre de proveedor para los proveedores que abastecen todas
las partes.*/
CREATE OR REPLACE PROCEDURE supplier_all_parts IS
    CURSOR sup_all_p_cursor IS
        SELECT 
            s.SNAME
        FROM
            S s
        JOIN
            SP sp ON s.S# = sp.S#
        GROUP BY
            s.SNAME
        HAVING
            COUNT(DISTINCT sp.P#) = (SELECT COUNT(DISTINCT P#)
                                     FROM P);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Proveedores que abastecen a todas las partes: ');
    FOR sup_rec IN sup_all_p_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || sup_rec.SNAME);
    END LOOP;
END supplier_all_parts;
/

/*4.1.17 Obtenga el número de parte para todas las partes que pesan más de 16 
libras ó son abastecidas por el proveedor S2, ó cumplen con ambos criterios.*/
CREATE OR REPLACE PROCEDURE parts_more_than_16_or_sup_2 IS
    CURSOR  parts_m16_s2_cursor IS
        SELECT
            p.P#
        FROM
            P p
        WHERE
            p.WEIGHT > 16 
            OR
            EXISTS (
                SELECT 1 
                FROM SP sp
                WHERE
                    sp.P# = p.P#  
                    AND sp.S# = 'S2'
            );
BEGIN
    DBMS_OUTPUT.PUT_LINE('Partes que pesan mas de 16 libras o son abastecidas 
                         por S2');
    FOR part_rec IN parts_m16_s2_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Numero : ' || part_rec.P#);
    END LOOP;
END parts_more_than_16_or_sup_2;
/