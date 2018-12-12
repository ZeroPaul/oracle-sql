CREATE OR REPLACE FUNCTION xo_account_entry (
    date_sale    IN VARCHAR2,
    id_account   IN VARCHAR2,
    id_user      IN VARCHAR2
) RETURN VARCHAR2 IS

    tipo_pago          vent_registro.modo%TYPE;
    tipo_ingr          vent_registro.tipo_ope%TYPE;
    codi_paci          vent_registro.id_personal%TYPE;
    tipo_paci          vent_registro.tipo_pac%TYPE;
    tipo_hono          vent_regdet.pago_hono%TYPE;
    codi_serv          vent_regdet.id_articulo%TYPE;
    impo_igv           vent_registro.igv%TYPE;
    impo_desc          vent_regdet.descuento%TYPE;
    impo_cobe          vent_regdet.cobertura%TYPE;
    impo_serv          vent_regdet.total%TYPE;
    cent_cost          vent_regdet.centro_costo%TYPE;
    nume_plan          datos_afiliados.id_plan%TYPE;
    codi_cuen          asient.codpla%TYPE;
    cta_cte            asient.ctacte%TYPE;
    impo_cta           asient.import%TYPE;
    concepto           asient.concep%TYPE;
    admi_cent          eco_pr.admcdc%TYPE;
    gara_cent          eco_pr.garcdc%TYPE;
    igv_cuen           eco_pr.igvcta%TYPE;
    part_cuen          eco_pr.parcta%TYPE;
    prep_cuen          eco_pr.precta%TYPE;
    segu_cuen          eco_pr.segcta%TYPE;
    trad_cuen          eco_pr.tracta%TYPE;
    desc_cuen          eco_pr.descta%TYPE;
    desc_ctc           eco_pr.desctc%TYPE;
    desc_cent          VARCHAR2(20);
    cob_cuen           eco_pr.cobcta%TYPE;
    cob_ctc            eco_pr.cobctc%TYPE;
    cob_cent           VARCHAR2(20);
    caj_cuen           eco_pr.cajcta%TYPE;
    caj_ctc            eco_pr.cajctc%TYPE;
    dev_cuen           eco_pr.devcta%TYPE;
    amb_cuen           eco_pr.ambcta%TYPE;
    hos_cuen           eco_pr.hoscta%TYPE;
    cop_ctc            eco_pr.copctc%TYPE;
    tipo_plan          cred_planes.tipo_plan%TYPE;
    nume_fila          NUMBER;
    codi_ctct          VARCHAR2(20);
    nom_tippac         tipo_pac.nombre%TYPE;
    nom_art            patron.nombre%TYPE;
    nom_med            VARCHAR2(80);
    nom_niv            nivel.nombre%TYPE;
    nom_plan           cred_planes.nombre%TYPE;
    punto              vent_registro.punto%TYPE;
    concep             VARCHAR2(100);
    concep_desc        VARCHAR2(100);
    concep_cob         VARCHAR2(100);
    contador           NUMBER;
    cont               NUMBER;
    v_cuen             VARCHAR2(1);
    v_id_mov_vnt       VARCHAR2(20);
    v_id_personal      VARCHAR2(20);
    v_caja             VARCHAR2(5);
    v_id_medico_ser    VARCHAR2(20);
    v_id_medico_hono   VARCHAR2(20);
    v_cc_punto         VARCHAR2(5);
    v_id_mov_doc       VARCHAR2(20);
    v_documento        VARCHAR2(200);
    v_tipo_cta         VARCHAR2(1);
    v_tipctc           VARCHAR2(1);
    
    /*
    Ventas
    */
    CURSOR ventas IS 
                    
                    /* PAR Emergencia / Farmacia(examenes de laboratorio y medicamentos)*/ SELECT
                         b.id_mov_vnt,
                         c.id_movart,
                         b.modo,
                         b.tipo_ope,
                         b.id_personal,
                         b.tipo_pac,
                         DECODE(e.tipo_pac,'5','PAR',upper(e.nombre) ) nom_tippac,
                         c.pago_hono,
                         c.id_articulo,
                         replace(b.punto,'04','32') punto,
                         articulo(c.id_articulo) nom_articulo,
                         c.id_medico_ser,
                         b.id_medico_hono,
                         DECODE(b.tipo_doc,'02','RH-'
                                                  || b.serie
                                                  || '-'
                                                  || b.numdoc
                                                  || ' '
                                                  || nombre(b.id_personal),nombre(c.id_medico_ser) ) nom_med,
                         nombre_nivel(substr(d.id_nivel,1,2) ) nom_niv,
                         nvl(plan(b.id_plan),' ') nom_plan,
                         CASE
                             WHEN regven(b.tipo_doc) = '1' THEN ( nvl(c.descuento,0) + nvl(c.descuento_esp,0) )
                             ELSE 0
                         END descuento,
                         CASE
                             WHEN regven(b.tipo_doc) = '1' THEN nvl(c.cobertura,0)
                             ELSE 0
                         END cobertura,
                         c.igv,
                         CASE
                             WHEN regven(b.tipo_doc) = '1' THEN ( c.valor_venta - nvl(c.ret_hono,0) ) * ( factor_tipo_ope(b.tipo_ope
                             ) )
                             ELSE c.total * ( factor_tipo_ope(b.tipo_ope) )
                         END total,
                         centro_costo(c.id_articulo) cent_cost
                     FROM
                         vent_registro b,
                         vent_regdet c,
                         patron d,
                         tipo_pac e
                     WHERE
                         b.id_mov_vnt = c.id_mov_vnt
                         AND c.id_articulo = d.id_servicio
                         AND b.tipo_pac = e.tipo_pac
                         AND trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD')
                         AND b.modo = '1'
                         AND b.estado = 'V'
                         AND b.tipo_ope IN (
                             '1',
                             '2',
                             '8'
                         )
                         AND b.tipo_doc IN (
                             SELECT
                                 tipo_doc
                             FROM
                                 cont_tipo_doc
                             WHERE
                                 ventas = '1'
                                 AND tipo_doc NOT IN (
                                     '04',
                                     '80'
                                 )
                         )
                         AND replace(b.punto,'04','32') IN (
                             SELECT DISTINCT
                                 DECODE(punto,'04','32',punto) punto
                             FROM
                                 puntos
                             WHERE
                                 tipo = 'C'
                                 AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                 AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                         )
                     UNION ALL
                     /* Emergencia(pacientes)*/
                     SELECT
                         b.id_mov_vnt,
                         ' ' id_movart,
                         b.modo,
                         b.tipo_ope,
                         b.id_personal,
                         b.tipo_pac,
                         DECODE(e.tipo_pac,'5','PAR',upper(e.nombre) ) nom_tippac,
                         '0' pago_hono,
                         '' id_articulo,
                         replace(b.punto,'04','32') punto,
                         '' nom_articulo,
                         '' id_medico_ser,
                         b.id_medico_hono   id_medico_hono,
                         nombre(b.id_personal) nom_med,
                         '' nom_niv,
                         nvl(plan(b.id_plan),' ') nom_plan,
                         CASE
                             WHEN regven(b.tipo_doc) = '1' THEN ( nvl(b.descuento,0) + nvl(b.descuento_esp,0) )
                             ELSE 0
                         END descuento,
                         CASE
                             WHEN regven(b.tipo_doc) = '1' THEN nvl(b.cobertura,0)
                             ELSE 0
                         END cobertura,
                         b.igv,
                         CASE
                             WHEN regven(b.tipo_doc) = '1' THEN ( b.valor_venta - nvl(b.ret_hono,0) ) * ( factor_tipo_ope(b.tipo_ope
                             ) )
                             ELSE b.total * factor_tipo_ope(b.tipo_ope)
                         END total,
                         'X' cent_cost
                     FROM
                         vent_registro b,
                         tipo_pac e
                     WHERE
                         b.tipo_pac = e.tipo_pac
                         AND trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD')
                         AND b.modo = '1'
                         AND b.estado = 'V'
                         AND b.tipo_ope IN (
                             '2',
                             '5',
                             '6',
                             '7',
                             '9',
                             '10'
                         )
                         AND b.tipo_doc NOT IN (
                             '02',
                             '23',
                             '24'
                         )
                         AND b.tipo_doc IN (
                             SELECT
                                 tipo_doc
                             FROM
                                 cont_tipo_doc
                             WHERE
                                 ventas = '1'
                                 AND tipo_doc NOT IN (
                                     '04',
                                     '80'
                                 )
                         )
                         AND replace(b.punto,'04','32') IN (
                             SELECT DISTINCT
                                 DECODE(punto,'04','32',punto) punto
                             FROM
                                 puntos
                             WHERE
                                 tipo = 'C'
                                 AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                 AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                         )
                     UNION ALL
                     /*CIA Emergencia / Farmacia(examenes de laboratorio y medicamentos)*/
                     SELECT DISTINCT
                         e.id_mov_vnt,
                         c.id_movart,
                         e.modo,
                         e.tipo_ope,
                         e.id_personal,
                         e.tipo_pac,
                         DECODE(e.tipo_pac,'5','PAR',upper(f.nombre) ) nom_tippac,
                         c.pago_hono,
                         c.id_articulo,
                         replace(e.punto,'04','32') punto,
                         articulo(c.id_articulo) nom_articulo,
                         c.id_medico_ser,
                         ' ' id_medico_hono,
                         nombre(c.id_medico_ser) nom_med,
                         nomb_cencos(d.id_nivel) nom_niv,
                         nvl(plan(e.id_plan),' ') nom_plan,
                         0 descuento,
                         0 cobertura,
                         0 igv,
                         ( round( (round( (c.copago / CASE
                             WHEN ox_copago_sale(e.id_mov_vnt) = 'S' THEN 1
                             ELSE 1.18
                         END),2) * 100) / ( (round( (nvl(b.copago,0) / CASE
                             WHEN ox_copago_sale(e.id_mov_vnt) = 'S' THEN 1
                             ELSE 1.18
                         END),2) * 100) / nvl(e.base_imp,0) ),2) ) * ( factor_tipo_ope(e.tipo_ope) ) total,
                         centro_costo(c.id_articulo) cent_cost
                     FROM
                         (
                             SELECT
                                 a.id_mov_vnt,
                                 a.copago,
                                 b.base_imp,
                                 ( a.copago - b.base_imp ) dif
                             FROM
                                 (
                                     SELECT
                                         id_mov_vnt,
                                         round(SUM(copago / CASE
                                             WHEN ox_copago_sale(id_mov_vnt) = 'S' THEN 1
                                             ELSE 1.18
                                         END),2) copago
                                     FROM
                                         vent_registro
                                     WHERE
                                         modo = '2'
                                         AND estado = 'V'
                                         AND id_mov_vnt IN (
                                             SELECT
                                                 id_vnt_ref
                                             FROM
                                                 vent_registro
                                             WHERE
                                                 TO_CHAR(fecha,'yyyymmdd') = date_sale
                                                 AND estado = 'V'
                                                 AND modo = '1'
                                                 AND tipo_ope IN (
                                                     '3',
                                                     '4'
                                                 )
                                                 AND replace(punto,'04','32') IN (
                                                     SELECT DISTINCT
                                                         DECODE(punto,'04','32',punto) punto
                                                     FROM
                                                         puntos
                                                     WHERE
                                                         tipo = 'C'
                                                         AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                                         AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                                                 )
                                         )
                                     GROUP BY
                                         id_mov_vnt
                                 ) a,
                                 (
                                     SELECT
                                         id_vnt_ref,
                                         base_imp
                                     FROM
                                         vent_registro
                                     WHERE
                                         id_vnt_ref IN (
                                             SELECT
                                                 id_vnt_ref
                                             FROM
                                                 vent_registro
                                             WHERE
                                                 trunc(fecha) = TO_DATE(date_sale,'YYYYMMDD')
                                                 AND estado = 'V'
                                                 AND modo = '1'
                                                 AND tipo_ope IN (
                                                     '3',
                                                     '4'
                                                 )
                                                 AND replace(punto,'04','32') IN (
                                                     SELECT DISTINCT
                                                         DECODE(punto,'04','32',punto) punto
                                                     FROM
                                                         puntos
                                                     WHERE
                                                         tipo = 'C'
                                                         AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                                         AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                                                 )
                                         )
                                 ) b
                             WHERE
                                 a.id_mov_vnt = b.id_vnt_ref
                                 AND a.copago = b.base_imp
                         ) a,
                         vent_registro b,
                         vent_regdet c,
                         patron d,
                         vent_registro e,
                         tipo_pac f
                     WHERE
                         a.id_mov_vnt = b.id_mov_vnt
                         AND b.id_mov_vnt = c.id_mov_vnt
                         AND c.id_articulo = d.id_servicio
                         AND b.id_mov_vnt = e.id_vnt_ref
                         AND e.tipo_pac = f.tipo_pac
                         AND e.estado = 'V'
                     UNION ALL
                     /*Hospitalizacion ()*/
                     SELECT
                         b.id_mov_vnt,
                         ' ' id_movart,
                         b.modo,
                         b.tipo_ope,
                         b.id_personal,
                         b.tipo_pac,
                         DECODE(b.tipo_pac,'5','PAR',upper(c.nombre) ) nom_tippac,
                         '0' pago_hono,
                         '' id_articulo,
                         replace(b.punto,'04','32') punto,
                         '' nom_articulo,
                         '' id_medico_ser,
                         '' id_medico_hono,
                         '' nom_med,
                         'HOSPITALIZACION' nom_niv,
                         nvl(plan(b.id_plan),' ') nom_plan,
                         0 descuento,
                         0 cobertura,
                         0 igv,
                         ( b.base_imp ) * ( factor_tipo_ope(b.tipo_ope) ) total,
                         '31101' cent_cost
                     FROM
                         (
                             SELECT
                                 a.id_mov_vnt,
                                 a.copago,
                                 b.base_imp,
                                 ( a.copago - b.base_imp ) dif
                             FROM
                                 (
                                     SELECT
                                         id_mov_vnt,
                                         round(SUM(copago / CASE
                                             WHEN ox_copago_sale(id_mov_vnt) = 'S' THEN 1
                                             ELSE 1.18
                                         END),2) copago
                                     FROM
                                         vent_registro
                                     WHERE
                                         modo = '2'
                                         AND estado = 'V'
                                         AND id_mov_vnt IN (
                                             SELECT
                                                 id_vnt_ref
                                             FROM
                                                 vent_registro
                                             WHERE --TO_CHAR(FECHA,'yyyymmdd') = date_sale
                                                 trunc(fecha) = TO_DATE(date_sale,'YYYYMMDD')
                                                 AND estado = 'V'
                                                 AND modo = '1'
                                                 AND tipo_ope IN (
                                                     '3',
                                                     '4'
                                                 )
                                                 AND replace(punto,'04','32') IN (
                                                     SELECT DISTINCT
                                                         DECODE(punto,'04','32',punto) punto
                                                     FROM
                                                         puntos
                                                     WHERE
                                                         tipo = 'C'
                                                         AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                                         AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                                                 )
                                         )
                                     GROUP BY
                                         id_mov_vnt
                                 ) a,
                                 (
                                     SELECT
                                         id_vnt_ref,
                                         base_imp
                                     FROM
                                         vent_registro
                                     WHERE
                                         id_vnt_ref IN (
                                             SELECT
                                                 id_vnt_ref
                                             FROM
                                                 vent_registro
                                             WHERE
                                                 trunc(fecha) = TO_DATE(date_sale,'YYYYMMDD')
                                                 AND estado = 'V'
                                                 AND modo = '1'
                                                 AND tipo_ope IN (
                                                     '3',
                                                     '4'
                                                 )
                                                 AND replace(punto,'04','32') IN (
                                                     SELECT DISTINCT
                                                         DECODE(punto,'04','32',punto) punto
                                                     FROM
                                                         puntos
                                                     WHERE
                                                         tipo = 'C'
                                                         AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                                         AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                                                 )
                                         )
                                 ) b
                             WHERE
                                 a.id_mov_vnt = b.id_vnt_ref
                                 AND a.copago IS NULL
                                 AND b.base_imp > 0
                         ) a,
                         vent_registro b,
                         tipo_pac c
                     WHERE
                         a.id_mov_vnt = b.id_vnt_ref
                         AND b.tipo_pac = c.tipo_pac
                         AND nvl(b.base_imp,0) > 0
                     UNION ALL
                     /*Hospitalizacion ()*/
                     SELECT
                         b.id_mov_vnt,
                         ' ' id_movart,
                         b.modo,
                         b.tipo_ope,
                         b.id_personal,
                         b.tipo_pac,
                         DECODE(b.tipo_pac,'5','PAR',upper(c.nombre) ) nom_tippac,
                         '0' pago_hono,
                         '' id_articulo,
                         replace(b.punto,'04','32') punto,
                         '' nom_articulo,
                         '' id_medico_ser,
                         '' id_medico_hono,
                         '' nom_med,
                         'HOSPITALIZACION' nom_niv,
                         nvl(plan(b.id_plan),' ') nom_plan,
                         0 descuento,
                         0 cobertura,
                         0 igv,
                         ( b.base_imp ) * ( factor_tipo_ope(b.tipo_ope) ) total,
                         '31101' cent_cost
                     FROM
                         vent_registro b,
                         tipo_pac c
                     WHERE
                         b.tipo_pac = c.tipo_pac
                         AND trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD')
                         AND b.estado = 'V'
                         AND b.modo = '1'
                         AND b.tipo_ope IN (
                             '3',
                             '4'
                         )
                         AND b.id_vnt_ref IS NULL
                         AND replace(b.punto,'04','32') IN (
                             SELECT DISTINCT
                                 DECODE(punto,'04','32',punto) punto
                             FROM
                                 puntos
                             WHERE
                                 tipo = 'C'
                                 AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                 AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                         )
                     UNION ALL
                     /*Hospitalizacion()*/
                     SELECT
                         b.id_mov_vnt,
                         ' ' id_movart,
                         b.modo,
                         b.tipo_ope,
                         b.id_personal,
                         b.tipo_pac,
                         DECODE(b.tipo_pac,'5','PAR',upper(c.nombre) ) nom_tippac,
                         '0' pago_hono,
                         '' id_articulo,
                         replace(b.punto,'04','32') punto,
                         '' nom_articulo,
                         '' id_medico_ser,
                         '' id_medico_hono,
                         '' nom_med,
                         'HOSPITALIZACION' nom_niv,
                         nvl(plan(b.id_plan),' ') nom_plan,
                         0 descuento,
                         0 cobertura,
                         0 igv,
                         ( b.base_imp ) * ( factor_tipo_ope(b.tipo_ope) ) total,
                         '31101' cent_cost
                     FROM
                         vent_registro b,
                         tipo_pac c
                     WHERE
                         b.tipo_pac = c.tipo_pac
                         AND trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD')
                         AND b.estado = 'V'
                         AND b.modo = '1'
                         AND b.tipo_ope IN (
                             '3',
                             '4'
                         )
                         AND replace(b.punto,'04','32') IN (
                             SELECT DISTINCT
                                 DECODE(punto,'04','32',punto) punto
                             FROM
                                 puntos
                             WHERE
                                 tipo = 'C'
                                 AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                 AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                         )
                         AND b.id_vnt_ref IN (
                             SELECT
                                 id_vnt_ref
                             FROM
                                 vent_registro b
                             WHERE
                                 trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD')
                                 AND b.estado = 'V'
                                 AND b.modo = '1'
                                 AND b.tipo_ope IN (
                                     '3',
                                     '4'
                                 )
                                 AND b.id_vnt_ref IS NOT NULL
                             MINUS
                             SELECT
                                 id_mov_vnt
                             FROM
                                 vent_registro
                             WHERE
                                 modo = '2'
                                 AND estado = 'V'
                                 AND id_mov_vnt IN (
                                     SELECT
                                         id_vnt_ref
                                     FROM
                                         vent_registro b
                                     WHERE
                                         trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD')
                                         AND b.estado = 'V'
                                         AND b.modo = '1'
                                         AND b.tipo_ope IN (
                                             '3',
                                             '4'
                                         )
                                         AND b.id_vnt_ref IS NOT NULL
                                 )
                         );
    /*
    Notas de Credito
    */

    CURSOR nota_cred IS
                        /* Empty(empty)*/ SELECT
                           b.id_mov_vnt,
                           b.modo,
                           b.tipo_ope,
                           b.id_personal,
                           b.tipo_pac,
                           DECODE(e.tipo_pac,'5','PAR',upper(e.nombre) ) nom_tippac,
                           c.pago_hono,
                           c.id_articulo,
                           DECODE(b.punto,'32','04',b.punto) punto,
                           articulo(c.id_articulo) nom_articulo,
                           c.id_medico_ser,
                           nombre(c.id_medico_ser) nom_med,
                           nombre_nivel(substr(d.id_nivel,1,2) ) nom_niv,
                           nvl(plan(b.id_plan),' ') nom_plan,
                           ( nvl(c.descuento,0) + nvl(c.descuento_esp,0) ) descuento,
                           nvl(c.cobertura,0) cobertura,
                           c.igv,
                           ( c.valor_venta - nvl(c.ret_hono,0) ) * ( factor_tipo_ope(b.tipo_ope) ) total,
                           ( b.total ) * ( factor_tipo_ope(b.tipo_ope) ) importe,
                           centro_costo(c.id_articulo) cent_cost
                       FROM
                           vent_registro b,
                           vent_regdet c,
                           patron d,
                           tipo_pac e
                       WHERE
                           b.id_mov_vnt = c.id_mov_vnt
                           AND c.id_articulo = d.id_servicio
                           AND b.tipo_pac = e.tipo_pac
                           AND b.modo = '1'
                           AND b.estado = 'V'
                           AND b.tipo_ope IN (
                               '1',
                               '2'
                           )
                           AND b.id_mov_vnt IN (
                               SELECT
                                   id_mov_vnt
                               FROM
                                   fact_comprobantes
                               WHERE
                                   tipo_doc IN (
                                       '04',
                                       '80'
                                   )
                                   AND estado = 'V'
                                   AND modo = '1'
                                   AND cajcom IS NULL
                                   AND numvou IS NULL
                                   AND TO_CHAR(fecha_emision,'YYYYMMDD') = date_sale
                           )
                       UNION ALL
                       /* Empty(empty)*/
                       SELECT
                           b.id_mov_vnt,
                           b.modo,
                           b.tipo_ope,
                           b.id_personal,
                           b.tipo_pac,
                           DECODE(e.tipo_pac,'5','PAR',upper(e.nombre) ) nom_tippac,
                           '0' pago_hono,
                           '' id_articulo,
                           DECODE(b.punto,'32','04',b.punto) punto,
                           '' nom_articulo,
                           '' id_medico_ser,
                           '' nom_med,
                           '' nom_niv,
                           nvl(plan(b.id_plan),' ') nom_plan,
                           ( nvl(b.descuento,0) + nvl(b.descuento_esp,0) ) descuento,
                           nvl(b.cobertura,0) cobertura,
                           b.igv,
                           ( b.valor_venta - nvl(b.ret_hono,0) ) * ( factor_tipo_ope(b.tipo_ope) ) total,
                           ( b.total ) * ( factor_tipo_ope(b.tipo_ope) ) importe,
                           'X' cent_cost
                       FROM
                           vent_registro b,
                           tipo_pac e
                       WHERE
                           b.tipo_pac = e.tipo_pac
                           AND b.modo = '1'
                           AND b.estado = 'V'
                           AND b.tipo_ope IN (
                               '3',
                               '4',
                               '5',
                               '6',
                               '7',
                               '8',
                               '9',
                               '10'
                           )
                           AND b.id_mov_vnt IN (
                               SELECT
                                   id_mov_vnt
                               FROM
                                   fact_comprobantes
                               WHERE
                                   tipo_doc IN (
                                       '04',
                                       '80'
                                   )
                                   AND estado = 'V'
                                   AND modo = '1'
                                   AND cajcom IS NULL
                                   AND numvou IS NULL
                                   AND TO_CHAR(fecha_emision,'YYYYMMDD') = date_sale
                           );
    /*
    Notas de Credito Particular
    */

    CURSOR nc_vent IS 
                    /* Empty(empty)*/ SELECT
                         b.id_mov_vnt,
                         b.modo,
                         b.tipo_ope,
                         b.id_personal,
                         b.tipo_pac,
                         DECODE(e.tipo_pac,'5','PAR',upper(e.nombre) ) nom_tippac,
                         c.pago_hono,
                         c.id_articulo,
                         DECODE(b.punto,'32','04',b.punto) punto,
                         'N/C '
                         || b.serie
                         || ' '
                         || lpad(b.numdoc,8,'0') docum,
                         articulo(c.id_articulo) nom_articulo,
                         c.id_medico_ser,
                         nombre(c.id_medico_ser) nom_med,
                         nombre_nivel(substr(d.id_nivel,1,2) ) nom_niv,
                         nvl(plan(b.id_plan),' ') nom_plan,
                         ( nvl(c.descuento,0) + nvl(c.descuento_esp,0) ) descuento,
                         nvl(c.cobertura,0) cobertura,
                         c.igv,
                         ( c.valor_venta - nvl(c.ret_hono,0) ) total,
                         ( b.total ) importe,
                         centro_costo(c.id_articulo) cent_cost
                     FROM
                         vent_registro b,
                         vent_regdet c,
                         patron d,
                         tipo_pac e
                     WHERE
                         b.id_mov_vnt = c.id_mov_vnt
                         AND c.id_articulo = d.id_servicio
                         AND b.tipo_pac = e.tipo_pac
                         AND b.modo = '1'
                         AND b.estado = 'V'
                         AND b.tipo_ope IN (
                             '1',
                             '2'
                         )
                         AND b.tipo_doc IN (
                             '04',
                             '80'
                         )
                         AND trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD')
                     UNION ALL
                     SELECT
                         b.id_mov_vnt,
                         b.modo,
                         b.tipo_ope,
                         b.id_personal,
                         b.tipo_pac,
                         DECODE(e.tipo_pac,'5','PAR',upper(e.nombre) ) nom_tippac,
                         '0' pago_hono,
                         '' id_articulo,
                         DECODE(b.punto,'32','04',b.punto) punto,
                         'N/C '
                         || b.serie
                         || ' '
                         || lpad(b.numdoc,8,'0') docum,
                         '' nom_articulo,
                         '' id_medico_ser,
                         '' nom_med,
                         '' nom_niv,
                         nvl(plan(b.id_plan),' ') nom_plan,
                         ( nvl(b.descuento,0) + nvl(b.descuento_esp,0) ) descuento,
                         nvl(b.cobertura,0) cobertura,
                         b.igv,
                         ( b.valor_venta - nvl(b.ret_hono,0) ) total,
                         ( b.total ) importe,
                         'X' cent_cost
                     FROM
                         vent_registro b,
                         tipo_pac e
                     WHERE
                         b.tipo_pac = e.tipo_pac
                         AND b.modo = '1'
                         AND b.estado = 'V'
                         AND b.tipo_ope IN (
                             '3',
                             '4',
                             '5',
                             '6',
                             '7',
                             '8',
                             '9',
                             '10'
                         )
                         AND b.tipo_doc IN (
                             '04',
                             '80'
                         )
                         AND trunc(b.fecha) = TO_DATE(date_sale,'YYYYMMDD');
    /*
    Codigo de plan contable
    */

    CURSOR codigo IS SELECT
                        admcdc,
                        garcdc,
                        igvcta,
                        parcta,
                        precta,
                        segcta,
                        tracta,
                        descta,
                        desctc,
                        cobcta,
                        cobctc,
                        cajcta,
                        cajctc,
                        devcta,
                        ambcta,
                        hoscta,
                        copctc
                    FROM
                        eco_pr;

    CURSOR ver_patron IS SELECT
                            nvl(codpla,'X'),
                            ctacte,
                            nvl(tipctc,'X')
                        FROM
                            patron
                        WHERE
                            id_servicio = codi_serv;

    CURSOR copagos IS SELECT
                         centro_costo(id_articulo)
                     FROM
                         vent_regdet
                     WHERE
                         id_mov_vnt IN (
                             SELECT
                                 id_mov_vnt
                             FROM
                                 vent_registro
                             WHERE
                                 id_vnt_ref = v_id_mov_vnt
                         );

    CURSOR garantia IS SELECT DISTINCT
                          substr(codigo,1,1)
                      FROM
                          datos_afiliados
                      WHERE
                          id_personal = v_id_personal
                          AND estado <> 'T';

    CURSOR medico IS SELECT
                        nvl(ctacte,' ')
                    FROM
                        datos_medico
                    WHERE
                        id_personal = v_id_medico_ser;

    CURSOR medico_hono IS SELECT
                             nvl(ctacte,' ')
                         FROM
                             datos_medico
                         WHERE
                             id_personal = v_id_medico_hono;

    CURSOR cencos_puntos IS SELECT
                               nvl(TRIM(cencos),'Y')
                           FROM
                               puntos
                           WHERE
                               punto = v_caja;

    CURSOR documento IS SELECT
                           id_mov_doc,
                           punto,
                           'N/C '
                           || serie
                           || ' '
                           || lpad(nro_doc,8,'0')
                       FROM
                           fact_comprobantes
                       WHERE
                           tipo_doc IN (
                               '04',
                               '80'
                           )
                           AND estado = 'V'
                           AND modo = '1'
                           AND id_mov_vnt = v_id_mov_vnt;

    CURSOR igv_vent IS SELECT
                          punto,
                          SUM(igv) igv
                      FROM
                          vent_registro
                      WHERE
                          trunc(fecha) = TO_DATE(date_sale,'YYYYMMDD')
                          AND estado = 'V'
                          AND modo = '1'
                          AND replace(punto,'04','32') IN (
                              SELECT
                                  DECODE(punto,'04','32',punto) punto
                              FROM
                                  puntos
                              WHERE
                                  tipo = 'C'
                                  AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                  AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                                  AND tipo_doc IN (
                                      SELECT
                                          tipo_doc
                                      FROM
                                          cont_tipo_doc
                                      WHERE
                                          ventas = '1'
                                          AND tipo_doc NOT IN (
                                              '04',
                                              '80'
                                          )
                                  )
                          )
                      GROUP BY
                          punto;

    CURSOR igv_fact IS SELECT
                          punto,
                          SUM(igv) igv
                      FROM
                          fact_comprobantes
                      WHERE
                          tipo_doc IN (
                              '04',
                              '80'
                          )
                          AND estado = 'V'
                          AND modo = '1'
                          AND cajcom IS NULL
                          AND numvou IS NULL
                          AND TO_CHAR(fecha_emision,'YYYYMMDD') = date_sale
                      GROUP BY
                          punto;

    CURSOR igv_not IS SELECT
                         punto,
                         SUM(igv) igv
                     FROM
                         vent_registro
                     WHERE
                         TO_CHAR(fecha,'yyyymmdd') = date_sale
                         AND estado = 'V'
                         AND modo = '1'
                         AND replace(punto,'04','32') IN (
                             SELECT
                                 DECODE(punto,'04','32',punto) punto
                             FROM
                                 puntos
                             WHERE
                                 tipo = 'C'
                                 AND TO_CHAR(fecini,'YYYYMMDD') <= date_sale
                                 AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= date_sale
                                 AND tipo_doc IN (
                                     '04',
                                     '80'
                                 )
                         )
                     GROUP BY
                         punto;

    CURSOR tipo_cta IS SELECT
                          CASE
                              WHEN id_ctacte IS NULL THEN 'A'
                              ELSE cta_hosp(id_ctacte)
                          END hosp
                      FROM
                          vent_registro
                      WHERE
                          id_mov_vnt = v_id_mov_vnt;

BEGIN
    contador := 0;
    cont := 0;
    DELETE FROM asient
    WHERE
        id_personal_user = id_user;
    --REGISTRO VENTAS

    FOR i IN ventas LOOP
        codi_serv := i.id_articulo;
        v_id_mov_vnt := i.id_mov_vnt;
        v_id_personal := i.id_personal;
        v_caja := i.punto;
        v_id_medico_ser := i.id_medico_ser;
        v_id_medico_hono := i.id_medico_hono;
        OPEN codigo;
        FETCH codigo INTO
            admi_cent,
            gara_cent,
            igv_cuen,
            part_cuen,
            prep_cuen,
            segu_cuen,
            trad_cuen,
            desc_cuen,
            desc_ctc,
            cob_cuen,
            cob_ctc,
            caj_cuen,
            caj_ctc,
            dev_cuen,
            amb_cuen,
            hos_cuen,
            cop_ctc;

        CLOSE codigo;
        contador := contador + 1;
        OPEN garantia;
        FETCH garantia INTO cob_ctc;
        CLOSE garantia;
        IF i.tipo_ope = '1' OR i.tipo_ope = '2' OR i.tipo_ope = '8' THEN
            OPEN ver_patron;
            FETCH ver_patron INTO
                codi_cuen,
                codi_ctct,
                v_tipctc;
            IF ver_patron%notfound OR codi_cuen = 'X' THEN
                cont := cont + 1;
                SELECT
                    codpla,
                    nvl(TRIM(ctacte),'X')
                INTO
                    codi_cuen,
                    codi_ctct
                FROM
                    tipo_operacion
                WHERE
                    tipo = i.tipo_ope;

                IF codi_ctct = 'X' THEN
                    SELECT
                        ambctc
                    INTO codi_ctct
                    FROM
                        tipo_pac
                    WHERE
                        tipo_pac = i.tipo_pac;

                END IF;

            ELSE
                IF v_tipctc = '3' THEN
                    SELECT
                        ambctc
                    INTO codi_ctct
                    FROM
                        tipo_pac
                    WHERE
                        tipo_pac = i.tipo_pac;

                END IF;
            END IF;

            CLOSE ver_patron;
        ELSE
            SELECT
                codpla,
                ctacte
            INTO
                codi_cuen,
                codi_ctct
            FROM
                tipo_operacion
            WHERE
                tipo = i.tipo_ope;

            IF i.tipo_ope = '3' OR i.tipo_ope = '4' THEN
                OPEN tipo_cta;
                FETCH tipo_cta INTO v_tipo_cta;
                CLOSE tipo_cta;
                IF v_tipo_cta = 'A' THEN
                    codi_cuen := amb_cuen;
                ELSE
                    codi_cuen := hos_cuen;
                END IF;

                codi_ctct := cop_ctc;
            END IF;

        END IF;

        SELECT
            DECODE(substr(codi_cuen,1,1),'1','S','2','S','N')
        INTO v_cuen
        FROM
            dual;
        -- Ventas

        IF i.tipo_ope = '1' THEN
            concep := i.nom_tippac
                      || ' '
                      || i.nom_niv;
            concep_desc := 'DESC. ' || i.nom_niv;
            concep_cob := 'COB. ' || i.nom_niv;
            desc_cent := i.cent_cost;
            cob_cent := i.cent_cost;
            IF i.tipo_pac = '1' AND codi_cuen <> '3142002' THEN
                OPEN garantia;
                FETCH garantia INTO codi_ctct;
                CLOSE garantia;
            END IF;

            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := i.cent_cost;
            END IF;

        END IF;
        --Honorarios Profesionales

        IF i.tipo_ope = '2' THEN
            concep := i.nom_med;
            IF length(i.id_medico_hono) > 3 THEN
                OPEN medico_hono;
                FETCH medico_hono INTO codi_ctct;
                IF medico_hono%notfound THEN
                    codi_ctct := '';
                END IF;
                CLOSE medico_hono;
            ELSE
                OPEN medico;
                FETCH medico INTO codi_ctct;
                IF medico%notfound THEN
                    codi_ctct := '';
                END IF;
                CLOSE medico;
            END IF;

            concep_desc := 'DESC. ' || i.nom_niv;
            concep_cob := 'COB. ' || i.nom_niv;
            desc_cent := i.cent_cost;
            cob_cent := i.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := i.cent_cost;
            END IF;

        END IF;
        --Deducible

        IF i.tipo_ope = '3' OR i.tipo_ope = '4' THEN
            concep := 'COPAGO COMPANIAS ' || i.nom_niv;
            concep_desc := 'DESC. ' || i.nom_niv;
            desc_cent := i.cent_cost;
            concep_cob := 'COB. ' || i.nom_niv;
            cob_cent := i.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := i.cent_cost;
            END IF;

        END IF;
        --Dep. en Garantia/Dev.Pac./Dev.Prod.

        IF i.tipo_ope = '5' OR i.tipo_ope = '9' OR i.tipo_ope = '10' THEN
            concep := 'CTAS.PAC.PARTICULARES ' || serie_numdoc_cliente(i.id_mov_vnt);
            concep_desc := 'DESC. ' || i.nom_niv;
            desc_cent := i.cent_cost;
            concep_cob := 'COB. ' || i.nom_niv;
            cob_cent := i.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := i.cent_cost;
            END IF;

        END IF;
        --Manutencion GG.SS.

        IF i.tipo_ope = '6' THEN
            concep := 'MANUTENCION GG.SS. ';--||I.NOM_PLAN;
            concep_desc := 'DESC. GGSS ' || i.nom_niv;
            desc_cent := gara_cent;
            concep_cob := 'COB. GGSS ' || i.nom_niv;
            cob_cent := gara_cent;
          --PARA LA CUENTA CORRIENTE
            OPEN garantia;
            FETCH garantia INTO codi_ctct;
            CLOSE garantia;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := gara_cent;
            END IF;

        END IF;
        --Otros Pagos

        IF i.tipo_ope = '7' THEN
            concep := 'OTROS PAGOS ';
            concep_desc := 'DESC. ' || i.nom_niv;
            desc_cent := i.cent_cost;
            concep_cob := 'COB. ' || i.nom_niv;
            cob_cent := i.cent_cost;
            OPEN garantia;
            FETCH garantia INTO cob_ctc;
            CLOSE garantia;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := i.cent_cost;
            END IF;

        END IF;
        --Inscripcion GGSS

        IF i.tipo_ope = '8' THEN
            IF codi_cuen = '3142502' THEN
                concep := 'MANUTENCION GG.SS. ' || i.nom_plan;
            ELSE
                concep := 'INSCRIPCION GG.SS. ' || i.nom_plan;
            END IF;

            concep_desc := 'DESC. GGSS ' || i.nom_niv;
            desc_cent := gara_cent;
            concep_cob := 'COB. GGSS ' || i.nom_niv;
            cob_cent := gara_cent;
            OPEN garantia;
            FETCH garantia INTO codi_ctct;
            CLOSE garantia;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := gara_cent;
            END IF;

        END IF;

        OPEN cencos_puntos;
        FETCH cencos_puntos INTO v_cc_punto;
        IF v_cc_punto <> 'Y' THEN
            cent_cost := v_cc_punto;
            desc_cent := v_cc_punto;
            gara_cent := v_cc_punto;
        END IF;

        CLOSE cencos_puntos;
        asi_grab(id_account,codi_serv,codi_cuen,codi_ctct,cent_cost,i.total,concep,v_caja,'H',id_user,i.id_mov_vnt);

        IF i.descuento <> 0 THEN
            IF i.tipo_pac = '1' THEN
            -- Grabar el descuento
                asi_grab(id_account,NULL,desc_cuen,desc_ctc,desc_cent,i.descuento,concep_desc,v_caja,'D',id_user,i.id_mov_vnt);

            ELSE
            -- Grabar el descuento
                asi_grab(id_account,NULL,desc_cuen,desc_ctc,desc_cent,i.descuento,concep_desc,v_caja,'D',id_user,i.id_mov_vnt);
            END IF;
        END IF;

        IF i.cobertura <> 0 THEN
          -- Grabar la cobertura
            asi_grab(id_account,NULL,cob_cuen,cob_ctc,gara_cent,i.cobertura,concep_cob,v_caja,'D',id_user,i.id_mov_vnt);
        END IF;
        -- Registrar el I.G.V.

    END LOOP;
    
    /*Registro IGV de ventas*/

    FOR c IN igv_vent LOOP
        -- Registrar el I.G.V.
        asi_grab(id_account,NULL,igv_cuen,'',admi_cent,c.igv,'I.G.V.',c.punto,'H',id_user,'');
    END LOOP;
    
    /* Registro de NC Operaciones*/

    concep := '';
    concep_desc := '';
    concep_cob := '';
    FOR j IN nota_cred LOOP
        codi_serv := j.id_articulo;
        v_id_personal := j.id_personal;
        v_caja := j.punto;
        v_id_medico_ser := j.id_medico_ser;
        v_id_mov_vnt := j.id_mov_vnt;
        OPEN codigo;
        FETCH codigo INTO
            admi_cent,
            gara_cent,
            igv_cuen,
            part_cuen,
            prep_cuen,
            segu_cuen,
            trad_cuen,
            desc_cuen,
            desc_ctc,
            cob_cuen,
            cob_ctc,
            caj_cuen,
            caj_ctc,
            dev_cuen,
            amb_cuen,
            hos_cuen,
            cop_ctc;

        CLOSE codigo;
        OPEN documento;
        FETCH documento INTO
            v_id_mov_doc,
            v_caja,
            v_documento;
        CLOSE documento;
        OPEN garantia;
        FETCH garantia INTO cob_ctc;
        CLOSE garantia;
        contador := contador + 1;
        IF j.tipo_ope = '1' OR j.tipo_ope = '2' THEN
            OPEN ver_patron;
            FETCH ver_patron INTO
                codi_cuen,
                codi_ctct,
                v_tipctc;
            IF ver_patron%notfound OR codi_cuen = 'X' THEN
                cont := cont + 1;
                SELECT
                    codpla,
                    nvl(ctacte,' ')
                INTO
                    codi_cuen,
                    codi_ctct
                FROM
                    tipo_operacion
                WHERE
                    tipo = j.tipo_ope;

            END IF;

            CLOSE ver_patron;
        END IF;

        SELECT
            DECODE(substr(codi_cuen,1,1),'1','S','2','S','N')
        INTO v_cuen
        FROM
            dual;

        IF j.tipo_ope = '1' THEN
            concep := 'DEV.'
                      || j.nom_tippac
                      || ' '
                      || j.nom_niv;
            concep_desc := 'DEV.DESC. ' || j.nom_niv;
            concep_cob := 'DEV.COB. ' || j.nom_niv;
            desc_cent := j.cent_cost;
            cob_cent := j.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := j.cent_cost;
            END IF;

        END IF;

        IF j.tipo_ope = '2' THEN
            concep := j.nom_med;
            OPEN medico;
            FETCH medico INTO codi_ctct;
            IF medico%notfound THEN
                codi_ctct := '';
            END IF;
            CLOSE medico;
            concep_desc := 'DEV.DESC. ' || j.nom_niv;
            concep_cob := 'DEV.COB. ' || j.nom_niv;
            desc_cent := j.cent_cost;
            cob_cent := j.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := j.cent_cost;
            END IF;

        END IF;

        IF j.tipo_ope = '3' OR j.tipo_ope = '4' THEN
            concep := 'DEV.COPAGO COMPA?IAS ' || j.nom_niv;
            concep_desc := 'DEV. DESC. ' || j.nom_niv;
            desc_cent := j.cent_cost;
            concep_cob := 'DEV. COB. ' || j.nom_niv;
            cob_cent := j.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                OPEN copagos;
                FETCH copagos INTO cent_cost;
                IF copagos%notfound THEN
                    cent_cost := '31101';
                END IF;
                CLOSE copagos;
            END IF;

            IF cent_cost = 'X' THEN
                cent_cost := '31101';
            END IF;
        END IF;

        IF j.tipo_ope = '5' THEN
            concep := 'DEV.CTAS.PAC.PARTICULARES';
            concep_desc := 'DEV.DESC. ' || j.nom_niv;
            desc_cent := j.cent_cost;
            concep_cob := 'DEV.COB. ' || j.nom_niv;
            cob_cent := j.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := j.cent_cost;
            END IF;

        END IF;

        IF j.tipo_ope = '6' THEN
            concep := 'DEV.MANUTENCION GG.SS. ';
            concep_desc := 'DEV.DESC.GGSS ' || j.nom_niv;
            desc_cent := gara_cent;
            concep_cob := 'DEV.COB.GGSS ' || j.nom_niv;
            cob_cent := gara_cent;
          --PARA LA CUENTA CORRIENTE
            OPEN garantia;
            FETCH garantia INTO codi_ctct;
            CLOSE garantia;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := gara_cent;
            END IF;

        END IF;

        IF j.tipo_ope = '7' THEN
            concep := 'DEV.OTROS PAGOS ';
            concep_desc := 'DEV.DESC. ' || j.nom_niv;
            desc_cent := j.cent_cost;
            concep_cob := 'DEV.COB. ' || j.nom_niv;
            cob_cent := j.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := j.cent_cost;
            END IF;

        END IF;

        IF j.tipo_ope = '8' THEN
            concep := 'DEV.INSCRIPCION GG.SS. ' || j.nom_plan;
            concep_desc := 'DEV.DESC.GGSS ' || j.nom_niv;
            desc_cent := gara_cent;
            concep_cob := 'DEV.COB.GGSS ' || j.nom_niv;
            cob_cent := gara_cent;
            OPEN garantia;
            FETCH garantia INTO codi_ctct;
            CLOSE garantia;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := gara_cent;
            END IF;

        END IF;

        IF j.tipo_pac = '3' OR j.tipo_pac = '4' OR j.tipo_pac = '5' OR j.tipo_pac = '6' THEN
            codi_ctct := '1';
        END IF;

        IF j.tipo_pac = '2' THEN
            codi_ctct := '2';
        END IF;
        IF j.tipo_pac = '1' THEN
            codi_ctct := '3';
        END IF;
        asi_grab(id_account,codi_serv,dev_cuen,codi_ctct,cent_cost,j.total,v_documento,v_caja,'D',id_user,v_id_mov_doc);

        IF j.descuento > 0 THEN
          -- SI ES PACIENTE DE GGSS
            IF j.tipo_pac = '1' THEN
            -- Grabar el descuento
                asi_grab(id_account,NULL,cob_cuen,cob_ctc,gara_cent,j.descuento,v_documento,v_caja,'H',id_user,v_id_mov_doc);

            ELSE
            -- Grabar el descuento
                asi_grab(id_account,NULL,desc_cuen,desc_ctc,desc_cent,j.descuento,v_documento,v_caja,'H',id_user,v_id_mov_doc);
            END IF;
        END IF;

        IF j.cobertura > 0 THEN
          -- Grabar la cobertura
            asi_grab(id_account,NULL,cob_cuen,cob_ctc,gara_cent,j.cobertura,v_documento,v_caja,'H',id_user,v_id_mov_doc);
        END IF;

    END LOOP;
    /*Registro IGV de Operaciones*/

    FOR d IN igv_fact LOOP
        -- Registrar el I.G.V.
        asi_grab(id_account,NULL,igv_cuen,'',admi_cent,d.igv,'DEV. I.G.V.',d.punto,'D',id_user,'');
    END LOOP;
      
      /* Registro de NC Ventas*/

    concep := '';
    concep_desc := '';
    concep_cob := '';
    FOR m IN nc_vent LOOP
        codi_serv := m.id_articulo;
        v_id_personal := m.id_personal;
        v_caja := m.punto;
        v_id_medico_ser := m.id_medico_ser;
        v_id_mov_vnt := m.id_mov_vnt;
        v_id_mov_doc := m.id_mov_vnt;
        v_documento := m.docum;
        OPEN codigo;
        FETCH codigo INTO
            admi_cent,
            gara_cent,
            igv_cuen,
            part_cuen,
            prep_cuen,
            segu_cuen,
            trad_cuen,
            desc_cuen,
            desc_ctc,
            cob_cuen,
            cob_ctc,
            caj_cuen,
            caj_ctc,
            dev_cuen,
            amb_cuen,
            hos_cuen,
            cop_ctc;

        CLOSE codigo;
        OPEN garantia;
        FETCH garantia INTO cob_ctc;
        CLOSE garantia;
        contador := contador + 1;
        IF m.tipo_ope = '1' OR m.tipo_ope = '2' THEN
            OPEN ver_patron;
            FETCH ver_patron INTO
                codi_cuen,
                codi_ctct,
                v_tipctc;
            IF ver_patron%notfound OR codi_cuen = 'X' THEN
                cont := cont + 1;
                SELECT
                    codpla,
                    nvl(ctacte,' ')
                INTO
                    codi_cuen,
                    codi_ctct
                FROM
                    tipo_operacion
                WHERE
                    tipo = m.tipo_ope;

            END IF;

            CLOSE ver_patron;
        END IF;

        SELECT
            DECODE(substr(codi_cuen,1,1),'1','S','2','S','N')
        INTO v_cuen
        FROM
            dual;

        IF m.tipo_ope = '1' THEN
            concep := 'DEV.'
                      || m.nom_tippac
                      || ' '
                      || m.nom_niv;
            concep_desc := 'DEV.DESC. ' || m.nom_niv;
            concep_cob := 'DEV.COB. ' || m.nom_niv;
            desc_cent := m.cent_cost;
            cob_cent := m.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := m.cent_cost;
            END IF;

        END IF;

        IF m.tipo_ope = '2' THEN
            concep := m.nom_med;
            OPEN medico;
            FETCH medico INTO codi_ctct;
            IF medico%notfound THEN
                codi_ctct := '';
            END IF;
            CLOSE medico;
            concep_desc := 'DEV.DESC. ' || m.nom_niv;
            concep_cob := 'DEV.COB. ' || m.nom_niv;
            desc_cent := m.cent_cost;
            cob_cent := m.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := m.cent_cost;
            END IF;

        END IF;

        IF m.tipo_ope = '3' OR m.tipo_ope = '4' THEN
            concep := 'DEV.COPAGO COMPA?IAS ' || m.nom_niv;
            concep_desc := 'DEV. DESC. ' || m.nom_niv;
            desc_cent := m.cent_cost;
            concep_cob := 'DEV. COB. ' || m.nom_niv;
            cob_cent := m.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                OPEN copagos;
                FETCH copagos INTO cent_cost;
                IF copagos%notfound THEN
                    cent_cost := '31101';
                END IF;
                CLOSE copagos;
            END IF;

            IF cent_cost = 'X' THEN
                cent_cost := '31101';
            END IF;
        END IF;

        IF m.tipo_ope = '5' THEN
            concep := 'DEV.CTAS.PAC.PARTICULARES';
            concep_desc := 'DEV.DESC. ' || m.nom_niv;
            desc_cent := m.cent_cost;
            concep_cob := 'DEV.COB. ' || m.nom_niv;
            cob_cent := m.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := m.cent_cost;
            END IF;

        END IF;

        IF m.tipo_ope = '6' THEN
            concep := 'DEV.MANUTENCION GG.SS. ';
            concep_desc := 'DEV.DESC.GGSS ' || m.nom_niv;
            desc_cent := gara_cent;
            concep_cob := 'DEV.COB.GGSS ' || m.nom_niv;
            cob_cent := gara_cent;
          --PARA LA CUENTA CORRIENTE
            OPEN garantia;
            FETCH garantia INTO codi_ctct;
            CLOSE garantia;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := gara_cent;
            END IF;

        END IF;

        IF m.tipo_ope = '7' THEN
            concep := 'DEV.OTROS PAGOS ';
            concep_desc := 'DEV.DESC. ' || m.nom_niv;
            desc_cent := m.cent_cost;
            concep_cob := 'DEV.COB. ' || m.nom_niv;
            cob_cent := m.cent_cost;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := m.cent_cost;
            END IF;

        END IF;

        IF m.tipo_ope = '8' THEN
            concep := 'DEV.INSCRIPCION GG.SS. ' || m.nom_plan;
            concep_desc := 'DEV.DESC.GGSS ' || m.nom_niv;
            desc_cent := gara_cent;
            concep_cob := 'DEV.COB.GGSS ' || m.nom_niv;
            cob_cent := gara_cent;
            OPEN garantia;
            FETCH garantia INTO codi_ctct;
            CLOSE garantia;
            IF v_cuen = 'S' THEN
                cent_cost := admi_cent;
            ELSE
                cent_cost := gara_cent;
            END IF;

        END IF;

        IF m.tipo_pac = '3' OR m.tipo_pac = '4' OR m.tipo_pac = '5' OR m.tipo_pac = '6' THEN
            codi_ctct := '1';
        END IF;

        IF m.tipo_pac = '2' THEN
            codi_ctct := '2';
        END IF;
        IF m.tipo_pac = '1' THEN
            codi_ctct := '3';
        END IF;
        asi_grab(id_account,codi_serv,dev_cuen,codi_ctct,cent_cost,m.total,v_documento,v_caja,'D',id_user,v_id_mov_doc);

        IF m.descuento > 0 THEN
            IF m.tipo_pac = '1' THEN
            -- Grabar el descuento
                asi_grab(id_account,NULL,cob_cuen,cob_ctc,gara_cent,m.descuento,v_documento,v_caja,'H',id_user,v_id_mov_doc);

            ELSE
            -- Grabar el descuento
                asi_grab(id_account,NULL,desc_cuen,desc_ctc,desc_cent,m.descuento,v_documento,v_caja,'H',id_user,v_id_mov_doc);
            END IF;
        END IF;

        IF m.cobertura > 0 THEN
          -- Grabar la cobertura
            asi_grab(id_account,NULL,cob_cuen,cob_ctc,gara_cent,m.cobertura,v_documento,v_caja,'H',id_user,v_id_mov_doc);
        END IF;

    END LOOP;
      /*Registro IGV de NC Ventas*/

    FOR n IN igv_not LOOP
        -- Registrar el I.G.V.
        asi_grab(id_account,NULL,igv_cuen,'',admi_cent,n.igv,'DEV. I.G.V.',n.punto,'D',id_user,'');
    END LOOP;
    
    RETURN('Account : '||contador||' Counter: '||cont);
END xo_account_entry;