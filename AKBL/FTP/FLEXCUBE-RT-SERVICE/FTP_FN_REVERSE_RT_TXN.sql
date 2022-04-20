CREATE OR REPLACE FUNCTION OFSFTP.FTP_FN_REVERSE_RT_TXN (
   P_Xref      VARCHAR2,
   P_Status    VARCHAR2)
   RETURN BOOLEAN
IS
   -- PRAGMA AUTONOMOUS_TRANSACTION;
   ol_req             soap_api.t_request;
   ol_resp            soap_api.t_response;
   p_envelope         VARCHAR2 (32700);
   vg_funciton_fnc1   VARCHAR2 (256)
      := 'http://172.24.8.200:7030/FCUBSRTService/FCUBSRTService';
   vg_ws_address      VARCHAR2 (255)
      := 'http://172.24.8.200:7030/FCUBSRTService/FCUBSRTService?wsdl';
   l_result_clob      CLOB;
   l_rt_txn           FTP_STTM_RT_TXN_CUSTOM%ROWTYPE;
   l_error_code       VARCHAR2 (20 BYTE);
   l_error_desc       VARCHAR2 (105 BYTE);
   l_user_id          VARCHAR2 (20 BYTE);
   l_branch_code      VARCHAR2 (3 BYTE);
BEGIN
   BEGIN
      SELECT *
        INTO l_rt_txn
        FROM FTP_STTM_RT_TXN_CUSTOM
       WHERE XREF = P_Xref;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   IF (l_rt_txn.ISL_CONV = 'AKBL')
   THEN
      l_user_id := 'PHOENIX';
      l_branch_code := '959';
   ELSE
      l_user_id := 'PHOENIX';
      l_branch_code := '990';
   END IF;

   ol_req :=
      soap_api.new_request (vg_funciton_fnc1,
                            'xmlns="' || vg_ws_address || '"');

   p_envelope :=
         '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                            xmlns:fcub="http://fcubs.ofss.com/service/FCUBSRTService">
                            <soapenv:Header/>
                            <soapenv:Body>
                                <fcub:REVERSETRANSACTION_IOPK_REQ>
                                    <fcub:FCUBS_HEADER>
                                        <fcub:SOURCE>IBRSOURCE</fcub:SOURCE>
                                        <fcub:UBSCOMP>FCUBS</fcub:UBSCOMP>
                                        <fcub:USERID>'
      || l_user_id
      || '</fcub:USERID>
                                        <fcub:BRANCH>'
      || l_branch_code
      || '</fcub:BRANCH>
                                        <fcub:MODULEID>RT</fcub:MODULEID>
                                        <fcub:SERVICE>FCUBSRTService</fcub:SERVICE>
                                        <fcub:OPERATION>ReverseTransaction</fcub:OPERATION>
                                        <fcub:SOURCE_OPERATION>ReverseTransaction</fcub:SOURCE_OPERATION>
                                        <fcub:SOURCE_USERID>'
      || l_user_id
      || '</fcub:SOURCE_USERID>
                                        <fcub:ADDL>
                                            <fcub:PARAM>
                                                <fcub:NAME>SERVERSTAT</fcub:NAME>
                                                <fcub:VALUE>HOST</fcub:VALUE>
                                            </fcub:PARAM>
                                        </fcub:ADDL>
                                    </fcub:FCUBS_HEADER>
                                    <fcub:FCUBS_BODY>
                                       <fcub:Transaction-Details-IO>
                                          <fcub:XREF>'
      || l_rt_txn.XREF
      || '</fcub:XREF>
                                       </fcub:Transaction-Details-IO>
                                    </fcub:FCUBS_BODY>
                                </fcub:REVERSETRANSACTION_IOPK_REQ>
                            </soapenv:Body>
                        </soapenv:Envelope>';

   -- DBMS_OUTPUT.PUT_LINE ('p_envelope::' || p_envelope);
   /*  UPDATE FTP_STTM_RT_TXN_CUSTOM
     SET FCUBS_REQUEST = p_envelope
     WHERE XREF = P_Xref;
     */


   UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
      SET FCUBS_REQUEST = p_envelope
    WHERE XREF = P_Xref;


   BEGIN
      ol_resp :=
         soap_api.invoke (ol_req,
                          vg_ws_address,
                          vg_funciton_fnc1,
                          p_envelope);

      ol_resp.doc :=
         ol_resp.doc.EXTRACT (
               '/'
            || ol_resp.envelope_tag
            || ':Envelope/'
            || ol_resp.envelope_tag
            || ':Body/child::node()',
               'xmlns:'
            || ol_resp.envelope_tag
            || '="http://schemas.xmlsoap.org/soap/envelope/"');

      l_result_clob := ol_resp.doc.getclobval ();

      /*  UPDATE FTP_STTM_RT_TXN_CUSTOM
        SET FCUBS_RESPONSE = l_result_clob
        WHERE XREF = P_Xref;
        */

      UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
         SET FCUBS_RESPONSE = l_result_clob
       WHERE XREF = P_Xref;
   EXCEPTION
      WHEN OTHERS
      THEN
         UPDATE FTP_STTM_RT_TXN_CUSTOM
            SET STATUS = 'E',
                REMARKS = 'Error occurred while invoking request'
          WHERE XREF = P_Xref;


         UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
            SET STATUS = 'E',
                REMARKS = 'Error occurred while invoking request'
          WHERE XREF = P_Xref;



         RETURN FALSE;
   END;

   IF (INSTR (l_result_clob, 'FCUBS_ERROR_RESP') > 0)
   THEN
      SELECT SUBSTR (l_result_clob,
                       INSTR (l_result_clob,
                              'ECODE',
                              1,
                              1)
                     + 6,
                       INSTR (l_result_clob,
                              'ECODE',
                              1,
                              2)
                     - INSTR (l_result_clob,
                              'ECODE',
                              1,
                              1)
                     - 8)
        INTO l_error_code
        FROM DUAL;

      SELECT SUBSTR (l_result_clob,
                       INSTR (l_result_clob,
                              'EDESC',
                              1,
                              1)
                     + 6,
                       INSTR (l_result_clob,
                              'EDESC',
                              1,
                              2)
                     - INSTR (l_result_clob,
                              'EDESC',
                              1,
                              1)
                     - 8)
        INTO l_error_desc
        FROM DUAL;

      IF (P_Status = 'U')
      THEN
         UPDATE FTP_STTM_RT_TXN_CUSTOM
            SET STATUS = 'AE', REMARKS = l_error_desc
          WHERE XREF = P_Xref;


         UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
            SET STATUS = 'AE', REMARKS = l_error_desc
          WHERE XREF = P_Xref;
      ELSE
         UPDATE FTP_STTM_RT_TXN_CUSTOM
            SET STATUS = 'CE', REMARKS = l_error_desc
          WHERE XREF = P_Xref;


         UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
            SET STATUS = 'CE', REMARKS = l_error_desc
          WHERE XREF = P_Xref;
      END IF;

      COMMIT;
      RETURN FALSE;
   ELSIF (INSTR (l_result_clob, 'FCUBS_WARNING_RESP') > 0)
   THEN
      IF (P_Status = 'U')
      THEN
         UPDATE FTP_STTM_RT_TXN_CUSTOM
            SET STATUS = 'AA'
          WHERE XREF = P_Xref;

         UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
            SET STATUS = 'AA'
          WHERE XREF = P_Xref;
      ELSE
         UPDATE FTP_STTM_RT_TXN_CUSTOM
            SET STATUS = 'CA'
          WHERE XREF = P_Xref;


         UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
            SET STATUS = 'CA'
          WHERE XREF = P_Xref;
      END IF;

      COMMIT;
   ELSE
      IF (P_Status = 'U')
      THEN
         UPDATE FTP_STTM_RT_TXN_CUSTOM
            SET STATUS = 'AT'
          WHERE XREF = P_Xref;


         UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
            SET STATUS = 'AT'
          WHERE XREF = P_Xref;
      ELSE
         UPDATE FTP_STTM_RT_TXN_CUSTOM
            SET STATUS = 'CT'
          WHERE XREF = P_Xref;


         UPDATE FTP_STTM_RT_TXN_CUSTOM_LOG
            SET STATUS = 'CT'
          WHERE XREF = P_Xref;
      END IF;

      COMMIT;
      RETURN FALSE;
   END IF;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN FALSE;
END FTP_FN_REVERSE_RT_TXN;
/
