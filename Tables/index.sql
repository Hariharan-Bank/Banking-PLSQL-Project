-- 03_create_indexes.sql

-- Customer indexes
CREATE INDEX idx_cust_phone
ON customers(phone);

CREATE INDEX idx_cust_email
ON customers(email);

-- Account indexes
CREATE INDEX idx_acc_customer
ON accounts(customer_id);

CREATE INDEX idx_acc_status
ON accounts(status);

CREATE INDEX idx_acc_type
ON accounts(account_type);

-- Transaction indexes
CREATE INDEX idx_txn_account
ON transactions_table(account_id);

CREATE INDEX idx_txn_date
ON transactions_table(txn_date);

CREATE INDEX idx_txn_type
ON transactions_table(txn_type);

-- Loan indexes
CREATE INDEX idx_loan_customer
ON loans(customer_id);

CREATE INDEX idx_loan_status
ON loans(status);

-- NPA indexes
CREATE INDEX idx_npa_category
ON npa_accounts(npa_category);

CREATE INDEX idx_npa_status
ON npa_accounts(status);
