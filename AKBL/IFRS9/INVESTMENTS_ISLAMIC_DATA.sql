/* Formatted on 4/5/2022 2:56:31 PM (QP5 v5.215.12089.38647) */
  SELECT SI.V_BROKERAGE_FIRM, COUNT (*)
    FROM STG_INVESTMENTS SI
   WHERE FIC_MIS_DATE = '30-SEP-2021'
GROUP BY SI.V_BROKERAGE_FIRM;

SELECT DISTINCT V_ACCOUNT_NUMBER
  FROM STG_INVESTMENTS
 WHERE     FIC_MIS_DATE = '30-SEP-2021'
       AND V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA';



SELECT V_ACCOUNT_NUMBER,
       V_GL_CODE,
       V_CUST_TYPE,
       V_LV_CODE
  FROM STG_INVESTMENTS
 WHERE     FIC_MIS_DATE = '30-SEP-2021'
       AND V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA'
       AND v_Account_number NOT IN
              (SELECT V_ACCOUNT_NUMBER
                 FROM AKBL_ACCT_STAGE_ASSIGNMENT
                WHERE N_RUN_SKEY = 2197 AND V_ACCOUNT_NUMBER LIKE '%OTH-FLEX');



SELECT V_ACCOUNT_NUMBER
  FROM AKBL_ACCT_STAGE_ASSIGNMENT
 WHERE N_RUN_SKEY = 2197 AND V_ACCOUNT_NUMBER LIKE '%FLEX';

SELECT *
  FROM STG_INVESTMENTS
 WHERE FIC_MIS_DATE = '30-SEP-2021' AND V_ACCOUNT_NUMBER LIKE '%FLEX';

  SELECT V_LV_CODE, COUNT (*)
    FROM stg_INVESTMENTS
   WHERE FIC_MIS_DATE = '30-SEP-2021'
GROUP BY V_LV_CODE;