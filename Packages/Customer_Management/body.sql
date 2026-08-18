create or replace NONEDITIONABLE PACKAGE body customer_management
as

PROCEDURE add_customer(
    p_first_name  IN VARCHAR2,
    p_last_name   IN VARCHAR2,
    p_email       IN VARCHAR2,
    p_phone       IN VARCHAR2,
    p_dob         IN DATE,
    p_customer_id OUT NUMBER) 
    as 
    
    v_count number;
    v_cust_id number;

    BEGIN

    select count(*) into v_count from customers where PHONE=p_phone;
    
    

    if v_count>0 then
    
    select customer_id into v_cust_id from customers where PHONE=p_phone;

    dbms_output.put_line ('The give phone number is already available :' || p_phone ||' '|| 'The customer id is :' || ' ' || v_cust_id );
     else 

    insert into customers (
    CUSTOMER_ID,
FIRST_NAME,
LAST_NAME,
EMAIL,
PHONE,
ADDRESS,
DOB,
KYC_STATUS,
CREATED_DATE) values (

CUSTOMER_SEQ.NEXTVAL,
p_first_name,
p_last_name,
p_email,
p_phone,
'',
p_dob ,
'PENDING',
SYSDATE
)
returning customer_id into p_customer_id;

commit;
dbms_output.put_line ('Customer details added' || 'Customer_id ' ||':' || p_customer_id);

END IF;



EXCEPTION

  WHEN OTHERS THEN
  rollback;
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END add_customer;

-----------------------------------------------------------------------------------------------------------------------------------------------


PROCEDURE update_kyc(
    p_customer_id IN NUMBER,
    p_kyc_status  IN VARCHAR2) as 
    
    v_cust_id number;
    v_status varchar2(100);
    begin
    
    select customer_id,kyc_status into v_cust_id,v_status from customers where customer_id=p_customer_id;
    
    if v_status <>'VERIFIED' then 
    
    update customers set kyc_status=p_kyc_status where customer_id=p_customer_id;
    
    dbms_output.put_line ('The customer id  : '|| p_customer_id ||' ' || 'kyc updated' );
    
    commit;
    
    else 
    
    dbms_output.put_line ('The customer id  : '|| p_customer_id ||' ' || 'kyc already done' );
    
    
    end if;
    

EXCEPTION

WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Customer id NOT FOUND');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    
    


end update_kyc;

--------------------------------------------------------------------------------------------------------------------------


FUNCTION get_customer_json(
    p_customer_id IN NUMBER)
  RETURN CLOB as 
  
  v_json clob;
  
  begin 
  
   select json_object (

'CUSTOMER_ID' value CUSTOMER_ID,
'FIRST_NAME'    value        FIRST_NAME , 
'LAST_NAME'     value        LAST_NAME,
'EMAIL'         value        EMAIL,
'PHONE'         value        PHONE , 
'ADDRESS'       value       ADDRESS,
'DOB'         value        DOB      ,    
'KYC_STATUS'     value      KYC_STATUS,
'CREATED_DATE'   value       CREATED_DATE )

  into v_json from customers where customer_id=p_customer_id; 
  
  return v_json;
  
  dbms_output.put_line (p_customer_id  ||':' || v_json );
  
  exception
    when NO_DATA_FOUND then 
    
    v_json := 'NO_DATA_FOUND';
    
    return v_json;
    

    
    end get_customer_json;
    
---------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE search_customers(
p_search_term IN VARCHAR2,
p_result      OUT SYS_REFCURSOR)

is 

type customer_record is table of customers%rowtype;

v_customers customer_record;

begin 

      select * bulk collect into v_customers from customers
      where (to_char(phone)=p_search_term or to_char(customer_id)=p_search_term 
      or email=p_search_term);
      
      if v_customers is not null then
      
      open p_result for 
        select * from customers
         where (to_char(phone)=p_search_term or to_char(customer_id)=p_search_term 
      or email=p_search_term);
      
     end if;
     

      
exception 

   when NO_DATA_FOUND then
 
    dbms_output.put_line ('Customer not found')  ;
    
    when others then
    
    dbms_output.put_line ('Error: ' || SQLERRM)  ;
      
end search_customers;



end customer_management;
