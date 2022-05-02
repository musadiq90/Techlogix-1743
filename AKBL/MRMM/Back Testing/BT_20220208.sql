/* Formatted on 2/8/2022 11:01:58 AM (QP5 v5.215.12089.38647) */
DECLARE
   L_FIC_MIS_DATE           DATE := TO_DATE ('20211117', 'YYYYMMDD');
   LD_PREV_DATE             DATE := TO_DATE ('20211116', 'YYYYMMDD');
   LOOP_CTRL1               NUMBER;
   LOOP_CTRL2               NUMBER;
   LN_CURR_PRICE            NUMBER (10, 6);
   LN_PREV_PRICE            NUMBER (10, 6);
   LN_CINTERPOLATED_YIELD   NUMBER (10, 6);
   LN_PINTERPOLATED_YIELD   NUMBER (10, 6);
   LN_LOWER_TENOR           NUMBER;
   LN_UPPER_TENOR           NUMBER;
   LN_CURR_LTENOR_RATE      NUMBER (10, 6);
   LN_CURR_UTENOR_RATE      NUMBER (10, 6);
   LN_PREV_LTENOR_RATE      NUMBER (10, 6);
   LN_PREV_UTENOR_RATE      NUMBER (10, 6);
   LN_HYPOTHETICAL_PL       NUMBER (22, 6);
BEGIN
   FOR LOOP_CTRL1
      IN (SELECT FIC_MIS_DATE,
                 V_PROD_DESC AS V_INSTRUMENT_TYPE,
                 V_INSTRUMENT_CODE,
                 V_INST_PRICE_CODE,
                 F_REPRICE_FLAG,
                 N_PREV_POSITION,
                 CASE
                    WHEN N_RESIDUAL_MATURITY < 7 THEN 7
                    ELSE N_RESIDUAL_MATURITY
                 END
                    AS N_RESIDUAL_MATURITY,
                 D_MATURITY_DATE,
                 N_COUPON,
                 N_COUPON_FREQUENCY,
                 N_FACE_VALUE
            FROM (  SELECT FIC_MIS_DATE,
                           V_PROD_DESC,
                           D_MATURITY_DATE,
                           N_COUPON,
                           N_COUPON_FREQUENCY,
                           N_FACE_VALUE,
                           F_REPRICE_FLAG,
                           V_ACCOUNT_NUMBER AS V_INST_PRICE_CODE,
                           V_INSTRUMENT_CODE AS V_INSTRUMENT_CODE,
                           NVL (N_EOP_BAL, N_MKT_VALUE) AS N_CURR_POSITION,
                           NVL (
                              LEAD (
                                 NVL (N_EOP_BAL, N_MKT_VALUE))
                              OVER (
                                 PARTITION BY V_ACCOUNT_NUMBER
                                 ORDER BY V_ACCOUNT_NUMBER, FIC_MIS_DATE DESC),
                              NVL (N_EOP_BAL, N_MKT_VALUE))
                              AS N_PREV_POSITION,
                           (D_MATURITY_DATE - FIC_MIS_DATE)
                              AS N_RESIDUAL_MATURITY
                      FROM (SELECT SI.FIC_MIS_DATE,
                                   V_ACCOUNT_NUMBER AS V_INSTRUMENT_CODE,
                                   SI.V_PROD_DESC,
                                   SI.D_MATURITY_DATE,
                                   SI.N_COUPON,
                                   SI.N_COUPON_FREQUENCY,
                                   SI.N_FACE_VALUE,
                                   SI.F_REPRICE_FLAG,
                                   SI.N_EOP_BAL,
                                   SI.N_MKT_VALUE,
                                   CASE
                                      WHEN V_ACCOUNT_NUMBER LIKE 'PKFRV%'
                                      THEN
                                         V_ACCOUNT_NUMBER
                                      ELSE
                                         SUBSTR (V_ACCOUNT_NUMBER,
                                                 1,
                                                 LENGTH (V_ACCOUNT_NUMBER) - 6)
                                   END
                                      V_ACCOUNT_NUMBER
                              FROM STG_INVESTMENTS SI
                             WHERE     SI.FIC_MIS_DATE <= L_FIC_MIS_DATE
                                   AND SI.FIC_MIS_DATE >= LD_PREV_DATE
                                   AND SI.V_PROD_DESC IN ('TBILL', 'PIB'))
                  ORDER BY V_ACCOUNT_NUMBER)
           WHERE FIC_MIS_DATE = L_FIC_MIS_DATE)
   LOOP
      /* DBMS_OUTPUT.PUT_LINE (
             'FN_HYPOTHETICAL_PROFIT_LOSS: PIB/TBILL: PROD_CODE: '
          || LOOP_CTRL1.V_INSTRUMENT_TYPE
          || ' ACCOUNT_NUMBER: '
          || LOOP_CTRL1.V_INSTRUMENT_CODE); */


      SELECT LOWER_TENOR,
             UPPER_TENOR,
             N_CURR_LTENOR_RATE,
             N_CURR_UTENOR_RATE,
             N_PREV_LTENOR_RATE,
             N_PREV_UTENOR_RATE
        INTO LN_LOWER_TENOR,
             LN_UPPER_TENOR,
             LN_CURR_LTENOR_RATE,
             LN_CURR_UTENOR_RATE,
             LN_PREV_LTENOR_RATE,
             LN_PREV_UTENOR_RATE
        FROM (SELECT FIC_MIS_DATE,
                     LOWER_TENOR,
                     UPPER_TENOR,
                     LOWER_TENOR_RATE AS N_CURR_LTENOR_RATE,
                     UPPER_TENOR_RATE AS N_CURR_UTENOR_RATE,
                     LEAD (LOWER_TENOR_RATE)
                        OVER (ORDER BY FIC_MIS_DATE DESC)
                        AS N_PREV_LTENOR_RATE,
                     LEAD (UPPER_TENOR_RATE)
                        OVER (ORDER BY FIC_MIS_DATE DESC)
                        AS N_PREV_UTENOR_RATE
                FROM (  SELECT IR.FIC_MIS_DATE,
                               IR.V_IRC_NAME,
                               DECODE (IR.V_INTEREST_RATE_TERM_UNIT,
                                       'M', IR.N_INTEREST_RATE_TERM * 30,
                                       'Y', IR.N_INTEREST_RATE_TERM * 365,
                                       IR.N_INTEREST_RATE_TERM)
                                  AS LOWER_TENOR,
                               NVL (
                                  LEAD (
                                     DECODE (
                                        IR.V_INTEREST_RATE_TERM_UNIT,
                                        'M', IR.N_INTEREST_RATE_TERM * 30,
                                        'Y', IR.N_INTEREST_RATE_TERM * 365,
                                        IR.N_INTEREST_RATE_TERM))
                                  OVER (
                                     PARTITION BY IR.FIC_MIS_DATE,
                                                  IR.V_IRC_NAME
                                     ORDER BY
                                        IR.V_INTEREST_RATE_TERM_UNIT,
                                        IR.N_INTEREST_RATE_TERM),
                                  IR.N_INTEREST_RATE_TERM * 365)
                                  AS UPPER_TENOR,
                               IR.N_INTEREST_RATE AS LOWER_TENOR_RATE,
                               NVL (
                                  LEAD (
                                     IR.N_INTEREST_RATE)
                                  OVER (
                                     PARTITION BY IR.FIC_MIS_DATE,
                                                  IR.V_IRC_NAME
                                     ORDER BY
                                        IR.V_INTEREST_RATE_TERM_UNIT,
                                        IR.N_INTEREST_RATE_TERM),
                                  IR.N_INTEREST_RATE)
                                  AS UPPER_TENOR_RATE
                          FROM STG_REF_INTEREST_RATE IR
                         WHERE     IR.V_IRC_NAME = 'PKRV'
                               AND IR.FIC_MIS_DATE <= L_FIC_MIS_DATE
                               AND IR.FIC_MIS_DATE >= LD_PREV_DATE
                      ORDER BY IR.V_INTEREST_RATE_TERM_UNIT,
                               IR.N_INTEREST_RATE_TERM)
               WHERE     LOWER_TENOR <= LOOP_CTRL1.N_RESIDUAL_MATURITY
                     AND UPPER_TENOR > LOOP_CTRL1.N_RESIDUAL_MATURITY)
       WHERE FIC_MIS_DATE = L_FIC_MIS_DATE;

      --HANDLING CASE FOR STANDARD TENORS
      IF LN_LOWER_TENOR = LOOP_CTRL1.N_RESIDUAL_MATURITY
      THEN
         LN_CINTERPOLATED_YIELD := LN_CURR_LTENOR_RATE;

         LN_PINTERPOLATED_YIELD := LN_PREV_LTENOR_RATE;
      ELSE
         LN_CINTERPOLATED_YIELD :=
              LN_CURR_LTENOR_RATE
            +   (  (LN_CURR_UTENOR_RATE - LN_CURR_LTENOR_RATE)
                 / (LN_UPPER_TENOR - LN_LOWER_TENOR))
              * (LOOP_CTRL1.N_RESIDUAL_MATURITY - LN_LOWER_TENOR);

         LN_PINTERPOLATED_YIELD :=
              LN_PREV_LTENOR_RATE
            +   (  (LN_PREV_UTENOR_RATE - LN_PREV_LTENOR_RATE)
                 / (LN_UPPER_TENOR - LN_LOWER_TENOR))
              * (LOOP_CTRL1.N_RESIDUAL_MATURITY - LN_LOWER_TENOR);
      END IF;


      IF LOOP_CTRL1.V_INSTRUMENT_TYPE = 'TBILL'
      THEN
         LN_CURR_PRICE := LN_CINTERPOLATED_YIELD;


         LN_PREV_PRICE := LN_PINTERPOLATED_YIELD;
      ELSIF LOOP_CTRL1.V_INSTRUMENT_TYPE = 'PIB'
      THEN
         --PRICE(settlement,maturity,coupon_rate,yld,face_value,coupon_frequency,1);

         LN_CURR_PRICE :=
            FN_CALC_BOND_PRICE_ORIG (LOOP_CTRL1.FIC_MIS_DATE,
                                     LOOP_CTRL1.D_MATURITY_DATE,
                                     LOOP_CTRL1.N_COUPON,
                                     LOOP_CTRL1.N_COUPON_FREQUENCY,
                                     LN_CINTERPOLATED_YIELD,
                                     NULL,
                                     100,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL);

         LN_PREV_PRICE :=
            FN_CALC_BOND_PRICE_ORIG (LOOP_CTRL1.FIC_MIS_DATE,
                                     LOOP_CTRL1.D_MATURITY_DATE,
                                     LOOP_CTRL1.N_COUPON,
                                     LOOP_CTRL1.N_COUPON_FREQUENCY,
                                     LN_PINTERPOLATED_YIELD,
                                     NULL,
                                     100,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL);
      END IF;


      --LN_HYPOTHETICAL_PL := ((LOOP_CTRL1.N_PREV_POSITION/LN_PREV_PRICE)* LN_CURR_PRICE)/LOOP_CTRL1.N_PREV_POSITION;

      /*
           (LOOP_CTRL1.N_PREV_POSITION * LN_CURR_PRICE)
         - (LOOP_CTRL1.N_PREV_POSITION * LN_PREV_PRICE);

      INSERT INTO RPT_HYPOTHETICAL_PL (FIC_MIS_DATE,
                                       V_INSTRUMENT_TYPE,
                                       V_INSTRUMENT_CODE,
                                       N_HYPO_PROFIT_LOSS)
         SELECT L_FIC_MIS_DATE,
                LOOP_CTRL1.V_INSTRUMENT_TYPE,
                LOOP_CTRL1.V_INSTRUMENT_CODE,
                LN_HYPOTHETICAL_PL
           FROM DUAL; */
      DBMS_OUTPUT.PUT_LINE (
            LOOP_CTRL1.V_INST_PRICE_CODE
         || '|'
         || LOOP_CTRL1.V_INSTRUMENT_CODE
         || '|'
         || LOOP_CTRL1.V_INSTRUMENT_TYPE
         || '|'
         || LOOP_CTRL1.N_PREV_POSITION
         || '|'
         || LN_PREV_PRICE
         || '|'
         || LN_CURR_PRICE
         || '|'
         || LN_LOWER_TENOR
         || '|'
         || LN_UPPER_TENOR
         || '|'
         || LN_CURR_LTENOR_RATE
         || '|'
         || LN_CURR_UTENOR_RATE
         || '|'
         || LN_PREV_LTENOR_RATE
         || '|'
         || LN_PREV_UTENOR_RATE
         || '|'
         || LN_PINTERPOLATED_YIELD
         || '|'
         || LN_CINTERPOLATED_YIELD
         || '|'
         || LOOP_CTRL1.D_MATURITY_DATE
         || '|'
         || LOOP_CTRL1.N_COUPON
         || '|'
         || LOOP_CTRL1.N_COUPON_FREQUENCY);
   END LOOP;
END;