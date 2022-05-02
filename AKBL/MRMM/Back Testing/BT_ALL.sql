/* Formatted on 12/27/2021 4:30:20 PM (QP5 v5.215.12089.38647) */
  SELECT V_INSTRUMENT_TYPE, SUM (N_HYPO_PROFIT_LOSS)
    FROM (SELECT FIC_MIS_DATE,
                 'Stocks and Equity Funds' AS V_INSTRUMENT_TYPE,
                 V_INSTRUMENT_CODE,
                 ( (N_PREV_UNITS / N_PREV_PRICE) * N_CURR_PRICE) - N_PREV_UNITS
                    AS N_HYPO_PROFIT_LOSS
            FROM (SELECT SI.FIC_MIS_DATE,
                         SI.V_CUST_REF_CODE AS V_INSTRUMENT_CODE,
                         (SI.N_MKT_VALUE) AS N_CURR_UNITS,
                         (NVL (
                             LEAD (
                                SI.N_MKT_VALUE)
                             OVER (
                                PARTITION BY SI.V_CUST_REF_CODE
                                ORDER BY
                                   SI.V_CUST_REF_CODE, SI.FIC_MIS_DATE DESC),
                             SI.N_MKT_VALUE))
                            AS N_PREV_UNITS,
                         (MKT.N_NET_PRESENT_VALUE) AS N_CURR_PRICE,
                         (NVL (
                             LEAD (
                                MKT.N_NET_PRESENT_VALUE)
                             OVER (
                                PARTITION BY SI.V_CUST_REF_CODE
                                ORDER BY
                                   SI.V_CUST_REF_CODE, SI.FIC_MIS_DATE DESC),
                             MKT.N_NET_PRESENT_VALUE))
                            AS N_PREV_PRICE
                    FROM    STG_INVESTMENTS SI
                         INNER JOIN
                            STG_MKT_INSTRUMENT_CONTRACT MKT
                         ON     SI.FIC_MIS_DATE = MKT.FIC_MIS_DATE
                            AND SI.V_CUST_REF_CODE = MKT.V_INSTRUMENT_CODE
                   WHERE     SI.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                         AND SI.FIC_MIS_DATE >= :LD_PREV_DATE
                         AND (   SI.V_PROD_DESC LIKE '%SHARES'
                              OR (    SI.V_PROD_DESC = 'MFND'
                                  AND SI.V_INSTRUMENT_CODE = 'NITIEF'))
                         AND SI.V_REPAYMENT_TYPE IN
                                ('EQ_LS_NS', 'MUTUAL_FUNDS')
                         AND V_CUST_REF_CODE <> 'Agritech Limited')
           WHERE FIC_MIS_DATE = :L_FIC_MIS_DATE
          -- GROUP BY   FIC_MIS_DATE, V_INSTRUMENT_CODE
          UNION
          /* HOEQT */
          SELECT FIC_MIS_DATE,
                 'HO Portfolio' AS V_INSTRUMENT_TYPE,
                 V_INSTRUMENT_CODE,
                 ( (N_PREV_UNITS / N_PREV_PRICE) * N_CURR_PRICE) - N_PREV_UNITS
                    AS N_HYPO_PROFIT_LOSS
            FROM (SELECT SI.FIC_MIS_DATE,
                         SI.V_CUST_REF_CODE AS V_INSTRUMENT_CODE,
                         (SI.N_EOP_BAL) AS N_CURR_UNITS,
                         (NVL (
                             LEAD (
                                SI.N_EOP_BAL)
                             OVER (
                                PARTITION BY SI.V_CUST_REF_CODE
                                ORDER BY
                                   SI.V_CUST_REF_CODE, SI.FIC_MIS_DATE DESC),
                             SI.N_EOP_BAL))
                            AS N_PREV_UNITS,
                         (MKT.N_NET_PRESENT_VALUE) AS N_CURR_PRICE,
                         (NVL (
                             LEAD (
                                MKT.N_NET_PRESENT_VALUE)
                             OVER (
                                PARTITION BY SI.V_CUST_REF_CODE
                                ORDER BY
                                   SI.V_CUST_REF_CODE, SI.FIC_MIS_DATE DESC),
                             MKT.N_NET_PRESENT_VALUE))
                            AS N_PREV_PRICE
                    FROM    STG_INVESTMENTS SI
                         INNER JOIN
                            STG_MKT_INSTRUMENT_CONTRACT MKT
                         ON     SI.FIC_MIS_DATE = MKT.FIC_MIS_DATE
                            AND SI.V_CUST_REF_CODE = MKT.V_INSTRUMENT_CODE
                   WHERE     SI.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                         AND SI.FIC_MIS_DATE >= :LD_PREV_DATE
                         AND SI.V_PROD_DESC = 'HOEQT')
           WHERE FIC_MIS_DATE = :L_FIC_MIS_DATE
          --  GROUP BY   FIC_MIS_DATE, V_INSTRUMENT_CODE
          UNION
          /* TFCs */
          SELECT FIC_MIS_DATE,
                 'TFCs' AS V_INSTRUMENT_TYPE,
                 V_INSTRUMENT_CODE,
               (  ( (N_PREV_UNITS / N_PREV_PRICE) * N_CURR_PRICE) - N_PREV_UNITS)*-1
                    AS N_HYPO_PROFIT_LOSS
            FROM (SELECT PL.FIC_MIS_DATE,
                         SI.V_ACCOUNT_NUMBER AS V_INSTRUMENT_CODE,
                         SI.N_MKT_VALUE AS N_CURR_UNITS,
                         (NVL (
                             LEAD (
                                SI.N_MKT_VALUE)
                             OVER (
                                PARTITION BY SI.V_ACCOUNT_NUMBER
                                ORDER BY
                                   SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                             SI.N_MKT_VALUE))
                            AS N_PREV_UNITS,
                         PL.N_PRICE AS N_CURR_PRICE,
                         (NVL (
                             LEAD (
                                PL.N_PRICE)
                             OVER (
                                PARTITION BY SI.V_ACCOUNT_NUMBER
                                ORDER BY
                                   SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                             PL.N_PRICE))
                            AS N_PREV_PRICE
                    FROM    VW_BACKTESTING_PL PL
                         INNER JOIN
                            STG_INVESTMENTS SI
                         ON     SI.V_CUST_REF_CODE = PL.CODE
                            AND SI.FIC_MIS_DATE = PL.FIC_MIS_DATE
                            AND SI.V_PROD_CODE = 'TFC'
                            AND SI.V_EXP_CATEGORY_CODE = 'AFS'
                   WHERE     PL.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                         AND SI.FIC_MIS_DATE >= :LD_PREV_DATE)
           WHERE FIC_MIS_DATE = :L_FIC_MIS_DATE
          -- GROUP BY FIC_MIS_DATE, V_INSTRUMENT_CODE
          UNION
          /* SUKUKS */
          SELECT FIC_MIS_DATE,
                 'Sukuk' AS V_INSTRUMENT_TYPE,
                 V_INSTRUMENT_CODE,
                 ( (N_PREV_UNITS / N_PREV_PRICE) * N_CURR_PRICE) - N_PREV_UNITS
                    AS N_HYPO_PROFIT_LOSS
            FROM (SELECT SI.FIC_MIS_DATE,
                         SI.V_ACCOUNT_NUMBER AS V_INSTRUMENT_CODE,
                         (SI.N_MKT_VALUE) AS N_CURR_UNITS,
                         (NVL (
                             LEAD (
                                SI.N_MKT_VALUE)
                             OVER (
                                PARTITION BY SI.V_ACCOUNT_NUMBER
                                ORDER BY
                                   SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                             SI.N_MKT_VALUE))
                            AS N_PREV_UNITS,
                         (MKT.N_NET_PRESENT_VALUE) AS N_CURR_PRICE,
                         (NVL (
                             LEAD (
                                MKT.N_NET_PRESENT_VALUE)
                             OVER (
                                PARTITION BY SI.V_ACCOUNT_NUMBER
                                ORDER BY
                                   SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                             MKT.N_NET_PRESENT_VALUE))
                            AS N_PREV_PRICE
                    FROM    STG_INVESTMENTS SI
                         INNER JOIN
                            STG_MKT_INSTRUMENT_CONTRACT MKT
                         ON     SI.FIC_MIS_DATE = MKT.FIC_MIS_DATE
                            AND SI.V_INSTRUMENT_CODE = MKT.V_INSTRUMENT_CODE
                   WHERE     SI.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                         AND SI.FIC_MIS_DATE >= :LD_PREV_DATE
                         AND SI.V_PROD_DESC = 'SUK'
                         AND V_EXP_CATEGORY_CODE = 'AFS')
           WHERE FIC_MIS_DATE = :L_FIC_MIS_DATE
          --  GROUP BY FIC_MIS_DATE, V_INSTRUMENT_CODE
          UNION
            /* FX SPOT */
            SELECT FIC_MIS_DATE,
                   'FX' AS V_INSTRUMENT_TYPE,
                   V_INSTRUMENT_CODE,
                     (MAX (N_CURR_PRICE) * SUM (N_PREV_UNITS))
                   - (MAX (N_PREV_PRICE) * SUM (N_PREV_UNITS))
                      AS N_HYPO_PROFIT_LOSS
              FROM (SELECT SI.FIC_MIS_DATE,
                           CONCAT (SI.V_ACCOUNT_NUMBER, '-SPOT')
                              AS V_INSTRUMENT_CODE,
                           (SI.N_EOP_BAL) AS N_CURR_UNITS,
                           (NVL (
                               LEAD (
                                  SI.N_EOP_BAL)
                               OVER (
                                  PARTITION BY SI.V_ACCOUNT_NUMBER
                                  ORDER BY
                                     SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                               SI.N_EOP_BAL))
                              AS N_PREV_UNITS,
                           (FR.N_EXCHANGE_RATE) AS N_CURR_PRICE,
                           (NVL (
                               LEAD (
                                  FR.N_EXCHANGE_RATE)
                               OVER (
                                  PARTITION BY SI.V_ACCOUNT_NUMBER
                                  ORDER BY
                                     SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                               FR.N_EXCHANGE_RATE))
                              AS N_PREV_PRICE
                      FROM    STG_INVESTMENTS SI
                           INNER JOIN
                              STG_REF_FOREX_RATE FR
                           ON     SI.FIC_MIS_DATE = FR.FIC_MIS_DATE
                              AND SI.V_ACCOUNT_NUMBER = FR.V_FROM_CCY_CODE
                              AND FR.V_TO_CCY_CODE = 'PKR'
                     WHERE     SI.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                           AND SI.FIC_MIS_DATE >= :LD_PREV_DATE
                           AND SI.V_PROD_DESC = 'FXNOP'
                           AND SI.V_ACCOUNT_NUMBER IN
                                  ('USD', 'EUR', 'GBP', 'JPY')
                           AND FR.V_MARKET_RATE_TYPE_CODE = 'FX_SPOT')
             WHERE FIC_MIS_DATE = :L_FIC_MIS_DATE
          GROUP BY FIC_MIS_DATE, V_INSTRUMENT_CODE
          UNION
            /* FXFWD */
            SELECT FIC_MIS_DATE,
                   'FX' AS V_INSTRUMENT_TYPE,
                   V_INSTRUMENT_CODE,
                     --N_RESIDUAL_MATURITY,
                     (  (  SUM (N_PREV_POSITION)
                         / POWER (1 + MAX (N_CURR_INTEREST_RATE),
                                  (N_RESIDUAL_MATURITY / 360)))
                      * MAX (N_CURR_EXCHANGE_RATE))
                   - (  (  SUM (N_PREV_POSITION)
                         / POWER (1 + MAX (N_PREV_INTEREST_RATE),
                                  (N_RESIDUAL_MATURITY / 360)))
                      * MAX (N_PREV_EXCHANGE_RATE))
                      AS N_HYPO_PROFIT_LOSS
              FROM (SELECT SI.FIC_MIS_DATE,
                           SI.N_RESIDUAL_MATURITY,
                           SI.V_INSTRUMENT_CODE,
                           /*   CASE
                                 WHEN SI.V_ACCOUNT_NUMBER LIKE '%B'
                                 THEN
                                    CONCAT (SI.V_CCY_CODE, '-LONG')
                                 ELSE
                                    CONCAT (SI.V_CCY_CODE, '-SHORT')
                              END
                                 AS V_INSTRUMENT_CODE, */
                           (SI.N_EOP_BAL) AS N_CURR_POSITION,
                           (NVL (
                               LEAD (
                                  SI.N_EOP_BAL)
                               OVER (
                                  PARTITION BY SI.V_ACCOUNT_NUMBER
                                  ORDER BY
                                     SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                               SI.N_EOP_BAL))
                              AS N_PREV_POSITION,
                           (FR.N_EXCHANGE_RATE) AS N_CURR_EXCHANGE_RATE,
                           (IR.N_INTEREST_RATE) AS N_CURR_INTEREST_RATE,
                           (NVL (
                               LEAD (
                                  FR.N_EXCHANGE_RATE)
                               OVER (
                                  PARTITION BY SI.V_ACCOUNT_NUMBER
                                  ORDER BY
                                     SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                               FR.N_EXCHANGE_RATE))
                              AS N_PREV_EXCHANGE_RATE,
                           (NVL (
                               LEAD (
                                  IR.N_INTEREST_RATE)
                               OVER (
                                  PARTITION BY SI.V_ACCOUNT_NUMBER
                                  ORDER BY
                                     SI.V_ACCOUNT_NUMBER, SI.FIC_MIS_DATE DESC),
                               IR.N_INTEREST_RATE))
                              AS N_PREV_INTEREST_RATE
                      FROM STG_INVESTMENTS SI
                           INNER JOIN STG_REF_INTEREST_RATE IR
                              ON     SI.FIC_MIS_DATE = IR.FIC_MIS_DATE
                                 AND SI.V_CCY_CODE = IR.V_CCY_CD
                                 AND SI.N_RESIDUAL_MATURITY =
                                        IR.N_INTEREST_RATE_TERM * 30
                           INNER JOIN STG_REF_FOREX_RATE FR
                              ON     SI.FIC_MIS_DATE = FR.FIC_MIS_DATE
                                 AND SI.V_CCY_CODE = FR.V_FROM_CCY_CODE
                                 AND FR.V_TO_CCY_CODE = 'PKR'
                     WHERE     SI.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                           AND SI.FIC_MIS_DATE >= :LD_PREV_DATE
                           AND SI.V_PROD_DESC = 'FXFWDTNR'
                           AND SI.V_CCY_CODE IN ('USD', 'EUR', 'GBP', 'JPY')
                           AND FR.V_MARKET_RATE_TYPE_CODE = 'FX_SPOT'
                           AND IR.V_IRC_NAME LIKE 'LIBOR%')
             WHERE FIC_MIS_DATE = :L_FIC_MIS_DATE
          GROUP BY FIC_MIS_DATE, V_INSTRUMENT_CODE, N_RESIDUAL_MATURITY)
GROUP BY V_INSTRUMENT_TYPE