CREATE OR REPLACE FUNCTION OFSFTP.FTP_FN_POP_RT_TXN_TABLE (BATCHID   IN VARCHAR2,
                                                MISDATE   IN VARCHAR2)
   RETURN NUMBER
IS
   RESULT     NUMBER;

   MIS_DATE   DATE := TO_DATE (MISDATE, 'YYYYMMDD');
   BATCH_ID   VARCHAR2 (3);

   RETVAL     NUMBER;
BEGIN
   RESULT := 1;
   BATCH_ID :=
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
                XREF || '-' || BATCH_ID,
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
                BATCH_ID
           FROM OFSRECON.FTP_ACCOUNTING_ENTRIES
          WHERE FIC_MIS_DATE = MIS_DATE;

      COMMIT;

      INSERT INTO FTP_STTM_RT_TXN_CUSTOM_LOG (FIC_MIS_DATE,
                                              XREF,
                                              BRN,
                                              TXNAMT,
                                              STATUS,
                                              BATCH_ID,
                                              REMARKS)
         SELECT FIC_MIS_DATE,
                XREF || '-' || BATCH_ID,
                BRN,
                TXNAMT,
                STATUS,
                BATCH_ID,
                REMARKS
           FROM OFSRECON.FTP_ACCOUNTING_ENTRIES
          WHERE FIC_MIS_DATE = MIS_DATE;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.PUT_LINE ('Function failed: FTP_FN_POP_RT_TXN_TABLE');

         RESULT := 0;

         ROLLBACK;
   END;

   DBMS_OUTPUT.PUT_LINE ('Function successfull: FTP_FN_POP_RT_TXN_TABLE');

   COMMIT;

   RETURN RESULT;
END FTP_FN_POP_RT_TXN_TABLE;
/
