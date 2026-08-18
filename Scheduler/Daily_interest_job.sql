BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    job_name => 'DAILY_INTEREST',
    job_type => 'STORED_PROCEDURE',
    job_action => 'INTEREST_MGMT.calc_daily_interest',
    start_date => SYSDATE,
    repeat_interval => 'FREQ=DAILY;
                        BYHOUR=23;
                        BYMINUTE=0',
    enabled => TRUE,
    comments => 'Daily interest calculation');
END;
