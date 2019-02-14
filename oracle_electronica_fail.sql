/*
   _ \                     |       
  |   |   __|  _` |   __|  |   _ \ 
  |   |  |    (   |  (     |   __/ 
 \___/  _|   \__,_| \___| _| \___|
*/

set SERVEROUTPUT ON;
EXECUTE xo_enterprise('99999999999', 'Enterpriser', 'Address');

SELECT
    nombre(id_personal) name,
    id_mov_vnt,
    id_personal_user,
    id_personal,
    '13261205685940012',
    fecha,
    punto,
    ruc,
    serie,
    numdoc
FROM
    vent_registro
WHERE
    serie = 'F031'
    AND numdoc = '77';

SELECT
    *
FROM
    facturas_emitidas
WHERE
    id_mov_vnt = '21627432';

SELECT
    *
FROM
    vent_registro_elec
WHERE
    id_mov_vnt = '21627432';

DELETE FROM
    vent_registro_elec
WHERE
    id_mov_vnt = '21627432';
    
SELECT
    *
FROM
    datos_personales
WHERE
    ruc = '99999999999';

SELECT
    serie||'-'||numdoc, fecha,
    COUNT(serie||'-'||numdoc)
FROM
    vent_registro
WHERE
    TO_CHAR(fecha, 'ddmmyyyy') = '10022019'
GROUP BY
    serie||'-'||numdoc, fecha
HAVING
    COUNT(serie||'-'||numdoc) > 1;

DELETE FROM fe_resumen_bol
WHERE
    TO_CHAR(fecha, 'ddmmyyyy') = '00002019'
    AND ( serie||'-'|| numini ) NOT IN ('');

DELETE FROM doc_enviado_sunat
WHERE
    id = 'RC-20190000-000';

SELECT
    *
FROM
    fe_resumen_bol
WHERE
    TO_CHAR(fecha, 'ddmmyyyy') = '00002019';

DELETE FROM fe_resumen_bol
WHERE
    TO_CHAR(fecha, 'ddmmyyyy') = '00002019';
    
/*
   _ \               |                            |   
  |   |  _ \    __|  __|   _` |   __|  _ \   __|  __| 
  ___/  (   | \__ \  |    (   |  |     __/ \__ \  |   
 _|    \___/  ____/ \__| \__, | _|   \___| ____/ \__| 
                         |___/                       
*/

select * from fact_documentos where serie='F099' and nro_doc='99'; 
select * from fact_trama where id_proceso='F9999';
select * from fact_auditoria where id_proceso='F9999';
select * from fact_pdf where id_proceso='F9999';
select * from fact_envio_doc where id_proceso='F9999';

--Lote
select '''||serie||'',' from fact_det_boletas where id_proceso='RC-00000000-000';


delete from fact_documentos where id_proceso='F9999';
delete from fact_trama where id_proceso='F9999';
