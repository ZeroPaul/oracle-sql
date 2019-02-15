CREATE OR REPLACE PROCEDURE XO_ENTERPRISE (
    number_ruc           IN VARCHAR2,
    name_enterprise      IN VARCHAR2,
    address_enterprise   IN VARCHAR2
) IS

    v_ruc          VARCHAR2(22);
    v_enterprise   VARCHAR2(300);
    v_counter      NUMBER(10);
BEGIN
    SELECT
        COUNT(*)
    INTO v_counter
    FROM
        datos_personales
    WHERE
        ruc = number_ruc;

    v_enterprise := upper(name_enterprise);
    IF v_counter > 0 THEN
        dbms_output.put_line('¡Exist Enterprise!');
        dbms_output.put_line('Alert Data');
    ELSE
        IF length(number_ruc) = 11 THEN
            v_ruc := number_ruc;
            INSERT INTO datos_personales (
                id_personal,
                nombre,
                apepat,
                apemat,
                direcc,
                domloc,
                fono2,
                email,
                ruc,
                estado,
                fecha_ing,
                fallecido,
                ggss,
                baby,
                print_arch,
                reg_pac,
                num_folio,
                direcc_carta,
                uri,
                enviado_ris
            ) VALUES (
                get_newid(9),
                ' ',
                v_enterprise,
                ' ',
                address_enterprise,
                'PE211101',
                '000000000',
                'enterprise@clinicaamericana.org.pe',
                v_ruc,
                '1',
                SYSDATE,
                'N',
                '0',
                '0',
                '0',
                '0',
                '0',
                'Lima',
                '0 ',
                '0'
            );

            COMMIT;
            dbms_output.put_line('Create Enterprise ' || v_enterprise);
            dbms_output.put_line('Success Data');
        ELSE
            dbms_output.put_line('Destroid Enterprise ' || v_enterprise);
            dbms_output.put_line('Error Data');
        END IF;
    END IF;


END xo_enterprise;