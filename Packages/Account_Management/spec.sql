create or replace NONEDITIONABLE package account_management as 



PROCEDURE open_account(
    p_customer_id  IN NUMBER,
    p_account_type IN VARCHAR2,
    p_initial_dep  IN NUMBER,
    p_account_id   OUT NUMBER);
    
    
PROCEDURE close_account(
    P_ACCOUNT_NO IN VARCHAR2,
    p_reason     IN VARCHAR2);

    
PROCEDURE get_statement(
    p_account_id IN NUMBER,
    p_from_date  IN DATE,
    p_to_date    IN DATE,
    p_result     OUT SYS_REFCURSOR);    


FUNCTION get_account_json(
    p_account_id IN NUMBER)
RETURN CLOB;



end account_management;
