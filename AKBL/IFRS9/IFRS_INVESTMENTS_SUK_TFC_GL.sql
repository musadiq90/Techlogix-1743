/* Formatted on 4/2/2022 10:58:37 PM (QP5 v5.215.12089.38647) */
SELECT SI.N_EOP_BAL, AM.N_EOP_BAL, SI.V_ACCOUNT_NUMBER
  FROM    STG_INVESTMENTS SI
       INNER JOIN
          VW_IFRS_ADJUSTMENTS_MANUAL AM
       ON     SI.V_PROD_cODE = AM.V_PROD_CODE
          AND SI.FIC_MIS_DATE = AM.FIC_MIS_dATE
 WHERE     SI.FIC_MIS_dATE = '30-SEP-2021'
       AND V_PROD_TYPE_dESC = 'Balances with other banks';



MERGE INTO STG_INVESTMENTS SI
     USING VW_IFRS_ADJUSTMENTS_MANUAL AM
        ON (    SI.V_PROD_cODE = AM.V_PROD_CODE
            AND SI.FIC_MIS_DATE = AM.FIC_MIS_dATE
            AND SI.FIC_MIS_dATE = '30-SEP-2021'
            AND V_PROD_TYPE_dESC = 'Balances with other banks')
WHEN MATCHED
THEN
   UPDATE SET SI.N_EOP_BAL = SI.N_EOP_BAL + AM.N_EOP_BAL;



SELECT DISTINCT trg.v_ISSUER_CODE
  FROM STG_INVESTMENTS trg
 WHERE     TRG.FIC_MIS_DATE = '30-SEP-2021'
       AND TRG.V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA';


SELECT DISTINCT V_CUST_TYPE, V_ISSUER_CODE
  FROM STG_INVESTMENTS trg
 WHERE     TRG.FIC_MIS_DATE = '30-SEP-2021'
       AND TRG.V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA';


UPDATE STG_INVESTMENTS SI
   SET V_CUST_TYPE =
          CASE
             WHEN V_ISSUER_CODE IN ('CUST-COR', 'CUST-BNK', 'CUST-OTH')
             THEN
                'COR'
             WHEN V_ISSUER_CODE = 'GOVPAK'
             THEN
                'GOV'
             ELSE
                NULL
          END,
       V_CLASS_CODE =
          CASE
             WHEN V_ISSUER_CODE IN ('CUST-COR', 'CUST-BNK', 'CUST-OTH')
             THEN
                'COR'
             WHEN V_ISSUER_CODE = 'GOVPAK'
             THEN
                'GOV'
             ELSE
                NULL
          END
 WHERE     SI.FIC_MIS_DATE = '30-SEP-2021'
       AND SI.V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA';



UPDATE STG_INVESTMENTS SI
   SET SI.V_CUST_TYPE = 'GOV', V_CLASS_CODE = 'GOV'
 WHERE     FIC_MIS_DATE = '30-SEP-2021'
       AND SI.V_BROKERAGE_FIRM <> 'VW_IFRS_GL_LEVEL_DATA'
       AND V_ACCOUNT_NUMBER IN
              (SELECT V_CONTRACT_CODE
                 FROM OFSRECON.STG_DATA_WEBTECH SDW
                WHERE     FIC_MIS_DATE = '30-SEP-2021'
                      AND (   SDW.V_ISSUER_TYPE IN ('SOZ', 'GOP')
                           OR V_SECURITIES_GUARANTOR_CD = 'GOP'));

COMMIT;


UPDATE STG_INVESTMENTS SI
   SET SI.V_CUST_TYPE = 'GOV', V_CLASS_CODE = 'GOV'
 WHERE     SI.FIC_MIS_DATE = '30-SEP-2021'
       AND SI.V_BROKERAGE_FIRM <> 'VW_IFRS_GL_LEVEL_DATA'
       AND SI.V_CUST_REF_CODE IN
              (SELECT * FROM OFSRECON.STG_ISSUER_CODES_CSTM);

COMMIT;



UPDATE STG_INVESTMENTS SI
   SET SI.V_CUST_TYPE = 'COR', V_CLASS_CODE = 'COR'
 WHERE     SI.FIC_MIS_DATE = '30-SEP-2021'
       AND V_CUST_TYPE IS NULL
       AND SI.V_BROKERAGE_FIRM <> 'VW_IFRS_GL_LEVEL_DATA';

COMMIT;



UPDATE STG_INVESTMENTS SI
   SET SI.V_CUST_TYPE = 'COR', V_CLASS_CODE = 'COR'
 WHERE     FIC_MIS_DATE = '30-SEP-2021'
       AND V_PROD_DESC = 'PSHARES'
       AND SI.V_BROKERAGE_FIRM <> 'VW_IFRS_GL_LEVEL_DATA';



  SELECT SI.V_ACCOUNT_NUMBER,
         SI.V_PROD_DESC,
         V_CUST_REF_CODE,
         V_PROD_cODE,
         V_GL_cODE,
         V_CUST_TYPE
    FROM STG_INVESTMENTS SI
   WHERE     FIC_MIS_dATE = '30-SEP-2021'
         AND (V_PROD_DESC IN ('TFC', 'SUKUK') OR V_PROD_DESC IS NULL)
ORDER BY V_PROD_DESC;


SELECT SARC.V_aCCOUNT_NUMBER,
       SI.V_ACCOUNT_NUMBER,
       SI.V_CUST_REF_CODE,
       SARC.V_RATING_cODE,
       SI.FIC_MIS_dATE
  FROM    STG_INVESTMENTS SI
       INNER JOIN
          OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
       ON     SI.FIC_MIS_dATE = SARC.FIC_MIS_dATE
          AND SUBSTR (SARC.V_aCCOUNT_NUMBER, 1, 8) = SI.V_PROD_CODE
 WHERE     SI.FIC_MIS_dATE = '30-SEP-2021'
       AND SI.V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA';                                                                                                                                                                                                            --AND SI.V_CUST_REF_CODE = 'PAFLT'


SELECT DISTINCT SUBSTR (SARC.V_aCCOUNT_NUMBER, 1, 8)
  FROM    STG_INVESTMENTS SI
       INNER JOIN
          OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
       ON     SI.FIC_MIS_dATE = SARC.FIC_MIS_dATE
          AND SUBSTR (SARC.V_aCCOUNT_NUMBER, 1, 8) = SI.V_PROD_CODE
 WHERE     SI.FIC_MIS_dATE = '30-SEP-2021'
       AND SI.V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA';


SELECT SUBSTR (V_aCCOUNT_NUMBER, 1, 8), V_aCCOUNT_NUMBER
  FROM OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
 WHERE FIC_MIS_dATE = '30-SEP-2021';                                                                                                                                                                                                                  --AND V_ACCOUNT_NUMBER = '5'

SELECT *
  FROM OFSRECON.STG_BNK_GL_RATING
 WHERE FIC_MIS_dATE = '30-SEP-2021';

  SELECT SUBSTR (V_aCCOUNT_NUMBER, 1, 8), V_aCCOUNT_NUMBER, COUNT (*)
    FROM OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
   WHERE     FIC_MIS_dATE = '30-SEP-2021'
         AND SUBSTR (V_aCCOUNT_NUMBER, 1, 8) IN
                (SELECT DISTINCT V_PROD_cODE
                   FROM STG_INVESTMENTS
                  WHERE     FIC_MIS_dATE = '30-SEP-2021'
                        AND V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA')
GROUP BY V_aCCOUNT_NUMBER;

SELECT DISTINCT v_account_number, SUBSTR (V_aCCOUNT_NUMBER, 1, 8) V_PROD_CODE
  FROM OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
 WHERE     FIC_MIS_dATE = '30-SEP-2021'
       AND SUBSTR (V_aCCOUNT_NUMBER, 1, 8) IN
              (SELECT DISTINCT V_PROD_cODE
                 FROM STG_INVESTMENTS
                WHERE     FIC_MIS_dATE = '30-SEP-2021'
                      AND V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA');