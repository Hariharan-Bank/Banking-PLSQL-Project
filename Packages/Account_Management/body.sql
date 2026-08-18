create or replace NONEDITIONABLE package body account_management as 

PROCEDURE open_account(
    p_customer_id  IN NUMBER,
    p_account_type IN VARCHAR2,
    p_initial_dep  IN NUMBER,
    p_account_id   OUT NUMBER)
    
    as 
    
    v_cust number ;
    v_customer_id number ;
    v_ACCOUNT_NO varchar2(200);
    N_ACC_NO varchar2(200);
    v_total_cnt NUMBER;


    begin 

     --SELECT get_acc INTO N_ACC_NO FROM DUAL;

   select count(*) into v_cust from customers where customer_id=p_customer_id;
   
   if v_cust=0 then 
    
    dbms_output.put_line ('CUSTOMER DETAILS NOT FOUND. PLEASE ADD THE CUSTOMER FIRST THEN CREATE ACCOUNT');
    
    RETURN;
          
   END IF; 
   
        SELECT COUNT(*)
        INTO v_total_cnt
        FROM accounts
        WHERE customer_id = p_customer_id;


      
        IF v_total_cnt >= 2 THEN

            DBMS_OUTPUT.PUT_LINE(
                'THIS CUSTOMER ALREADY HAS TWO ACCOUNTS'
            );

            RETURN;
            
        END IF;    
   
     select COUNT(*) INTO v_customer_id from accounts where customer_id=p_customer_id and UPPER(account_type) = UPPER(p_account_type) ;

     
     
     if v_customer_id >0 THEN 
     
     SELECT ACCOUNT_NO INTO v_ACCOUNT_NO FROM accounts where customer_id=p_customer_id and UPPER(account_type) = UPPER(p_account_type);

           dbms_output.put_line ('The given customer already have' || ' ' || UPPER(p_account_type) || '  account : '|| v_ACCOUNT_NO);
           
           RETURN;

       END IF;
       
       n_acc_no:= get_acc;
       
         insert into accounts  (
           ACCOUNT_ID,
           CUSTOMER_ID,
           ACCOUNT_NO,
           ACCOUNT_TYPE,
           BALANCE,
           STATUS,
           OPEN_DATE)values

           (
           account_seq.nextval,
           p_customer_id,
           N_ACC_NO, 
           p_account_type,
           p_initial_dep,
           'ACTIVE',
            (SYSDATE)
            )returning ACCOUNT_ID into p_ACCOUNT_ID;

            COMMIT;

            dbms_output.put_line ('ACCOUNT CREATED SUCCESSFULLY : '|| N_ACC_NO);
       

EXCEPTION
WHEN OTHERS THEN
  rollback;
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);

END open_account;


--------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE close_account(
    p_account_NO IN VARCHAR2,
    p_reason     IN VARCHAR2) AS 
    
V_COUNT NUMBER;
V_STATUS VARCHAR2(50);

BEGIN 

SELECT STATUS INTO V_STATUS FROM ACCOUNTS WHERE ACCOUNT_NO=p_account_NO;

   IF V_STATUS='CLOSED' THEN 
   
   dbms_output.put_line ('ACCOUNT ALREDY IN CLOSED STATE');
   
  ELSE 

SELECT COUNT (*) INTO V_COUNT FROM ACCOUNTS WHERE ACCOUNT_NO=p_account_NO;


   IF V_COUNT >0 THEN
   
         UPDATE ACCOUNTS SET STATUS='CLOSED',CLOSING_REASON=p_reason,CLOSED_DATE=SYSDATE  WHERE ACCOUNT_NO=p_account_NO;
         
         dbms_output.put_line ('ACCOUNT CLOSED SUCCESSFULLY : '|| p_account_NO || ' ' || ' REASON  FOR CLOSING ' || ' ' || p_reason);
   
         COMMIT;
         
   END IF;    
   
   END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN 
  rollback;

dbms_output.put_line ('INVALID ACCOUNT NO'); 

WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);

END close_account;

-----------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE get_statement(
    p_account_id IN NUMBER,
    p_from_date  IN DATE,
    p_to_date    IN DATE,
    p_result     OUT SYS_REFCURSOR)
    
    as
    BEGIN 
    open p_result for  select TXN_ID,
    
ACCOUNT_ID,
TXN_TYPE,
AMOUNT,
BALANCE_AFTER,
TXN_DATE,
CHANNEL,
STATUS,
REFERENCE_NO FROM TRANSACTIONS_TABLE WHERE ACCOUNT_ID=p_account_id AND 
TXN_DATE >= TRUNC(p_from_date) AND TXN_DATE < TRUNC(p_to_date)+1 
ORDER BY TXN_DATE;



EXCEPTION

WHEN OTHERS THEN

    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    
END    get_statement; 


-----------------------------------------------------------------------------------------------------------------------------------------


  FUNCTION get_account_json(
    p_account_id IN NUMBER)
  RETURN CLOB
  AS
   v_json clob;
  begin
  
  select json_object (
'ACCOUNT_ID' value ACCOUNT_ID,
'CUSTOMER_ID'    value        CUSTOMER_ID , 
'ACCOUNT_NO'     value        ACCOUNT_NO,
'ACCOUNT_TYPE'         value        ACCOUNT_TYPE,
'BALANCE'         value        BALANCE , 
'STATUS'       value       STATUS,
'OPEN_DATE'         value        OPEN_DATE      ,    
'CLOSED_DATE'     value      CLOSED_DATE,
'CLOSING_REASON'   value       CLOSING_REASON )

  into v_json from ACCOUNTS where ACCOUNT_ID=p_ACCOUNT_ID; 
  
   dbms_output.put_line (P_ACCOUNT_ID  ||':' || v_json );
   return v_json;
  
 
  
  exception
    when NO_DATA_FOUND then 
    
    v_json := 'NO_DATA_FOUND';
    
    return v_json;
    
END     get_account_json;
    

end account_management;
