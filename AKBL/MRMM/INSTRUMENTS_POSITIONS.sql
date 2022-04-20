/* Formatted on 4/20/2022 11:36:52 AM (QP5 v5.215.12089.38647) */
SELECT V_ACCOUNT_NUMBER,
       V_HOLDING_TYPE,
       V_INSTRUMENT_CODE,
       V_PROD_CODE,
       SI.D_MATURITY_DATE,
       SI.D_REPRICING_DATE,
       N_FACE_VALUE,
       N_MKT_VALUE,
       N_EOP_BAL
  FROM STG_INVESTMENTS SI
 WHERE FIC_MIS_DATE = '16-FEB-2022';


SELECT SUBSTR (V_FORMATTED_MKT_DATA, 16, LENGTH (V_FORMATTED_MKT_DATA) - 24)
          AS ACCT_NUM,
       N_VALUE
  FROM FSI_FIN_MARKET_DATA MD
 WHERE D_MKT_dATE = '16-FEB-2022' AND V_MARKET_TYPE = 'EQ_SPOT';