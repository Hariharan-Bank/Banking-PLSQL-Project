create or replace NONEDITIONABLE package customer_management 
as 

PROCEDURE add_customer(
    p_first_name  IN VARCHAR2,
    p_last_name   IN VARCHAR2,
    p_email       IN VARCHAR2,
    p_phone       IN VARCHAR2,
    p_dob         IN DATE,
    p_customer_id OUT NUMBER);

PROCEDURE update_kyc(
    p_customer_id IN NUMBER,
    p_kyc_status  IN VARCHAR2);
    
    
FUNCTION get_customer_json(
    p_customer_id IN NUMBER)
  RETURN CLOB;
    
    
PROCEDURE search_customers(
p_search_term IN VARCHAR2,
p_result      OUT SYS_REFCURSOR);
    
    
end customer_management;
