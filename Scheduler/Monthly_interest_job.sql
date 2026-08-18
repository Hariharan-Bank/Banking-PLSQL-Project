BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'Monthly_INTEREST',
    job_type => 'STORED_PROCEDURE',
    job_action => 'INTEREST_MGMT.apply_monthly_interest',
    start_date => SYSDATE,
    repeat_interval => 'FREQ=MONTHLY;
                        BYMONTHDAY=1',
    enabled => TRUE,
    comments => 'Monthly interest calculation');
END;
