/* Formatted on 12/16/2021 7:42:46 PM (QP5 v5.215.12089.38647) */
SELECT DISTINCT INV.FIC_MIS_DATE,
       INV.V_ACCOUNT_NUMBER AS V_INSTRUMENT_CODE,
       INV.N_MKT_VALUE AS N_CURR_UNITS,
   MIC.N_NET_PRESENT_VALUE AS N_CURR_PRICE
  FROM    STG_INVESTMENTS INV
       LEFT OUTER JOIN
          (SELECT MAP.V_BANK_INSTR_CODE AS CODE,
                  IC.V_INSTRUMENT_CODE AS INSTRUMENT_CODE
             FROM    STG_MKT_INSTRUMENT_CONTRACT IC
                  INNER JOIN
                     OFSRECON.STG_TFC_SUK_MUFAP_MAP MAP
                  ON     IC.V_INSTRUMENT_CODE =
                            REPLACE (
                               REPLACE (
                                  REPLACE (MAP.V_MUFAP_INSTR_CODE, '-', '_'),
                                  ' ',
                                  '_'),
                               '/',
                               '_')
                     AND MAP.V_INSTR_DESC = 'INVESTMENT IN TFC'
            WHERE IC.FIC_MIS_DATE = :MIS_DATE
           UNION ALL
           SELECT V_BANK_INSTR_CODE AS CODE, 'UNLISTED' AS INSTRUMENT_CODE
             FROM OFSRECON.STG_TFC_SUK_MUFAP_MAP MM
            WHERE     MM.V_INSTR_DESC = 'INVESTMENT IN TFC'
                  AND MM.V_MUFAP_INSTR_CODE = 'Unlisted'
                  ) A
       ON A.CODE = INV.V_CUST_REF_CODE AND INV.FIC_MIS_DATE IN (:PREV_DATE, :MIS_DATE)
  INNER JOIN STG_MKT_INSTRUMENT_CONTRACT MIC
    ON     MIC.V_INSTRUMENT_CODE = A.INSTRUMENT_CODE
       AND MIC.FIC_MIS_DATE = INV.FIC_MIS_DATE
 WHERE     INV.FIC_MIS_DATE <= :MIS_DATE
       AND INV.FIC_MIS_DATE >= :PREV_DATE
       AND INV.V_PROD_DESC = 'TFC'
       AND INV.V_EXP_CATEGORY_CODE = 'AFS'