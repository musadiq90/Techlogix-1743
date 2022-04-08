/* Formatted on 4/8/2022 10:41:01 AM (QP5 v5.215.12089.38647) */
  SELECT AKBL.V_ACCOUNT_NUMBER,
         SUM (NVL (A.N_PRINCIPAL_RUN_OFF, 0) + NVL (A.N_INTEREST_RUN_OFF, 0))
            AS TOTAL_EXPOSURE
    FROM AKBL_ACCT_STAGE_ASSIGNMENT AKBL, FSI_CF_PROCESS_OUTPUTS A
   WHERE     AKBL.V_D_CUST_REF_CODE = '002700459'
         AND AKBL.N_ACCT_SKEY = A.N_ACCT_SKEY
         AND AKBL.N_RUN_SKEY = 2197
         --AND V_ACCOUNT_NUMBER NOT LIKE '%_INT'
         AND A.N_RUN_SKEY = 2200
GROUP BY AKBL.V_ACCOUNT_NUMBER;

SELECT *
  FROM OFSRECON.AATB_STG_FWD_EXCHG_RATES FWD
 WHERE     FIC_MIS_daTE = '30-SEP-2021'
       AND V_FROM_CCY_cODE = 'USD'
       AND V_TO_CCY_CODE = 'PKR';

SELECT V_ACCOUNT_NUMBER,
       V_PROD_CODE,
       V_CCY_CODE,
       V_dATA_ORIGIN,
       -1 * N_EOP_BAL * 170.6576
  FROM VW_IFRS_GL_LEVEL_DATA
 WHERE     FIC_MIS_DATE = '30-SEP-2021'
       AND v_PROD_cODE IN
              ('40203060',
               '40203062',
               '40203063',
               '40203064',
               '40203065',
               '40203067',
               '40203073',
               '40203074',
               '40204028');

SELECT SI.D_NEXT_PAYMENT_DATE
  FROM STG_INVESTMENTS SI
 WHERE FIC_MIS_dATE = '30-SEP-2021' AND N_EOP_BAL - N_PROVISION_AMOUNT <= 0;

SELECT SI.V_ACCOUNT_NUMBER,
       N_EOP_BAL,
       N_PROVISION_AMOUNT,
       N_EOP_BAL - N_PROVISION_AMOUNT
  FROM STG_INVESTMENTS SI
 WHERE FIC_MIS_dATE = '30-SEP-2021' AND N_PROVISION_AMOUNT > 0;

SELECT DISTINCT V_PROD_CODE
  FROM STG_INVESTMENTS SI
 WHERE     FIC_MIS_dATE = '30-SEP-2021'
       AND V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA';


SELECT V_PROD_CODE, v_account_number, N_EOP_BAL
  FROM STG_INVESTMENTS SI
 WHERE     FIC_MIS_dATE = '30-SEP-2021'
       AND V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA'
       AND V_PROD_CODE IN
              ('40203074',
               '40203073',
               '40203055',
               '40202500',
               '40203056',
               '40203057',
               '40203046',
               '40204013',
               '40201004',
               '40203071',
               '40203053',
               '40204018',
               '40203042',
               '40203059',
               '40203063',
               '40203062',
               '40203065',
               '40203067',
               '40204017',
               '40203048',
               '40203041',
               '40201003',
               '40203064',
               '40201005',
               '40203022',
               '40203077',
               '40203080',
               '40203058',
               '40203049',
               '40203052',
               '40203023',
               '40201019',
               '40204007',
               '40204015',
               '40201007',
               '40204002',
               '40203075',
               '40203078',
               '40203001',
               '40203060',
               '40204028',
               '40204500',
               '40202002',
               '40201026',
               '40203045',
               '40203040',
               '40204011',
               '40201008');


--with provision

SELECT *
  FROM (SELECT V_CONTRACT_CODE,
               V_EXP_CATEGORY_CODE,
               N_BOOK_VALUE,
               N_MARKET_VALUE,
               V_PROD_CODE,
               N_PROVISION_AMOUNT,
               CASE
                  WHEN SDA.V_EXP_CATEGORY_CODE = 'HTM'
                  THEN
                     GREATEST (
                        SDA.N_BOOK_VALUE - NVL (SDA.N_PROVISION_AMOUNT, 0),
                        0)
                  ELSE
                     GREATEST (
                        SDA.N_MARKET_VALUE - NVL (SDA.N_PROVISION_AMOUNT, 0),
                        0)
               END
                  N_EOP_BAL
          FROM OFSRECON.STG_dATA_ADAMS SDA
         WHERE     FIC_MIS_dATE = '30-SEP-2021'
               AND V_PROD_CODE IN ('PIB', 'TBILL', 'SUKUK'))
 WHERE N_EOP_BAL = 0;