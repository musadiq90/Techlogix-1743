/* Formatted on 4/2/2022 10:51:56 PM (QP5 v5.215.12089.38647) */
  SELECT *
    FROM (  SELECT SUM (D.N_12M_ECL) AS ECL12M,
                   SUM (D.N_LIFETIME_ECL) AS ECL_LT,
                   AKBL.V_ACCOUNT_SEGMENT,
                   AKBL.N_CURR_IFRS_STAGE_SKEY
              FROM AKBL_ACCT_STAGE_ASSIGNMENT AKBL,
                   (  SELECT N_ACCT_SKEY,
                             N_RUN_SKEY,
                             SUM (
                                CASE
                                   WHEN N_CASH_FLOW_BUCKET_ID <= 12
                                   THEN
                                      NVL (N_CASH_SHORTFALL_PV, 0)
                                   ELSE
                                      0
                                END)
                                N_12M_ECL,
                             SUM (NVL (N_CASH_SHORTFALL_PV, 0)) N_LIFETIME_ECL,
                             SUM (NVL (A.N_PRINCIPAL_RUN_OFF, 0)) TOTAL_EXPOSURE
                        FROM FSI_CF_PROCESS_OUTPUTS A
                       WHERE     A.N_RUN_SKEY = 2200
                             AND NVL (N_CASH_SHORTFALL_PV, 0) > 0
                    GROUP BY N_ACCT_SKEY, N_RUN_SKEY) D
             WHERE AKBL.N_ACCT_SKEY = D.N_ACCT_SKEY AND AKBL.N_RUN_SKEY = 2197
          GROUP BY AKBL.V_ACCOUNT_SEGMENT, AKBL.N_CURR_IFRS_STAGE_SKEY
          ORDER BY AKBL.N_CURR_IFRS_STAGE_SKEY) PIVOT (SUM (D.N_12M_ECL)
                                                FOR AKBL.N_CURR_IFRS_STAGE_SKEY
                                                IN  (ECL12M,
                                                    ECL_LT,
                                                    V_ACCOUNT_SEGMENT))
ORDER BY N_CURR_IFRS_STAGE_SKEY