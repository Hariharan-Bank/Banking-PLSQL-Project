create or replace NONEDITIONABLE PACKAGE TRANSACTION_MANAGEMENT AS 

PROCEDURE deposit(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER,
    p_channel    IN VARCHAR2,
    p_reference  OUT VARCHAR2);
    
    
PROCEDURE withdraw(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER,
    p_channel    IN VARCHAR2,
    p_reference  OUT VARCHAR2);



PROCEDURE transfer_funds(
    p_from_account IN VARCHAR2,
    p_to_account   IN VARCHAR2,
    p_amount       IN NUMBER,
    p_reference    OUT VARCHAR2);
    

FUNCTION get_txn_history_json(
    p_account_id IN NUMBER,
    p_from_date  IN DATE,
    p_to_date    IN DATE)
  RETURN CLOB;


    
END TRANSACTION_MANAGEMENT;
