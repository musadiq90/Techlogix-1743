SELECT   SI.FIC_MIS_DATE,
                           SI.V_ACCOUNT_NUMBER AS V_INSTRUMENT_CODE,
                           (SI.N_MKT_VALUE) AS N_CURR_UNITS,
                           (NVL (
                               LEAD(SI.N_MKT_VALUE)
                                  OVER (
                                     PARTITION BY SI.V_ACCOUNT_NUMBER
                                     ORDER BY
                                        SI.V_ACCOUNT_NUMBER,
                                        SI.FIC_MIS_DATE DESC
                                  ),
                               SI.N_MKT_VALUE
                            ))
                              AS N_PREV_UNITS,
                           (MKT.N_NET_PRESENT_VALUE) AS N_CURR_PRICE,
                           (NVL (
                               LEAD(MKT.N_NET_PRESENT_VALUE)
                                  OVER (
                                     PARTITION BY SI.V_ACCOUNT_NUMBER
                                     ORDER BY
                                        SI.V_ACCOUNT_NUMBER,
                                        SI.FIC_MIS_DATE DESC
                                  ),
                               MKT.N_NET_PRESENT_VALUE
                            ))
                              AS N_PREV_PRICE
                    FROM      STG_INVESTMENTS SI
                           INNER JOIN
                              STG_MKT_INSTRUMENT_CONTRACT MKT
                           ON SI.FIC_MIS_DATE = MKT.FIC_MIS_DATE
                              AND SI.V_CUST_REF_cODE = MKT.V_INSTRUMENT_CODE
                   WHERE       SI.FIC_MIS_DATE <= :MIS_DATE
                           AND SI.FIC_MIS_DATE >= :PREV_DATE
                           AND SI.V_PROD_DESC = 'TFC'
                           AND V_EXP_CATEGORY_CODE = 'AFS'
                           ORDER BY SI.V_ACCOUNT_NUMBER