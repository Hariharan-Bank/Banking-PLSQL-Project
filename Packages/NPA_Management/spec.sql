create or replace NONEDITIONABLE PACKAGE npa_mgmt AS

PROCEDURE classify_npa;

PROCEDURE get_npa_report(
    p_category IN VARCHAR2,
    p_result   OUT SYS_REFCURSOR);
    
FUNCTION get_npa_summary_json
  RETURN CLOB;
  
PROCEDURE update_npa_status(
    p_npa_id IN NUMBER,
    p_status IN VARCHAR2);
    
end npa_mgmt;
