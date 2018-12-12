/*Only Credit*/

SELECT
    --op.*,
    substr(op.concep,0,23) concep,
    op.codi_cuen codpla,
    nvl(op.codi_ctct,' ') ctacte,
    op.cent_cost cencos,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'01',1,0) ),'9999,990.99') princ,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'03',1,0) ),'9999,990.99') emerg,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'05',1,0) ),'9999,990.99') cajadieta,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'10',1,0) ),'9999,990.99') cajaupeu,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'04',1,'32',1,0) ),'9999,990.99') farma,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'51',1,0) ),'9999,990.99') farma2,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'58',1,0) ),'9999,990.99') admi2,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'53',1,0) ),'9999,990.99') princ2,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'62',1,0) ),'9999,990.99') cajaadmision,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'63',1,0) ),'9999,990.99') cajaadministrativa,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'65',1,0) ),'9999,990.99') cajaadmision1,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'66',1,0) ),'9999,990.99') cajaadmision2,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'67',1,0) ),'9999,990.99') cajaadmision3,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'68',1,0) ),'9999,990.99') cajaadmision4,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'69',1,0) ),'9999,990.99') cajaadmision5,
    TO_CHAR(SUM(op.total * DECODE(op.punto,'70',1,0) ),'9999,990.99') cajaodont,
    TO_CHAR(SUM(op.total),'9999,990.99') total
FROM
    (
SELECT
    xp.id_seat,
    xp.codi_cuen,
    xp.codi_ctct,
    xp.cent_cost,
    xp.total,
    xp.concep,
    nvl(aplacta_xo(xp.codi_cuen,codi_ctct),'N') datos2,
    xp.v_caja punto,
    'H',
    xp.id_user,
    xp.id_mov_vnt
FROM
    (
        SELECT
            '1' id_seat,
            xoz.codi_serv      codi_serv,
            xoz.codi_cuen_2    codi_cuen,
            xoz.codi_ctct_2    codi_ctct,
            xoz.cent_cost      cent_cost,
            xoz.total          total,
            xoz.descuento      descuento,
            xoz.desc_cuen      desc_cuen,
            xoz.desc_ctc       desc_ctc,
            xoz.desc_cent      desc_cent,
            xoz.cob_cuen,
            xoz.cob_ctc,
            xoz.gara_cent,
            xoz.cobertura,
            TRIM(xoz.concep) concep,
            TRIM(xoz.concep_desc) concep_desc,
            TRIM(xoz.concep_cob) concep_cob,
            xoz.v_caja         v_caja,
            'zero' id_user,
            xoz.v_id_mov_vnt   id_mov_vnt,
            xoz.tipo_pac
        FROM
            (
                SELECT
                    'basic data',
                    ox.id_articulo      codi_serv,
                    ox.id_mov_vnt       v_id_mov_vnt,
                    ox.id_personal      v_id_personal,
                    ox.punto            v_caja,
                    ox.id_medico_ser    v_id_medico_ser,
                    ox.id_medico_hono   v_id_medico_hono,
                    ox.total,
                    xe.desc_cuen,
                    xe.desc_ctc,
                    xe.cob_cuen,
                    xe.cob_ctc,
                    xe.gara_cent,
                    ox.tipo_pac,
                    'Advance data',
                    substr(xda.codigo,1,1) cob_ctc_1,
                    nvl(xp.codpla,'X') codi_cuen_1,
                    xp.ctacte           codi_ctct_1,
                    nvl(xp.tipctc,'X') v_tipctc_1,
                    CASE
                        WHEN ox.tipo_ope = '1'
                             OR ox.tipo_ope = '2'
                             OR ox.tipo_ope = '8' THEN CASE
                            WHEN nvl(xp.codpla,'X') = 'X' THEN xto.codpla
                        END
                        ELSE --xto.codpla
                         CASE
                            WHEN ox.tipo_ope = '3'
                                 OR ox.tipo_ope = '4' THEN CASE
                                WHEN xvr.id_ctacte IS NULL THEN xe.amb_cuen--'A'
                                ELSE xe.hos_cuen--cta_hosp(xvr.id_ctacte)
                            END
                            ELSE xto.codpla
                        END
                    END codi_cuen_2,
                    CASE
                        WHEN ox.tipo_ope = '1'
                             OR ox.tipo_ope = '8' THEN CASE
                            WHEN nvl(xp.codpla,'X') = 'X' THEN CASE
                                WHEN nvl(TRIM(xto.ctacte),'X') = 'X' THEN xtp.ambctc
                                ELSE nvl(TRIM(xto.ctacte),'X')
                            END
                        END
                        WHEN ox.tipo_ope = '2'        THEN CASE
                            WHEN length(ox.id_medico_hono) > 3 THEN CASE
                                WHEN nvl(xdm.ctacte,'XE') <> 'XE' THEN nvl(xdm.ctacte,'XE')
                                ELSE nvl(xdm.ctacte,'XE')
                                     || ' '
                            END
                            WHEN nvl(xp.codpla,'X') = 'X'
                                 AND nvl(xdm.ctacte,'XE') = 'XE' THEN CASE
                                WHEN nvl(TRIM(xto.ctacte),'X') = 'X' THEN xtp.ambctc
                                ELSE nvl(TRIM(xto.ctacte),'X')
                            END
                            ELSE nvl(xdms.ctacte,' ')
                        END
                        WHEN ox.tipo_ope = '6'
                             OR ox.tipo_ope = '8' THEN substr(xda.codigo,1,1)
                        WHEN nvl(xp.tipctc,'X') = '3' THEN xtp.ambctc
                        ELSE --xto.ctacte
                         CASE
                            WHEN ox.tipo_ope = '3'
                                 OR ox.tipo_ope = '4' THEN xe.cop_ctc
                            ELSE xto.ctacte
                        END
                    END codi_ctct_2,
    ---|||||||||||||||||||||||||||||||||||||||||||||||||||||---
                    DECODE(substr(CASE
                        WHEN ox.tipo_ope = '1'
                             OR ox.tipo_ope = '2'
                             OR ox.tipo_ope = '8' THEN CASE
                            WHEN nvl(xp.codpla,'X') = 'X' THEN xto.codpla
                        END
                        ELSE --xto.codpla
                         CASE
                            WHEN ox.tipo_ope = '3'
                                 OR ox.tipo_ope = '4' THEN CASE
                                WHEN xvr.id_ctacte IS NULL THEN xe.amb_cuen--'A'
                                ELSE xe.hos_cuen--cta_hosp(xvr.id_ctacte)
                            END
                            ELSE xto.codpla
                        END
                    END,1,1),'1','S','2','S','N') v_cuen,
                    CASE
                        WHEN ox.tipo_ope = '1' THEN ox.nom_tippac
                                                    || ' '
                                                    || ox.nom_niv
                        WHEN ox.tipo_ope = '2' THEN ox.nom_med
                        WHEN ox.tipo_ope = '3'
                             OR ox.tipo_ope = '4' THEN 'COPAGO COMPANIAS ' || ox.nom_niv
                        WHEN ox.tipo_ope = '5'
                             OR ox.tipo_ope = '9'
                             OR ox.tipo_ope = '10' THEN 'CTAS.PAC.PARTICULARES ' || serie_numdoc_cliente(ox.id_mov_vnt)
                        WHEN ox.tipo_ope = '6' THEN 'MANUTENCION GG.SS. '
                        WHEN ox.tipo_ope = '7' THEN 'OTROS PAGOS '
                        WHEN ox.tipo_ope = '8' THEN CASE
                            WHEN CASE
                                WHEN ox.tipo_ope = '1'
                                     OR ox.tipo_ope = '2'
                                     OR ox.tipo_ope = '8' THEN CASE
                                    WHEN nvl(xp.codpla,'X') = 'X' THEN xto.codpla
                                END
                                ELSE --xto.codpla
                                 CASE
                                    WHEN ox.tipo_ope = '3'
                                         OR ox.tipo_ope = '4' THEN CASE
                                        WHEN xvr.id_ctacte IS NULL THEN xe.amb_cuen--'A'
                                        ELSE xe.hos_cuen--cta_hosp(xvr.id_ctacte)
                                    END
                                    ELSE xto.codpla
                                END
                            END = '3142502' THEN 'MANUTENCION GG.SS. ' || ox.nom_plan
                            ELSE 'INSCRIPCION GG.SS. ' || ox.nom_plan
                        END
                    END concep,
                    CASE
                        WHEN ox.tipo_ope = '1' THEN 'DESC. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '2' THEN 'DESC. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '3'
                             OR ox.tipo_ope = '4' THEN 'DESC. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '5'
                             OR ox.tipo_ope = '9'
                             OR ox.tipo_ope = '10' THEN 'DESC. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '6' THEN 'DESC. GGSS ' || ox.nom_niv
                        WHEN ox.tipo_ope = '7' THEN 'DESC. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '8' THEN 'DESC. GGSS ' || ox.nom_niv
                    END concep_desc,
                    CASE
                        WHEN ox.tipo_ope = '1' THEN 'COB. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '2' THEN 'COB. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '3'
                             OR ox.tipo_ope = '4' THEN 'COB. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '5'
                             OR ox.tipo_ope = '9'
                             OR ox.tipo_ope = '10' THEN 'COB. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '6' THEN 'COB. GGSS ' || ox.nom_niv
                        WHEN ox.tipo_ope = '7' THEN 'COB. ' || ox.nom_niv
                        WHEN ox.tipo_ope = '8' THEN 'COB. GGSS ' || ox.nom_niv
                    END concep_cob,
                    CASE
                        WHEN ox.tipo_ope = '1' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '2' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '3'
                             OR ox.tipo_ope = '4' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '5'
                             OR ox.tipo_ope = '9'
                             OR ox.tipo_ope = '10' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '6' THEN xe.gara_cent
                        WHEN ox.tipo_ope = '7' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '8' THEN xe.gara_cent
                    END desc_cent,
                    CASE
                        WHEN ox.tipo_ope = '1' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '1' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '3'
                             OR ox.tipo_ope = '4' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '5'
                             OR ox.tipo_ope = '9'
                             OR ox.tipo_ope = '10' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '6' THEN xe.gara_cent
                        WHEN ox.tipo_ope = '7' THEN ox.cent_cost
                        WHEN ox.tipo_ope = '8' THEN xe.gara_cent
                    END cob_cent,
                    CASE
                        WHEN ox.tipo_ope = '1'
                             OR ox.tipo_ope = '2'
                             OR ox.tipo_ope = '3'
                             OR ox.tipo_ope = '4'
                             OR ox.tipo_ope = '5'
                             OR ox.tipo_ope = '9'
                             OR ox.tipo_ope = '10'
                             OR ox.tipo_ope = '7' THEN CASE
                            WHEN DECODE(substr(CASE
                                WHEN ox.tipo_ope = '1'
                                     OR ox.tipo_ope = '2'
                                     OR ox.tipo_ope = '8' THEN CASE
                                    WHEN nvl(xp.codpla,'X') = 'X' THEN xto.codpla
                                END
                                ELSE --xto.codpla
                                 CASE
                                    WHEN ox.tipo_ope = '3'
                                         OR ox.tipo_ope = '4' THEN CASE
                                        WHEN xvr.id_ctacte IS NULL THEN xe.amb_cuen--'A'
                                        ELSE xe.hos_cuen--cta_hosp(xvr.id_ctacte)
                                    END
                                    ELSE xto.codpla
                                END
                            END,1,1),'1','S','2','S','N') = 'S' THEN xe.admi_cent
                            ELSE ox.cent_cost
                        END
                        WHEN ox.tipo_ope = '6'
                             OR ox.tipo_ope = '8' THEN CASE
                            WHEN DECODE(substr(CASE
                                WHEN ox.tipo_ope = '1'
                                     OR ox.tipo_ope = '2'
                                     OR ox.tipo_ope = '8' THEN CASE
                                    WHEN nvl(xp.codpla,'X') = 'X' THEN xto.codpla
                                END
                                ELSE --xto.codpla
                                 CASE
                                    WHEN ox.tipo_ope = '3'
                                         OR ox.tipo_ope = '4' THEN CASE
                                        WHEN xvr.id_ctacte IS NULL THEN xe.amb_cuen--'A'
                                        ELSE xe.hos_cuen--cta_hosp(xvr.id_ctacte)
                                    END
                                    ELSE xto.codpla
                                END
                            END,1,1),'1','S','2','S','N') = 'S' THEN xe.admi_cent
                            ELSE xe.gara_cent
                        END
                    END cent_cost,
                    nvl(TRIM(xpo.cencos),'Y') v_cc_punto,
                    ox.descuento,
                    ox.cobertura
    /* */
                FROM
                    (
                        SELECT
                            b.id_mov_vnt,
                            c.id_movart,
                            b.modo,
                            b.tipo_ope,
                            b.id_personal,
                            b.tipo_pac,
                            DECODE(e.tipo_pac,'5','PAR',upper(e.nombre) ) nom_tippac,
                            c.pago_hono,
                            c.id_articulo,
                            b.punto,
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
                            AND trunc(b.fecha) = TO_DATE('20181017','YYYYMMDD')
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
                            AND b.punto IN (
                                SELECT DISTINCT
                                    punto   punto
                                FROM
                                    puntos
                                WHERE
                                    tipo = 'C'
                                    AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                    AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= '20181017'
                            )
                        UNION ALL
------------------------------------ DEBIT ATTENTION AND OTHERS ------------------------------------
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
                            b.punto,
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
                            AND trunc(b.fecha) = TO_DATE('20181017','YYYYMMDD')
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
                            AND b.punto IN (
                                SELECT DISTINCT
                                    punto   punto
                                FROM
                                    puntos
                                WHERE
                                    tipo = 'C'
                                    AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                    AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= '20181017'
                            )
                        UNION ALL
------------------------------------ CREDIT ATTENTION AND OTHERS ------------------------------------
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
                            e.punto,
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
                                                    TO_CHAR(fecha,'yyyymmdd') = '20181017'
                                                    AND estado = 'V'
                                                    AND modo = '1'
                                                    AND tipo_ope IN (
                                                        '3',
                                                        '4'
                                                    )
                                                    AND punto IN (
                                                        SELECT DISTINCT
                                                            punto
                                                        FROM
                                                            puntos
                                                        WHERE
                                                            tipo = 'C'
                                                            AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                                            AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >
                                                            = '20181017'
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
                                                    trunc(fecha) = TO_DATE('20181017','YYYYMMDD')
                                                    AND estado = 'V'
                                                    AND modo = '1'
                                                    AND tipo_ope IN (
                                                        '3',
                                                        '4'
                                                    )
                                                    AND punto IN (
                                                        SELECT DISTINCT
                                                            punto
                                                        FROM
                                                            puntos
                                                        WHERE
                                                            tipo = 'C'
                                                            AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                                            AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >
                                                            = '20181017'
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
------------------------------------ CREDIT UNKNOWN FUNCTION ------------------------------------
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
                            b.punto,
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
                                                WHERE
                                                    trunc(fecha) = TO_DATE('20181017','YYYYMMDD')
                                                    AND estado = 'V'
                                                    AND modo = '1'
                                                    AND tipo_ope IN (
                                                        '3',
                                                        '4'
                                                    )
                                                    AND punto IN (
                                                        SELECT DISTINCT
                                                            punto
                                                        FROM
                                                            puntos
                                                        WHERE
                                                            tipo = 'C'
                                                            AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                                            AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >
                                                            = '20181017'
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
                                                    trunc(fecha) = TO_DATE('20181017','YYYYMMDD')
                                                    AND estado = 'V'
                                                    AND modo = '1'
                                                    AND tipo_ope IN (
                                                        '3',
                                                        '4'
                                                    )
                                                    AND replace(punto,'04','32') IN (
                                                        SELECT DISTINCT
                                                            punto
                                                        FROM
                                                            puntos
                                                        WHERE
                                                            tipo = 'C'
                                                            AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                                            AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >
                                                            = '20181017'
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
------------------------------------ CREDIT HOSPITALIZATION(WITHOUT DOCUMENT REFERENCE) ------------------------------------
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
                            b.punto,
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
                            AND trunc(b.fecha) = TO_DATE('20181017','YYYYMMDD')
                            AND b.estado = 'V'
                            AND b.modo = '1'
                            AND b.tipo_ope IN (
                                '3',
                                '4'
                            )
                            AND b.id_vnt_ref IS NULL
                            AND b.punto IN (
                                SELECT DISTINCT
                                    punto
                                FROM
                                    puntos
                                WHERE
                                    tipo = 'C'
                                    AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                    AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= '20181017'
                            )
                        UNION ALL
------------------------------------ CREDIT HOSPITALIZATION(WITH A REFERENCE DOCUMENT DOES NOT EXIST) ------------------------------------
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
                            b.punto,
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
                            AND trunc(b.fecha) = TO_DATE('20181017','YYYYMMDD')
                            AND b.estado = 'V'
                            AND b.modo = '1'
                            AND b.tipo_ope IN (
                                '3',
                                '4'
                            )
                            AND replace(b.punto,'04','32') IN (
                                SELECT DISTINCT
                                    punto
                                FROM
                                    puntos
                                WHERE
                                    tipo = 'C'
                                    AND TO_CHAR(fecini,'YYYYMMDD') <= '20181017'
                                    AND TO_CHAR(nvl(fecfin,TO_DATE('30001231','YYYYMMDD') ),'YYYYMMDD') >= '20181017'
                            )
                            AND b.id_vnt_ref IN (
                                SELECT
                                    id_vnt_ref
                                FROM
                                    vent_registro b
                                WHERE
                                    trunc(b.fecha) = TO_DATE('20181017','YYYYMMDD')
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
                                            trunc(b.fecha) = TO_DATE('20181017','YYYYMMDD')
                                            AND b.estado = 'V'
                                            AND b.modo = '1'
                                            AND b.tipo_ope IN (
                                                '3',
                                                '4'
                                            )
                                            AND b.id_vnt_ref IS NOT NULL
                                    )
                            )
                    ) ox
                    LEFT JOIN datos_afiliados xda ON xda.id_personal = ox.id_personal
                                                     AND xda.estado <> 'T'
                    LEFT JOIN patron xp ON xp.id_servicio = ox.id_articulo
                    LEFT JOIN tipo_operacion xto ON xto.tipo = ox.tipo_ope
                    LEFT JOIN tipo_pac xtp ON xtp.tipo_pac = ox.tipo_pac
                    LEFT JOIN vent_registro xvr ON xvr.id_mov_vnt = ox.id_mov_vnt
                    LEFT JOIN datos_medico xdm ON xdm.id_personal = ox.id_medico_hono
                    LEFT JOIN datos_medico xdms ON xdm.id_personal = ox.id_medico_ser
                    LEFT JOIN puntos xpo ON xpo.punto = ox.punto,
                    (
                        SELECT
                            admcdc   admi_cent,
                            garcdc   gara_cent,
                            igvcta   igv_cuen,
                            parcta   part_cuen,
                            precta   prep_cuen,
                            segcta   segu_cuen,
                            tracta   trad_cuen,
                            descta   desc_cuen,
                            desctc   desc_ctc,
                            cobcta   cob_cuen,
                            cobctc   cob_ctc,
                            cajcta   caj_cuen,
                            cajctc   caj_ctc,
                            devcta   dev_cuen,
                            ambcta   amb_cuen,
                            hoscta   hos_cuen,
                            copctc   cop_ctc
                        FROM
                            eco_pr
                    ) xe
            ) xoz
        ORDER BY
            id_mov_vnt
    ) xp
    )op

group by op.codi_cuen, nvl(op.codi_ctct,' '), op.cent_cost, substr(op.concep,0,23)
order by codpla,ctacte,cencos,concep;