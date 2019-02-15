CREATE OR REPLACE PROCEDURE XO_ADJUST_PEI (
    xdata IN VARCHAR2,
    xdoc IN VARCHAR2
) IS
    l_bi    VARCHAR2(22);
    l_igv   VARCHAR2(22);
BEGIN
--////////////////////// Adjust Price //////////////////////--
    dbms_output.put_line(' ');
    dbms_output.put_line('  _____  __   ____  _____ ___ ');
    dbms_output.put_line(' / _ \ \/ /  |  _ \| ____|_ _|');
    dbms_output.put_line('| | | \  /   | |_) |  _|  | |');
    dbms_output.put_line('| |_| /  \   |  __/| |___ | | ');
    dbms_output.put_line(' \___/_/\_\  |_|   |_____|___|');
    FOR e IN (
        SELECT
            vr.base_imp     bi,
            vr.igv          igvn,
            vrf.igv         igvfe,
            vr.id_mov_vnt   mov_vnt
        FROM
            vent_registro vr
            LEFT JOIN vent_registro_fe vrf ON vrf.id_mov_vnt = vr.id_mov_vnt
        WHERE
            TO_CHAR(vr.fecha,'DDMMYYYY') = xdata
            AND vr.tipo_doc = xdoc
            AND ( vr.igv <> vrf.igv
                  OR vr.base_imp <> vrf.base_imp 
                  OR vr.base_imp <> vrf.valor_afecto
                )
    ) LOOP
        SELECT
            TO_CHAR(e.igvn,'99990d99'),
            TO_CHAR(e.bi,'99990d99')
        INTO
            l_igv,
            l_bi
        FROM
            dual;

        dbms_output.put_line(l_bi
                               || ' - '
                               || e.bi
                               || ' - '
                               || e.igvn
                               || ' - '
                               || e.igvfe
                               || ' - '
                               || e.mov_vnt);

        UPDATE vent_registro_fe
        SET
            valor_afecto = l_bi,
            base_imp = l_bi,
            igv = l_igv
        WHERE
            id_mov_vnt = e.mov_vnt;

        COMMIT;
    END LOOP;

    dbms_output.put_line('Finished adjusting price');
 --////////////////////// Adjust Price //////////////////////--
 
 
 --////////////////////// Adjust Nullified //////////////////////--
    dbms_output.put_line('Started adjusting voided');
    FOR e IN (
        SELECT
            vr.estado       estadou,
            vrf.estado      estadod,
            vr.id_mov_vnt   mov_vnt
        FROM
            vent_registro vr
            LEFT JOIN vent_registro_fe vrf ON vrf.id_mov_vnt = vr.id_mov_vnt
        WHERE
            TO_CHAR(vr.fecha,'DDMMYYYY') = xdata
            AND vr.tipo_doc = xdoc
            AND vr.estado <> vrf.estado
    ) LOOP
        dbms_output.put_line(e.estadou
                               || ' - '
                               || e.estadod
                               || ' - '
                               || e.mov_vnt);

        UPDATE vent_registro_fe
        SET
            estado = 'A'
        WHERE
            id_mov_vnt = e.mov_vnt;

        COMMIT;
    END LOOP;

    dbms_output.put_line('Finished adjusting voided');
--////////////////////// Adjust Nullified //////////////////////--
END xo_adjust_pei;
