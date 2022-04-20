CREATE OR REPLACE FUNCTION OFSFTP.FTP_FN_POP_RT_TXN_TABLE_REVERSAL (
   BATCHID   IN VARCHAR2,
   MISDATE   IN VARCHAR2)
   RETURN NUMBER
IS
   RESULT        NUMBER;

   MIS_DATE      DATE := TO_DATE (MISDATE, 'YYYYMMDD');
   LV_BATCH_ID   VARCHAR2 (3);

   RETVAL        NUMBER;
BEGIN
   RESULT := 1;
   LV_BATCH_ID :=
      SUBSTR (
         SUBSTR (BATCHID, -10),
         INSTR (SUBSTR (BATCHID, -10), '_') - LENGTH (SUBSTR (BATCHID, -10)));

   BEGIN
      INSERT INTO FTP_STTM_RT_TXN_CUSTOM (FIC_MIS_DATE,
                                          XREF,
                                          ORIG_XREF,
                                          PRD,
                                          BRN,
                                          ISL_CONV,
                                          TXNBRN,
                                          TXNACC,
                                          TXNCCY,
                                          TXNAMT,
                                          OFFSETBRN,
                                          OFFSETACC,
                                          OFFSETCCY,
                                          NARRATIVE,
                                          STATUS,
                                          REMARKS,
                                          BATCH_ID)
         SELECT FIC_MIS_DATE,
                ORIG_XREF || '-R' || LV_BATCH_ID,
                ORIG_XREF,
                PRD,
                BRN,
                ISL_CONV,
                TXNBRN,
                TXNACC,
                TXNCCY,
                TXNAMT,
                OFFSETBRN,
                OFFSETACC,
                OFFSETCCY,
                'REVERSAL OF ' || NARRATIVE,
                 STATUS,
                NULL REMARKS,
                'R' || LV_BATCH_ID
           FROM FTP_STTM_RT_TXN_CUSTOM TX
          WHERE        FIC_MIS_DATE = MIS_DATE
                   AND REGEXP_REPLACE (TX.BATCH_ID, '(\D)', '') =
                          LV_BATCH_ID - 1
                   AND STATUS IN ('AA')
                OR (    REGEXP_REPLACE (BATCH_ID, '(\d)', '') = 'R'
                    AND STATUS IN ('CE'));



      COMMIT;

      INSERT INTO FTP_STTM_RT_TXN_CUSTOM_LOG (FIC_MIS_DATE,
                                              XREF,
                                              BRN,
                                              TXNAMT,
                                              STATUS,
                                              BATCH_ID,
                                              REMARKS)
         SELECT FIC_MIS_DATE,
                ORIG_XREF || '-R' || LV_BATCH_ID,
                BRN,
                TXNAMT,
                 STATUS,
                'R' || LV_BATCH_ID,
                NULL REMARKS
           FROM FTP_STTM_RT_TXN_CUSTOM TX
          WHERE        FIC_MIS_DATE = MIS_DATE
                   AND REGEXP_REPLACE (TX.BATCH_ID, '(\D)', '') =
                          LV_BATCH_ID - 1
                   AND STATUS IN ('AA')
                OR (    REGEXP_REPLACE (BATCH_ID, '(\d)', '') = 'R'
                    AND STATUS IN ('CE'));

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE (
            'Function failed: FTP_FN_POP_RT_TXN_TABLE_REVERSAL');

         RESULT := 0;

         ROLLBACK;
   END;

   DBMS_OUTPUT.PUT_LINE (
      'Function successfull: FTP_FN_POP_RT_TXN_TABLE_REVERSAL');

   COMMIT;

   RETURN RESULT;
END FTP_FN_POP_RT_TXN_TABLE_REVERSAL;
/
