/*
   _ \                     |       
  |   |   __|  _` |   __|  |   _ \ 
  |   |  |    (   |  (     |   __/ 
 \___/  _|   \__,_| \___| _| \___|
*/

set SERVEROUTPUT ON;
EXECUTE xo_enterprise('Enterprise', 99999999999);

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


delete from fact_documentos where id_proceso='F9999';
delete from fact_trama where id_proceso='F9999';