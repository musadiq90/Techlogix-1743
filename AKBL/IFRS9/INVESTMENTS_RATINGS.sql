/* Formatted on 4/2/2022 11:02:43 PM (QP5 v5.215.12089.38647) */
SELECT V_ACCOUNT_NUMBER,
       FIC_MIS_DATE,
       V_CUST_REF_CODE,
       V_RATING_cODE,
       RATING,
       V_PROD_CODE
  FROM (SELECT V_ACCOUNT_NUMBER,
               FIC_MIS_DATE,
               V_CUST_REF_CODE,
               V_RATING_cODE,
               N_ID,
               RATING,
               V_PROD_CODE,
               RANK () OVER (PARTITION BY V_PROD_CODE ORDER BY RATING, N_ID)
                  RATING_RANK
          FROM (  SELECT SI.FIC_MIS_DATE,
                         SI.V_CUST_REF_CODE,
                         CASE
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('AAA', 'AAA+', 'AAA-', 'Aaa')
                            THEN
                               1
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('AA', 'AA+', 'AA-', 'Aa1', 'Aa2', 'Aa3')
                            THEN
                               2
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('A', 'A+', 'A-', 'A1', 'A2', 'A3')
                            THEN
                               3
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('BBB',
                                     'BBB+',
                                     'BBB-',
                                     'Baa1',
                                     'Baa2',
                                     'Baa3')
                            THEN
                               4
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('BB', 'BB+', 'BB-', 'Ba1', 'Ba2', 'Ba3')
                            THEN
                               5
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('B', 'B+', 'B-', 'B1', 'B2', 'B3')
                            THEN
                               6
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('CCC',
                                     'CCC+',
                                     'CCC-',
                                     'Caa1',
                                     'Caa2',
                                     'Caa3')
                            THEN
                               7
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('CC', 'CC+', 'CC-', 'Ca')
                            THEN
                               8
                            WHEN SUBSTR (SARC.V_RATING_cODE,
                                         1,
                                         LENGTH (SARC.V_RATING_cODE) - 4) IN
                                    ('C', 'C+', 'C-', 'C')
                            THEN
                               9
                         END
                            AS RATING,
                         sarc.V_RATING_cODE,
                         SARC.V_aCCOUNT_NUMBER,
                         SI.V_PROD_CODE,
                         ROW_NUMBER () OVER (ORDER BY SARC.V_RATING_CODE)
                            AS N_ID
                    FROM    STG_INVESTMENTS SI
                         INNER JOIN
                            OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
                         ON     SI.FIC_MIS_dATE = SARC.FIC_MIS_dATE
                            AND SUBSTR (SARC.V_aCCOUNT_NUMBER, 1, 8) =
                                   SI.V_PROD_CODE
                   WHERE     SI.FIC_MIS_dATE = '30-SEP-2021'
                         AND SI.V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA'
                         AND (   SARC.V_RATING_cODE LIKE '%MOD'
                              OR SARC.V_RATING_cODE LIKE '%SNP'
                              OR SARC.V_RATING_cODE LIKE '%FIT')
                         AND SI.V_ACCOUNT_NUMBER IN (SELECT v_account_number
                                                       FROM (  SELECT SARD.V_aCCOUNT_NUMBER,
                                                                      COUNT (*)
                                                                 FROM    STG_INVESTMENTS INV
                                                                      INNER JOIN
                                                                         OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARD
                                                                      ON     INV.FIC_MIS_dATE =
                                                                                SARD.FIC_MIS_dATE
                                                                         AND SUBSTR (
                                                                                SARD.V_aCCOUNT_NUMBER,
                                                                                1,
                                                                                8) =
                                                                                INV.V_PROD_CODE
                                                                WHERE     INV.FIC_MIS_dATE =
                                                                             '30-SEP-2021'
                                                                      AND INV.V_BROKERAGE_FIRM =
                                                                             'VW_IFRS_GL_LEVEL_DATA'
                                                                      AND (   SARD.V_RATING_cODE LIKE
                                                                                 '%MOD'
                                                                           OR SARD.V_RATING_cODE LIKE
                                                                                 '%SNP'
                                                                           OR SARD.V_RATING_cODE LIKE
                                                                                 '%FIT')
                                                             GROUP BY SARD.V_aCCOUNT_NUMBER
                                                               HAVING COUNT (*) >
                                                                         1))
                ORDER BY SI.V_ACCOUNT_NUMBER))
 WHERE RATING_RANK = 2;



SELECT SARC.V_aCCOUNT_NUMBER,
       SI.V_ACCOUNT_NUMBER,
       SI.V_CUST_REF_CODE,
       SARC.V_RATING_cODE,
       SI.FIC_MIS_dATE
  FROM    STG_INVESTMENTS SI
       INNER JOIN
          OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
       ON     SI.FIC_MIS_dATE = SARC.FIC_MIS_dATE
          AND (   SARC.V_aCCOUNT_NUMBER = SI.V_aCCOUNT_NUMBER
               OR (SI.V_ACCOUNT_NUMBER = SUBSTR (SARC.V_ACCOUNT_NUMBER, 10)))
 WHERE SI.FIC_MIS_dATE = '30-SEP-2021' AND V_PROD_DESC IN ('TFC', 'SUKUK');



  SELECT V_ACCOUNT_NUMBER,
         FIC_MIS_DATE,
         V_CUST_REF_CODE,
         RATING
    FROM (  SELECT SI.FIC_MIS_DATE,
                   SI.V_CUST_REF_CODE,
                   CASE
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('AAA', 'AAA+', 'AAA-', 'Aaa')
                      THEN
                         1
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('AA', 'AA+', 'AA-', 'Aa1', 'Aa2', 'Aa3')
                      THEN
                         2
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('A', 'A+', 'A-', 'A1', 'A2', 'A3')
                      THEN
                         3
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('BBB', 'BBB+', 'BBB-', 'Baa1', 'Baa2', 'Baa3')
                      THEN
                         4
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('BB', 'BB+', 'BB-', 'Ba1', 'Ba2', 'Ba3')
                      THEN
                         5
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('B', 'B+', 'B-', 'B1', 'B2', 'B3')
                      THEN
                         6
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('CCC', 'CCC+', 'CCC-', 'Caa1', 'Caa2', 'Caa3')
                      THEN
                         7
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('CC', 'CC+', 'CC-', 'Ca')
                      THEN
                         8
                      WHEN SUBSTR (SARC.V_RATING_cODE,
                                   1,
                                   LENGTH (SARC.V_RATING_cODE) - 4) IN
                              ('C', 'C+', 'C-', 'C')
                      THEN
                         9
                   END
                      AS RATING,
                   sarc.V_RATING_cODE,
                   SARC.V_aCCOUNT_NUMBER
              FROM    STG_INVESTMENTS SI
                   INNER JOIN
                      OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARC
                   ON     SI.FIC_MIS_dATE = SARC.FIC_MIS_dATE
                      AND SUBSTR (SARC.V_aCCOUNT_NUMBER, 1, 8) = SI.V_PROD_CODE
             WHERE     SI.FIC_MIS_dATE = '30-SEP-2021'
                   AND SI.V_BROKERAGE_FIRM = 'VW_IFRS_GL_LEVEL_DATA'
                   AND (   SARC.V_RATING_cODE LIKE '%MOD'
                        OR SARC.V_RATING_cODE LIKE '%SNP'
                        OR SARC.V_RATING_cODE LIKE '%FIT')
                   AND SI.V_ACCOUNT_NUMBER IN (SELECT v_account_number
                                                 FROM (  SELECT SARD.V_aCCOUNT_NUMBER,
                                                                COUNT (*)
                                                           FROM    STG_INVESTMENTS INV
                                                                INNER JOIN
                                                                   OFSBASEL.STG_ACCOUNT_RATING_DETAILS SARD
                                                                ON     INV.FIC_MIS_dATE =
                                                                          SARD.FIC_MIS_dATE
                                                                   AND SUBSTR (
                                                                          SARD.V_aCCOUNT_NUMBER,
                                                                          1,
                                                                          8) =
                                                                          INV.V_PROD_CODE
                                                          WHERE     INV.FIC_MIS_dATE =
                                                                       '30-SEP-2021'
                                                                AND INV.V_BROKERAGE_FIRM =
                                                                       'VW_IFRS_GL_LEVEL_DATA'
                                                                AND (   SARD.V_RATING_cODE LIKE
                                                                           '%MOD'
                                                                     OR SARD.V_RATING_cODE LIKE
                                                                           '%SNP'
                                                                     OR SARD.V_RATING_cODE LIKE
                                                                           '%FIT')
                                                       GROUP BY SARD.V_aCCOUNT_NUMBER
                                                         HAVING COUNT (*) = 1))
          ORDER BY SI.V_ACCOUNT_NUMBER)
ORDER BY V_ACCOUNT_NUMBER;