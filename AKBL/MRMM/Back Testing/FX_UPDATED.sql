  SELECT SUM(N_HYPO_PROFIT_LOSS) FROM ( SELECT   FIC_MIS_DATE,
                 'FX' AS V_INSTRUMENT_TYPE,
                 V_INSTRUMENT_CODE,
                 (MAX (N_CURR_PRICE) * SUM (N_PREV_UNITS))
                 - (MAX (N_PREV_PRICE) * SUM (N_PREV_UNITS))
                    AS N_HYPO_PROFIT_LOSS
          FROM   (SELECT   SI.FIC_MIS_DATE,
                           CONCAT (SI.V_ACCOUNT_NUMBER, '-SPOT')
                              AS V_INSTRUMENT_CODE,
                           (SI.N_EOP_BAL) AS N_CURR_UNITS,
                           (NVL (
                               LEAD(SI.N_EOP_BAL)
                                  OVER (
                                     PARTITION BY SI.V_ACCOUNT_NUMBER
                                     ORDER BY
                                        SI.V_ACCOUNT_NUMBER,
                                        SI.FIC_MIS_DATE DESC
                                  ),
                               SI.N_EOP_BAL
                            ))
                              AS N_PREV_UNITS,
                           (FR.N_EXCHANGE_RATE) AS N_CURR_PRICE,
                           (NVL (
                               LEAD(FR.N_EXCHANGE_RATE)
                                  OVER (
                                     PARTITION BY SI.V_ACCOUNT_NUMBER
                                     ORDER BY
                                        SI.V_ACCOUNT_NUMBER,
                                        SI.FIC_MIS_DATE DESC
                                  ),
                               FR.N_EXCHANGE_RATE
                            ))
                              AS N_PREV_PRICE
                    FROM      STG_INVESTMENTS SI
                           INNER JOIN
                              STG_REF_FOREX_RATE FR
                           ON     SI.FIC_MIS_DATE = FR.FIC_MIS_DATE
                              AND SI.V_ACCOUNT_NUMBER = FR.V_FROM_CCY_CODE
                              AND FR.V_TO_CCY_CODE = 'PKR'
                   WHERE       SI.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                           AND SI.FIC_MIS_DATE >= :LD_PREV_DATE
                           AND SI.V_PROD_DESC = 'FXNOP'
                           AND SI.V_ACCOUNT_NUMBER IN ('USD', 'EUR', 'GBP', 'JPY')
                           AND FR.V_MARKET_RATE_TYPE_CODE = 'FX_SPOT')
         WHERE   FIC_MIS_DATE = :L_FIC_MIS_DATE
      GROUP BY   FIC_MIS_DATE, V_INSTRUMENT_CODE
      UNION
        /* FXFWD */
        SELECT   FIC_MIS_DATE,
                 'FX' AS V_INSTRUMENT_TYPE,
                 V_INSTRUMENT_CODE,
                 --N_RESIDUAL_MATURITY,
                 ( (SUM (N_PREV_POSITION)
                    / POWER (1 + MAX (N_CURR_INTEREST_RATE),
                             (N_RESIDUAL_MATURITY / 360)))
                  * MAX (N_CURR_EXCHANGE_RATE))
                 - ( (SUM (N_PREV_POSITION)
                      / POWER (1 + MAX (N_PREV_INTEREST_RATE),
                               (N_RESIDUAL_MATURITY / 360)))
                    * MAX (N_PREV_EXCHANGE_RATE))
                    AS N_HYPO_PROFIT_LOSS
          FROM   (SELECT   SI.FIC_MIS_DATE,
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
                               LEAD(SI.N_EOP_BAL)
                                  OVER (
                                     PARTITION BY SI.V_ACCOUNT_NUMBER
                                     ORDER BY
                                        SI.V_ACCOUNT_NUMBER,
                                        SI.FIC_MIS_DATE DESC
                                  ),
                               SI.N_EOP_BAL
                            ))
                              AS N_PREV_POSITION,
                           (FR.N_EXCHANGE_RATE) AS N_CURR_EXCHANGE_RATE,
                           (IR.N_INTEREST_RATE) AS N_CURR_INTEREST_RATE,
                           (NVL (
                               LEAD(FR.N_EXCHANGE_RATE)
                                  OVER (
                                     PARTITION BY SI.V_ACCOUNT_NUMBER
                                     ORDER BY
                                        SI.V_ACCOUNT_NUMBER,
                                        SI.FIC_MIS_DATE DESC
                                  ),
                               FR.N_EXCHANGE_RATE
                            ))
                              AS N_PREV_EXCHANGE_RATE,
                           (NVL (
                               LEAD(IR.N_INTEREST_RATE)
                                  OVER (
                                     PARTITION BY SI.V_ACCOUNT_NUMBER
                                     ORDER BY
                                        SI.V_ACCOUNT_NUMBER,
                                        SI.FIC_MIS_DATE DESC
                                  ),
                               IR.N_INTEREST_RATE
                            ))
                              AS N_PREV_INTEREST_RATE
                    FROM         STG_INVESTMENTS SI
                              INNER JOIN
                                 STG_REF_INTEREST_RATE IR
                              ON SI.FIC_MIS_DATE = IR.FIC_MIS_DATE
                                 AND SI.V_CCY_CODE = IR.V_CCY_CD
                                 AND SI.N_RESIDUAL_MATURITY =
                                       IR.N_INTEREST_RATE_TERM * 30
                           INNER JOIN
                              STG_REF_FOREX_RATE FR
                           ON     SI.FIC_MIS_DATE = FR.FIC_MIS_DATE
                              AND SI.V_CCY_CODE = FR.V_FROM_CCY_CODE
                              AND FR.V_TO_CCY_CODE = 'PKR'
                   WHERE       SI.FIC_MIS_DATE <= :L_FIC_MIS_DATE
                           AND SI.FIC_MIS_DATE >= :LD_PREV_DATE
                           AND SI.V_PROD_DESC = 'FXFWDTNR'
                           AND SI.V_CCY_CODE IN ('USD', 'EUR', 'GBP', 'JPY')
                           AND FR.V_MARKET_RATE_TYPE_CODE = 'FX_SPOT'
                           AND IR.V_IRC_NAME LIKE 'LIBOR%')
         WHERE   FIC_MIS_DATE = :L_FIC_MIS_DATE
      GROUP BY   FIC_MIS_DATE, V_INSTRUMENT_CODE, N_RESIDUAL_MATURITY)