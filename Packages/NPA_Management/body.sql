create or replace NONEDITIONABLE PACKAGE body npa_mgmt AS

PROCEDURE classify_npa

as
begin

        update npa_accounts set NPA_CATEGORY=(case when OVERDUE_DAYS <=90 then 'REGULAR'
                                                   WHEN OVERDUE_DAYS between 91 AND 365 THEN 'Sub Standard'
                                                   WHEN OVERDUE_DAYS between 366 AND 730 THEN 'Doubtful'
                                                   WHEN OVERDUE_DAYS >730  THEN 'Loss Asset' END ) ,CLASSIFIED_DATE=SYSDATE ;

       COMMIT;

EXCEPTION

  WHEN OTHERS THEN 
  ROLLBACK;
  dbms_output.put_line('ERROR: ' || SQLERRM);

end classify_npa;

------------------------------------------------------------------------------------------------------------------------------

PROCEDURE get_npa_report(
    p_category IN VARCHAR2,
    p_result   OUT SYS_REFCURSOR)

AS 

TYPE V_DE IS TABLE OF NPA_ACCOUNTS%ROWTYPE;

V_NPA V_DE;

BEGIN

   SELECT * BULK COLLECT INTO V_NPA FROM NPA_ACCOUNTS WHERE npa_category= p_category;

   IF V_NPA IS NOT NULL THEN

     OPEN  P_RESULT FOR 

      SELECT * FROM  NPA_ACCOUNTS WHERE npa_category= p_category;

      END IF;

exception 

   when NO_DATA_FOUND then

    dbms_output.put_line ('Category not found')  ;

    when others then

    dbms_output.put_line ('Error: ' || SQLERRM)  ;

end get_npa_report;

-----------------------------------------------------------------------------------------------

FUNCTION get_npa_summary_json
  RETURN CLOB

as
v_json clob;
begin 

select JSON_ARRAYAGG (json_object ('NPA_ID' value NPA_ID,
      'ACCOUNT_ID' value ACCOUNT_ID ,
      'LOAN_ID' value LOAN_ID,
      'OVERDUE_DAYS' value OVERDUE_DAYS,
      'OVERDUE_AMT' value OVERDUE_AMT,
      'NPA_CATEGORY' value NPA_CATEGORY ,
      'CLASSIFIED_DATE' value CLASSIFIED_DATE ,
      'STATUS' value STATUS )returning clob) into v_json from npa_accounts;


return v_json;


  exception
    when NO_DATA_FOUND then 

    v_json := 'NO_DATA_FOUND';

    return v_json;

END     get_npa_summary_json;

-------------------------------------------------------------------------------------------------------

 PROCEDURE update_npa_status(
    p_npa_id IN NUMBER,
    p_status IN VARCHAR2)

as 

v_c number;
v_OVERDUE_DAYS number;
V_STATUS VARCHAR2 (100);
begin

   select count (*) into v_c from npa_accounts where npa_id=p_npa_id;

   if v_c >0 then 

     select OVERDUE_DAYS,STATUS into v_OVERDUE_DAYS,V_STATUS from npa_accounts where npa_id=p_npa_id;

       if (v_OVERDUE_DAYS=0 OR v_OVERDUE_DAYS IS NULL )AND V_STATUS='ACTIVE' then 

        update npa_accounts set status=P_STATUS where npa_id=p_npa_id;

        ELSE 

            dbms_output.put_line('THE ACCOUNT DUE NOT YET COMPLTED OR ALREADY CLOSED');

        END IF;
    ELSE  
    dbms_output.put_line('ID NOT FOUND');

    END IF;

EXCEPTION 


  WHEN OTHERS THEN
   ROLLBACK;
      dbms_output.put_line('ERROR:' ||  SQLERRM);

END update_npa_status;

end npa_mgmt;
