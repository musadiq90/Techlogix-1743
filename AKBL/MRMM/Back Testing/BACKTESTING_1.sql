SELECT SI.* FROM        STG_INVESTMENTS SI
                           INNER JOIN
                              STG_MKT_INSTRUMENT_CONTRACT MKT
                           ON SI.FIC_MIS_DATE = MKT.FIC_MIS_DATE
                              AND SI.V_CUST_REF_cODE = MKT.V_INSTRUMENT_CODE
                   WHERE       SI.FIC_MIS_DATE <= :MIS_DATE
                           AND SI.FIC_MIS_DATE >= :PREV_DATE
                           AND SI.V_PROD_DESC = 'TFC'
                           AND V_EXP_CATEGORY_CODE = 'AFS'
                           
                           
                           SELECT * FROM STG_INVESTMENTS WHERE FIC_MIS_dATE = :MIS_DATE
                           AND V_PROD_DESC = 'TFC'
                           AND V_EXP_CATEGORY_CODE = 'AFS'
                           
                           SELECT DISTINCT V_CUST_REF_CODE FROM STG_INVESTMENTS S WHERE FIC_MIS_dATE = :MIS_DATE AND  V_PROD_DESC = 'TFC'
                           AND V_EXP_CATEGORY_CODE = 'AFS'
                           
                           
SELECT MAP.V_BANK_INSTR_CODE FROM STG_MKT_INSTRUMENT_CONTRACT IC
INNER JOIN OFSRECON.STG_TFC_SUK_MUFAP_MAP MAP
ON IC.V_INSTRUMENT_CODE =  REPLACE (
                      REPLACE (REPLACE (MAP.V_MUFAP_INSTR_CODE, '-', '_'),
                               ' ',
                               '_'),
                      '/',
                      '_') AND MAP.V_INSTR_DESC = 'INVESTMENT IN TFC'
                      WHERE IC.FIC_MIS_DATE = :MIS_DATE