/* Formatted on 4/14/2022 11:55:03 AM (QP5 v5.215.12089.38647) */
SELECT N_ROW_NUM,
       FIC_MIS_dATE,
       PREVIOUS_DATE,
       '12-apr-2022' AS CALENDAR_DATE
  FROM (  SELECT ROWNUM AS N_ROW_NUM,
                 FIC_MIS_DATE,
                 LAG (FIC_MIS_DATE, 1) OVER (ORDER BY FIC_MIS_DATE)
                    AS PREVIOUS_DATE
            FROM (  SELECT FIC_MIS_DATE
                      FROM (SELECT FIC_MIS_DATE
                              FROM (SELECT D_CALENDAR_dATE AS FIC_MIS_DATE
                                      FROM dim_dates
                                     WHERE     D_CALENDAR_dATE <= '12-apr-2022'
                                           AND TO_CHAR (D_CALENDAR_dATE, 'DY') NOT IN
                                                  ('SUN', 'SAT')
                                           AND D_CALENDAR_dATE NOT IN
                                                  (SELECT DISTINCT
                                                          B.D_HOLIDAY_DATE
                                                     FROM OFSRECON.STG_HOLIDAYS_CALENDAR B
                                                    WHERE B.V_CALENDAR_SOURCE =
                                                             'P'))
                            UNION
                            SELECT D_CALENDAR_dATE AS FIC_MIS_DATE
                              FROM dim_dates
                             WHERE     D_CALENDAR_dATE >= '6-APR-2022'
                                   AND D_CALENDAR_dATE <= '12-apr-2022'
                                   AND TO_CHAR (D_CALENDAR_dATE, 'DY') IN ('SAT')
                                   AND D_CALENDAR_dATE NOT IN
                                          (SELECT DISTINCT B.D_HOLIDAY_DATE
                                             FROM OFSRECON.STG_HOLIDAYS_CALENDAR B
                                            WHERE B.V_CALENDAR_SOURCE = 'P'))
                  ORDER BY FIC_MIS_DATE DESC)
           WHERE ROWNUM < 313
        ORDER BY ROWNUM)
 WHERE N_ROW_NUM < 312