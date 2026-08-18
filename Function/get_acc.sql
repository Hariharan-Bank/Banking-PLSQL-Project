create or replace NONEDITIONABLE function get_acc (PARAMDATE  VARCHAR2 DEFAULT TO_CHAR(SYSDATE,'YYYY')) return VARCHAR2
as 

v_acc VARCHAR2 (100);

V_MAX NUMBER;

V_ACCOUNT VARCHAR2(20);

begin 

     v_acc := 'ACC';

     SELECT MAX(ACCOUNT_ID)+1 INTO V_MAX  FROM accounts;

     SELECT V_ACC||PARAMDATE||V_MAX INTO V_ACCOUNT from dual;

     RETURN V_ACCOUNT;

     EXCEPTION

        when NO_DATA_FOUND then 

    V_ACCOUNT := 'NO_DATA_FOUND';

    return V_ACCOUNT; 
END;
