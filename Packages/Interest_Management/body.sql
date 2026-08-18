create or replace NONEDITIONABLE PACKAGE body
INTEREST_MGMT AS
PROCEDURE calc_daily_interest AS

  
  TYPE interest_rec IS RECORD(
    account_id NUMBER,
    balance    NUMBER,
    rate       NUMBER,
    daily_int  NUMBER);

  TYPE interest_tab IS TABLE OF
  interest_rec;

  v_interest interest_tab :=
  interest_tab();

  v_rate    NUMBER;
  v_daily   NUMBER;
  v_count   NUMBER := 0;

BEGIN
  DBMS_OUTPUT.PUT_LINE(
  '=== Daily Interest Calculation ===');
  DBMS_OUTPUT.PUT_LINE(
  'Date: ' || TO_CHAR(SYSDATE,
  'DD-MM-YYYY'));

  -- Loop through all active
  -- savings accounts
  FOR rec IN (
    SELECT a.account_id,
           a.balance,
           a.account_type
    FROM accounts a
    WHERE a.status = 'ACTIVE'
    AND a.account_type = 'SAVINGS'
    AND a.balance > 0)
  LOOP
    -- Get interest rate from
    -- interest_rates table
    BEGIN
      SELECT rate INTO v_rate
      FROM interest_rates
      WHERE account_type =
            rec.account_type
      AND SYSDATE BETWEEN
          effective_from
          AND effective_to;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_rate := 4.0; -- Default rate
    END;

    -- Calculate daily interest
    -- Annual rate / 365 days
    v_daily := ROUND(
    rec.balance * v_rate / 100 / 365,
    2);

    -- Store in interest_log table
    INSERT INTO interest_log(
      log_id,
      account_id,
      log_date,
      balance,
      rate,
      daily_interest,
      status)
    VALUES(
      interest_log_seq.NEXTVAL,
      rec.account_id,
      TRUNC(SYSDATE),
      rec.balance,
      v_rate,
      v_daily,
      'PENDING');

    v_count := v_count + 1;

    DBMS_OUTPUT.PUT_LINE(
    'Account: ' || rec.account_id ||
    ' Balance: ' || rec.balance ||
    ' Rate: ' || v_rate ||
    ' Daily Int: ' || v_daily);

  END LOOP;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE(
  'Total accounts processed: '
  || v_count);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(
    'ERROR: ' || SQLERRM);
END calc_daily_interest;

---------------------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE apply_monthly_interest AS

  -- Collect all accounts
  -- with pending interest
  TYPE acc_type IS TABLE OF NUMBER;
  v_accounts acc_type;

  v_total_interest NUMBER;
  v_new_balance    NUMBER;
  v_count          NUMBER := 0;

BEGIN
  DBMS_OUTPUT.PUT_LINE(
  '=== Monthly Interest Application ===');

  -- Get all accounts with
  -- pending daily interest
  SELECT DISTINCT account_id
  BULK COLLECT INTO v_accounts
  FROM interest_log
  WHERE status = 'PENDING'
  AND EXTRACT(MONTH FROM log_date)
    = EXTRACT(MONTH FROM SYSDATE)
  AND EXTRACT(YEAR FROM log_date)
    = EXTRACT(YEAR FROM SYSDATE);

  -- Process each account
  FOR i IN 1..v_accounts.COUNT LOOP

    -- Sum all pending daily interest
    SELECT SUM(daily_interest)
    INTO v_total_interest
    FROM interest_log
    WHERE account_id = v_accounts(i)
    AND status = 'PENDING';

    -- Round to 2 decimal places
    v_total_interest :=
    ROUND(v_total_interest, 2);

    -- Get current balance
    SELECT balance INTO v_new_balance
    FROM accounts
    WHERE account_id = v_accounts(i);

    -- Add interest to balance
    v_new_balance :=
    v_new_balance + v_total_interest;

    -- Update account balance
    UPDATE accounts
    SET balance = v_new_balance
    WHERE account_id = v_accounts(i);

    -- Insert transaction record
    INSERT INTO transactions_table(
      txn_id, account_id,
      txn_type, amount,
      balance_after, txn_date,
      channel, status,
      reference_no)
    VALUES(
      txn_seq_n.NEXTVAL,
      v_accounts(i),
      'INTEREST',
      v_total_interest,
      v_new_balance,
      SYSDATE,
      'SYSTEM',
      'SUCCESS',
      'INT' || TO_CHAR(SYSDATE,
      'MMYYYY') ||
      LPAD(v_accounts(i), 6, '0'));

    -- Mark interest as applied
    UPDATE interest_log
    SET status = 'APPLIED',
        applied_date = SYSDATE
    WHERE account_id = v_accounts(i)
    AND status = 'PENDING';

    v_count := v_count + 1;

    DBMS_OUTPUT.PUT_LINE(
    'Account: ' || v_accounts(i) ||
    ' Interest Applied: ' ||
    v_total_interest ||
    ' New Balance: ' || v_new_balance);

  END LOOP;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE(
  '================================');
  DBMS_OUTPUT.PUT_LINE(
  'Total accounts credited: '
  || v_count);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(
    'ERROR: ' || SQLERRM);
END apply_monthly_interest;
----------------------------------------------------------------------------------------------------------------------
FUNCTION calc_fd_maturity(
  p_principal IN NUMBER,
  p_rate      IN NUMBER,
  p_months    IN NUMBER)
RETURN NUMBER AS

  v_maturity  NUMBER;
  v_rate_m    NUMBER;

BEGIN
  -- Convert annual rate to monthly
  v_rate_m := p_rate / 100 / 12;

  -- Compound interest formula
  -- Monthly compounding
  v_maturity := ROUND(
    p_principal *
    POWER(1 + v_rate_m, p_months),
    2);

  DBMS_OUTPUT.PUT_LINE(
  'Principal   : ' || p_principal);
  DBMS_OUTPUT.PUT_LINE(
  'Rate        : ' || p_rate || '%');
  DBMS_OUTPUT.PUT_LINE(
  'Tenure      : ' || p_months ||
  ' months');
  DBMS_OUTPUT.PUT_LINE(
  'Maturity    : ' || v_maturity);
  DBMS_OUTPUT.PUT_LINE(
  'Interest    : ' ||
  (v_maturity - p_principal));

  RETURN v_maturity;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(
    'ERROR: ' || SQLERRM);
    RETURN 0;
END calc_fd_maturity;
---------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION calc_emi(
  p_principal IN NUMBER,
  p_rate      IN NUMBER,
  p_months    IN NUMBER)
RETURN NUMBER AS

  v_emi    NUMBER;
  v_rate_m NUMBER;

BEGIN
  -- Monthly interest rate
  v_rate_m := p_rate / 100 / 12;

  -- EMI Formula:
  -- P × R × (1+R)^N / ((1+R)^N - 1)
  v_emi := ROUND(
    p_principal *
    v_rate_m *
    POWER(1 + v_rate_m, p_months) /
    (POWER(1 + v_rate_m, p_months) - 1),
    2);

  DBMS_OUTPUT.PUT_LINE(
  'Loan Amount : ₹' || p_principal);
  DBMS_OUTPUT.PUT_LINE(
  'Interest    : ' || p_rate || '% pa');
  DBMS_OUTPUT.PUT_LINE(
  'Tenure      : ' || p_months ||
  ' months');
  DBMS_OUTPUT.PUT_LINE(
  'EMI Amount  : ₹' || v_emi);
  DBMS_OUTPUT.PUT_LINE(
  'Total Payment: ₹' ||
  ROUND(v_emi * p_months, 2));
  DBMS_OUTPUT.PUT_LINE(
  'Total Interest: ₹' ||
  ROUND((v_emi * p_months)
  - p_principal, 2));

  RETURN v_emi;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(
    'ERROR: ' || SQLERRM);
    RETURN 0;
END calc_emi;
--------------------------------------------------------------------------------------------------------------------
FUNCTION calc_outstanding(
  p_loan_id IN NUMBER)
RETURN NUMBER AS

  v_principal  NUMBER;
  v_rate       NUMBER;
  v_start_date DATE;
  v_months_paid NUMBER;
  v_emi        NUMBER;
  v_outstanding NUMBER;
  v_rate_m     NUMBER;
  v_tenure     NUMBER;

BEGIN
  -- Get loan details
  SELECT amount, interest_rate,
         start_date, tenure_months
  INTO v_principal, v_rate,
       v_start_date, v_tenure
  FROM loans
  WHERE loan_id = p_loan_id;

  -- Calculate months paid so far
  v_months_paid := FLOOR(
    MONTHS_BETWEEN(SYSDATE,
    v_start_date));

  -- Monthly rate
  v_rate_m := v_rate / 100 / 12;

  -- Calculate EMI
  v_emi := ROUND(
    v_principal * v_rate_m *
    POWER(1 + v_rate_m, v_tenure) /
    (POWER(1 + v_rate_m, v_tenure) - 1),
    2);

  -- Outstanding balance formula
  v_outstanding := ROUND(
    v_principal *
    POWER(1 + v_rate_m, v_months_paid) -
    v_emi *
    (POWER(1 + v_rate_m, v_months_paid) - 1)
    / v_rate_m,
    2);

  DBMS_OUTPUT.PUT_LINE(
  'Loan ID     : ' || p_loan_id);
  DBMS_OUTPUT.PUT_LINE(
  'Principal   : ₹' || v_principal);
  DBMS_OUTPUT.PUT_LINE(
  'Months Paid : ' || v_months_paid);
  DBMS_OUTPUT.PUT_LINE(
  'EMI Amount  : ₹' || v_emi);
  DBMS_OUTPUT.PUT_LINE(
  'Outstanding : ₹' || v_outstanding);

  RETURN v_outstanding;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE
    ('Loan not found!');
    RETURN 0;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(
    'ERROR: ' || SQLERRM);
    RETURN 0;
END calc_outstanding;

------------------------------------------------------------------------------------------------------------------------

PROCEDURE process_overdue_loans AS

  TYPE loan_rec IS RECORD(
    loan_id    NUMBER,
    customer_id NUMBER,
    account_id NUMBER,
    overdue_days NUMBER,
    overdue_amt  NUMBER);

  TYPE loan_tab IS TABLE OF loan_rec;
  v_loans loan_tab := loan_tab();

  v_count NUMBER := 0;

BEGIN
  DBMS_OUTPUT.PUT_LINE(
  '=== Processing Overdue Loans ===');

  -- Find all overdue loans
  FOR rec IN (
    SELECT l.loan_id,
           l.customer_id,
           a.account_id,
           TRUNC(SYSDATE) -
           TRUNC(l.start_date)
           AS overdue_days,
           l.emi_amount
    FROM loans l
    JOIN accounts a
    ON l.customer_id = a.customer_id
    WHERE l.status = 'OVERDUE'
    AND TRUNC(SYSDATE) -
        TRUNC(l.start_date) > 90)
  LOOP
    -- Update NPA table
    MERGE INTO npa_accounts npa
    USING (SELECT rec.loan_id
           FROM DUAL) src
    ON (npa.loan_id = rec.loan_id)
    WHEN MATCHED THEN
      UPDATE SET
        overdue_days = rec.overdue_days,
        npa_category =
          CASE
            WHEN rec.overdue_days
                 BETWEEN 91 AND 365
            THEN 'Sub Standard'
            WHEN rec.overdue_days
                 BETWEEN 366 AND 730
            THEN 'Doubtful'
            ELSE 'Loss Asset'
          END,
        classified_date = SYSDATE
    WHEN NOT MATCHED THEN
      INSERT VALUES(
        npa_seq.NEXTVAL,
        rec.account_id,
        rec.loan_id,
        rec.overdue_days,
        rec.emi_amount,
        CASE
          WHEN rec.overdue_days
               BETWEEN 91 AND 365
          THEN 'Sub Standard'
          WHEN rec.overdue_days
               BETWEEN 366 AND 730
          THEN 'Doubtful'
          ELSE 'Loss Asset'
        END,
        SYSDATE,
        'ACTIVE');

    v_count := v_count + 1;

    DBMS_OUTPUT.PUT_LINE(
    'Loan: ' || rec.loan_id ||
    ' Overdue: ' || rec.overdue_days ||
    ' days');

  END LOOP;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE(
  'Total overdue loans: ' || v_count);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(
    'ERROR: ' || SQLERRM);
END process_overdue_loans;

-----------------------------------------------------------------------------------------------------------------------------------------------------

FUNCTION get_interest_summary_json
RETURN CLOB AS

  v_json CLOB;

BEGIN
  SELECT JSON_OBJECT(
    'summary_date' VALUE
      TO_CHAR(SYSDATE, 'DD-MM-YYYY'),
    'savings_accounts' VALUE (
      SELECT JSON_OBJECT(
        'total_accounts' VALUE
          COUNT(*),
        'total_balance' VALUE
          SUM(balance),
        'total_interest_ytd' VALUE
          ROUND(SUM(balance) * 4/100, 2))
      FROM accounts
      WHERE account_type = 'SAVINGS'
      AND status = 'ACTIVE'),
    'loans' VALUE (
      SELECT JSON_OBJECT(
        'total_loans' VALUE COUNT(*),
        'total_outstanding' VALUE
          SUM(amount),
        'overdue_loans' VALUE
          SUM(CASE WHEN status = 'OVERDUE'
              THEN 1 ELSE 0 END))
      FROM loans),
    'npa_summary' VALUE (
      SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
          'category' VALUE npa_category,
          'count' VALUE COUNT(*),
          'total_overdue' VALUE
            SUM(overdue_amt)))
      FROM npa_accounts
      WHERE status = 'ACTIVE'
      GROUP BY npa_category))
  INTO v_json
  FROM DUAL;

  RETURN v_json;

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(
    'ERROR: ' || SQLERRM);
    RETURN NULL;
END get_interest_summary_json;

end INTEREST_MGMT;
