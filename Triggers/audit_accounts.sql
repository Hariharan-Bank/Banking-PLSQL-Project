create or replace NONEDITIONABLE TRIGGER
audit_accounts
AFTER INSERT OR UPDATE OR DELETE
ON accounts
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO audit_log VALUES(
    audit_seq.NEXTVAL,
    'ACCOUNTS', 'INSERT',
    NULL,
    JSON_OBJECT(
      'account_id' VALUE :NEW.account_id,
      'balance' VALUE :NEW.balance),
    USER, SYSDATE);
  ELSIF UPDATING THEN
    INSERT INTO audit_log VALUES(
    audit_seq.NEXTVAL,
    'ACCOUNTS', 'UPDATE',
    JSON_OBJECT(
      'balance' VALUE :OLD.balance),
    JSON_OBJECT(
      'balance' VALUE :NEW.balance),
    USER, SYSDATE);
  END IF;
END;
