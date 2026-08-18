create or replace NONEDITIONABLE PACKAGE
INTEREST_MGMT AS

  PROCEDURE calc_daily_interest;


  PROCEDURE apply_monthly_interest;

  FUNCTION calc_fd_maturity(
    p_principal  IN NUMBER,
    p_rate       IN NUMBER,
    p_months     IN NUMBER)
  RETURN NUMBER;


  FUNCTION calc_emi(
    p_principal  IN NUMBER,
    p_rate       IN NUMBER,
    p_months     IN NUMBER)
  RETURN NUMBER;


  FUNCTION calc_outstanding(
    p_loan_id IN NUMBER)
  RETURN NUMBER;


  FUNCTION get_interest_summary_json
  RETURN CLOB;

  -- Process overdue loans
  PROCEDURE process_overdue_loans;

END INTEREST_MGMT;
