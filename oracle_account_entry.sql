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
