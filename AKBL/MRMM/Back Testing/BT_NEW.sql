/* Formatted on 12/20/2021 1:41:25 PM (QP5 v5.215.12089.38647) */
SELECT FIC_MIS_DATE,
       V_INSTRUMENT_CODE,
       N_CURR_UNITS,
       N_PREV_UNITS,
       ( (N_PREV_UNITS / N_PREV_PRICE) * N_CURR_PRICE) - N_PREV_UNITS
           AS N_HYPO_PROFIT_LOSS
  FROM (SELECT PL.FIC_MIS_DATE,
               SI.V_ACCOUNT_NUMBER AS V_INSTRUMENT_CODE,
               SI.N_MKT_VALUE AS N_CURR_UNITS,
               (NVL (
                   LEAD (
                      SI.N_MKT_VALUE)
                   OVER (PARTITION BY SI.V_ACCOUNT_NUMBER
                         ORDER BY SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                   SI.N_MKT_VALUE))
                  AS N_PREV_UNITS,
               PL.N_PRICE AS N_CURR_PRICE,
               (NVL (
                   LEAD (
                      PL.N_PRICE)
                   OVER (PARTITION BY SI.V_ACCOUNT_NUMBER
                         ORDER BY SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                   PL.N_PRICE))
                  AS N_PREV_PRICE
          FROM    VW_BACKTESTING_PL PL
               INNER JOIN
                  STG_INVESTMENTS SI
               ON     SI.V_CUST_REF_CODE = PL.CODE
                  AND SI.FIC_MIS_DATE = PL.FIC_MIS_DATE
                  AND SI.V_PROD_CODE = 'TFC'
                  AND SI.V_EXP_CATEGORY_CODE = 'AFS'
         WHERE PL.FIC_MIS_DATE IN (:MIS_DATE, :PREV_DATE))
 WHERE FIC_MIS_dATE = :MIS_dATE