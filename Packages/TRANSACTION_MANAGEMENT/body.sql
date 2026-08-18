create or replace NONEDITIONABLE PACKAGE BODY TRANSACTION_MANAGEMENT AS 

PROCEDURE deposit(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER,
    p_channel    IN VARCHAR2,
    p_reference  OUT VARCHAR2)
AS

V_STATUS VARCHAR2 (50);
V_COUNT NUMBER;
V_BAL NUMBER;
V_NEW_BAL NUMBER;
REFN VARCHAR2(100);

BEGIN
    SELECT COUNT(*) INTO V_COUNT FROM ACCOUNTS WHERE ACCOUNT_ID=p_account_id;

     IF V_COUNT >0 THEN 

        SELECT STATUS INTO V_STATUS FROM ACCOUNTS WHERE  ACCOUNT_ID=p_account_id;

        IF V_STATUS IN ('ACTIVE') THEN 

          SELECT BALANCE INTO V_BAL FROM  ACCOUNTS WHERE  ACCOUNT_ID=p_account_id;

          DBMS_OUTPUT.put_line ('OLD BALANCE ' || V_BAL);

          V_NEW_BAL := V_BAL+P_AMOUNT;

          UPDATE ACCOUNTS SET BALANCE=V_NEW_BAL WHERE  ACCOUNT_ID=p_account_id;


          DBMS_OUTPUT.put_line ('AMOUNT '|| P_AMOUNT || ' '|| 'DEPOSITED SUCCESSFULLY' );

          DBMS_OUTPUT.put_line ('AVAILABLE BALANCE ' || V_NEW_BAL);

          p_reference:= 'REF' || LPAD (REFN_SEQ.NEXTVAL,3,'0');

          INSERT INTO TRANSACTIONS_TABLE (TXN_ID,
                                          ACCOUNT_ID,
                                          TXN_TYPE,
                                          AMOUNT,
                                          BALANCE_AFTER,
                                          TXN_DATE,
                                          CHANNEL,
                                          STATUS,
                                          REFERENCE_NO) VALUES (TXN_seq_N.nextvaL,
                                          P_ACCOUNT_ID,
                                          'CREDIT',
                                          P_AMOUNT,
                                          V_NEW_BAL,
                                          SYSDATE,
                                          P_CHANNEL,
                                          'SUCCESS',
                                          p_reference); 



                                          COMMIT;

          DBMS_OUTPUT.put_line ('DATA INSERTED INTO TRANSACTION TABLE' );
          ELSE 
          DBMS_OUTPUT.put_line ('THE ACCOUNT IS INACIVE OR CLOSED' );
          RETURN;

          END IF;
           RETURN ;
        END IF;
        dbms_output.put_line ('INVALID ACCOUNT NO'); 

EXCEPTION
WHEN NO_DATA_FOUND THEN 
  rollback;

dbms_output.put_line ('INVALID ACCOUNT NO'); 

WHEN OTHERS THEN
rollback;

    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);

END     deposit;

-----------------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE withdraw(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER,
    p_channel    IN VARCHAR2,
    p_reference  OUT VARCHAR2)
as

V_STATUS VARCHAR2 (50);
V_COUNT NUMBER;
V_BAL NUMBER;
V_NEW_BAL NUMBER;
REFN VARCHAR2(100);

BEGIN


     SELECT COUNT(*) INTO V_COUNT FROM ACCOUNTS WHERE ACCOUNT_ID=p_account_id;

     IF V_COUNT >0 THEN 

        SELECT STATUS INTO V_STATUS FROM ACCOUNTS WHERE  ACCOUNT_ID=p_account_id;

        IF V_STATUS IN ('ACTIVE') THEN 

          SELECT BALANCE INTO V_BAL FROM  ACCOUNTS WHERE  ACCOUNT_ID=p_account_id;
          
          if (V_BAL>500 AND V_BAL>P_AMOUNT)then

          DBMS_OUTPUT.put_line ('OLD BALANCE ' || V_BAL);

          V_NEW_BAL := V_BAL-P_AMOUNT;

          UPDATE ACCOUNTS SET BALANCE=V_NEW_BAL WHERE  ACCOUNT_ID=p_account_id;


          DBMS_OUTPUT.put_line ('AMOUNT '|| P_AMOUNT || ' '|| 'WITHDRAw HAPPNED SUCCESSFULLY' );

          DBMS_OUTPUT.put_line ('AVAILABLE BALANCE ' || V_NEW_BAL);

          p_reference:= 'REF' || LPAD (REFN_SEQ.NEXTVAL,3,'0');

          INSERT INTO TRANSACTIONS_TABLE (TXN_ID,
                                          ACCOUNT_ID,
                                          TXN_TYPE,
                                          AMOUNT,
                                          BALANCE_AFTER,
                                          TXN_DATE,
                                          CHANNEL,
                                          STATUS,
                                          REFERENCE_NO) VALUES (TXN_seq_N.nextvaL,
                                          P_ACCOUNT_ID,
                                          'DEBIT',
                                          P_AMOUNT,
                                          V_NEW_BAL,
                                          SYSDATE,
                                          P_CHANNEL,
                                          'SUCCESS',
                                          p_reference); 



                                          COMMIT;

          DBMS_OUTPUT.put_line ('DATA INSERTED INTO TRANSACTION TABLE' );
          ELSE 
          DBMS_OUTPUT.put_line ('BALANCE NOT AVAILABLE MIN BALANCE IS 500 OR THE AMOUNT TRIED TO WITHDRAW IS MORE THE AVAILABLE BALANCE ' );
           END IF;
          RETURN;
          ELSE 
          DBMS_OUTPUT.put_line ('ACCOUNT IS INACTIVE OR CLOSED' );
          RETURN;
          END IF;
           RETURN ;
        END IF;
        dbms_output.put_line ('INVALID ACCOUNT NO'); 

EXCEPTION
WHEN NO_DATA_FOUND THEN 
  rollback;

dbms_output.put_line ('INVALID ACCOUNT NO'); 

WHEN OTHERS THEN
rollback;

    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);

END withdraw;

--------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE transfer_funds(
    p_from_account IN VARCHAR2,
    p_to_account   IN VARCHAR2,
    p_amount       IN NUMBER,
    p_reference    OUT VARCHAR2)
    
AS

V_F_A NUMBER;
V_T_A NUMBER;
V_STATUS_F VARCHAR2(50);
V_STATUS_T VARCHAR2(50);
V_NBAL NUMBER;
V_BAL_F NUMBER;
V_COUNT NUMBER;

BEGIN

SELECT COUNT (*) INTO V_COUNT FROM ACCOUNTS WHERE ACCOUNT_NO IN (p_from_account,p_to_account);

   IF V_COUNT <1 THEN 
       
       RAISE_APPLICATION_ERROR (-20001,'ACCOUNT NOT  FOUND');
       
   END IF;
   
   IF p_from_account=p_to_account THEN

         
         RAISE_APPLICATION_ERROR (-20002,'FROM AND TO ACCOUNT SHOULD NOT BE SAME');
       
   END IF;
   
   SELECT ACCOUNT_ID,STATUS,BALANCE INTO  V_F_A,V_STATUS_F,V_BAL_F FROM ACCOUNTS WHERE ACCOUNT_NO=p_from_account;
   
   SELECT ACCOUNT_ID,STATUS INTO  V_T_A,V_STATUS_T FROM ACCOUNTS WHERE ACCOUNT_NO=p_TO_account;
   
   IF V_STATUS_F<>'ACTIVE' THEN 
        
        RAISE_APPLICATION_ERROR (-20003,'FROM ACCOUNT IS NOT IN ACTIVE');
       
   END IF;
   
   IF V_STATUS_T<>'ACTIVE' THEN 
        
        RAISE_APPLICATION_ERROR (-20004,'TO ACCOUNT IS NOT IN ACTIVE');
       
   END IF;

   IF V_BAL_F < P_AMOUNT THEN 
   
        RAISE_APPLICATION_ERROR (-20005,'INSUFFICIENT BALANCE');
       
   END IF;
   
  
   UPDATE  ACCOUNTS SET balance=BALANCE-P_AMOUNT WHERE ACCOUNT_NO=P_FROM_ACCOUNT;
   
   DBMS_OUTPUT.put_line('AMOUNT DEBITED FROM FROM ACCOUNT');
   
   UPDATE  ACCOUNTS SET balance=BALANCE+P_AMOUNT WHERE ACCOUNT_NO=P_TO_ACCOUNT;
   
   DBMS_OUTPUT.put_line('AMOUNT CREDITED TO TO ACCOUNT');
   
    p_reference:= 'REF' || LPAD (REFN_SEQ.NEXTVAL,3,'0');
    
    INSERT INTO TRANSACTIONS_TABLE (TXN_ID,
                                          ACCOUNT_ID,
                                          TXN_TYPE,
                                          AMOUNT,
                                          BALANCE_AFTER,
                                          TXN_DATE,
                                          CHANNEL,
                                          STATUS,
                                          REFERENCE_NO,
                                          FROM_ACCOUNT,
                                          TO_ACCOUNT) VALUES (TXN_seq_N.nextvaL,
                                          NULL,
                                          'FUND TRANSFER',
                                          P_AMOUNT,
                                          NULL,
                                          SYSDATE,
                                          NULL,
                                          'SUCCESS',
                                          p_reference,
                                          V_F_A,
                                          V_T_A
                                          ); 



                                          COMMIT;

   DBMS_OUTPUT.put_line('DATA INSERTED IN TRANSACTION TABLE');
   
EXCEPTION
WHEN NO_DATA_FOUND THEN 
  rollback;

dbms_output.put_line ('INVALID ACCOUNT NO'); 

WHEN OTHERS THEN
rollback;

    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    
END transfer_funds;

--------------------------------------------------------------------------------------------------------------------------------------


FUNCTION get_txn_history_json(
    p_account_id IN NUMBER,
    p_from_date  IN DATE,
    p_to_date    IN DATE)
  RETURN CLOB
  


AS
   v_json clob;
  begin
  
  SELECT JSON_ARRAYAGG( json_object (
'TXN_ID' value TXN_ID,
'ACCOUNT_ID'    value        ACCOUNT_ID , 
'TXN_TYPE'     value        TXN_TYPE,
'AMOUNT'         value        AMOUNT,
'BALANCE_AFTER'         value        BALANCE_AFTER , 
'TXN_DATE'       value       TXN_DATE,
'CHANNEL'         value        CHANNEL      ,    
'STATUS'     value      STATUS,
'REFERENCE_NO'   value       REFERENCE_NO,
'FROM_ACCOUNT'   value       FROM_ACCOUNT,
'TO_ACCOUNT'   value       TO_ACCOUNT) RETURNING CLOB)

  into v_json from TRANSACTIONS_TABLE where ACCOUNT_ID=p_ACCOUNT_ID  AND 
TXN_DATE >= TRUNC(p_from_date) AND TXN_DATE < TRUNC(p_to_date)+1 
ORDER BY TXN_DATE;
  dbms_output.put_line (P_ACCOUNT_ID  ||':' || v_json );
   return v_json;
 
  
  
  exception
    when NO_DATA_FOUND then 
    
    v_json := 'NO_DATA_FOUND';
    
    return v_json;
    
END     get_txn_history_json;
  



END TRANSACTION_MANAGEMENT;
