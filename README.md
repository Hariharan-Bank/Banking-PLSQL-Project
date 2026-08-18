# Core Banking System
## Enterprise Grade Banking Solution
## Oracle 23ai & PL/SQL

---

## Developer
**Hariharan B**
Oracle PL/SQL Developer
3 Years Banking Domain Experience
Indian Bank Corporate Office Support
📧 hariharanbalumech@gmail.com
📍 Chennai, India

---

## Project Overview
Enterprise level core banking system
developed using Oracle 23ai and PL/SQL
simulating real world banking operations
including customer management, account
operations, transaction processing,
loan management, NPA classification,
interest calculation and automated
reporting.

---

## Business Modules

### 1. Customer Management
- Customer onboarding with
  duplicate phone check
- KYC status management
  (PENDING → VERIFIED)
- Customer search by phone,
  email or customer ID
- Customer details as JSON API

### 2. Account Management
- Account opening with validations
  (max 2 accounts per customer)
- Duplicate account type check
- Auto account number generation
- Account closure with reason
- Account statement via REF CURSOR
- Account details as JSON API

### 3. Transaction Management
- Deposit with channel tracking
  (ATM, NET_BANKING, UPI, NEFT, RTGS)
- Withdrawal with minimum
  balance validation (₹500)
- Fund transfer with
  SAVEPOINT rollback protection
- Transaction history as JSON API
- Auto reference number generation

### 4. NPA Management
- Automated NPA classification
  per RBI guidelines:
  → Regular: 0-90 days
  → Sub Standard: 91-365 days
  → Doubtful: 366-730 days
  → Loss Asset: 730+ days
- NPA report by category
- NPA summary as JSON API
- NPA status management

### 5. Interest Management
- Daily interest calculation
  (Balance × Rate / 365)
- Monthly interest application
  using Bulk Collect + FORALL
- FD maturity calculation
  (Compound interest formula)
- Loan EMI calculation
  (Standard EMI formula)
- Outstanding loan balance
- Overdue loan processing
  using MERGE statement
- Interest summary JSON report

---

## Technical Highlights

### Database Design
✅ 8 normalized tables
✅ Foreign key relationships
✅ Proper constraints
✅ Audit trail table
✅ Interest log table

### PL/SQL Features Used
✅ 5 enterprise packages
✅ Package SPEC and BODY
✅ Stored procedures
✅ Functions
✅ SYS_REFCURSOR
✅ Bulk Collect and FORALL
✅ Dynamic SQL
✅ Exception handling
✅ RETURNING clause
✅ MERGE statement
✅ SAVEPOINT rollback

### Modern Oracle Features
✅ JSON_OBJECT
✅ JSON_ARRAYAGG
✅ JSON_OBJECT with RETURNING CLOB
✅ Oracle 23ai compatibility

### Automation
✅ DBMS_SCHEDULER jobs
✅ Daily interest calculation
✅ Monthly NPA classification

### Performance
✅ Bulk processing
✅ Proper indexing
✅ Optimized queries

---

## Database Tables

| Table | Description |
|-------|-------------|
| customers | Customer master data |
| accounts | Bank accounts |
| transactions_table | All transactions |
| loans | Loan details |
| npa_accounts | NPA records |
| interest_rates | Rate master |
| interest_log | Daily interest log |
| audit_log | Audit trail |

---

## How to Setup

```sql
-- Step 1: Create tables
/create.sql

-- Step 2: Create sequences
/sequences.sql

-- Step 3: Create indexes
/indexes.sql

-- Step 4: Insert master data
/insertdata.sql

-- Step 5: Create functions
@Functions/get_acc.sql


-- Step 6: Create packages
@Packages/Customer_Management/spec.sql
@Packages/Customer_Management/body.sql
@Packages/Account_Management/spec.sql
@Packages/Account_Management/body.sql
@Packages/Transaction_Management/spec.sql
@Packages/Transaction_Management/body.sql
@Packages/NPA_Management/spec.sql
@Packages/NPA_Management/body.sql
@Packages/Interest_Management/spec.sql
@Packages/Interest_Management/body.sql

-- Step 7: Create triggers
@Triggers/


-- Step 8: Setup scheduler
@Scheduler/
```

---

## Sample Usage

```sql
SET SERVEROUTPUT ON;

-- Add new customer
DECLARE
  v_cust_id NUMBER;
BEGIN
  CUSTOMER_MANAGEMENT.ADD_CUSTOMER(
    'Hariharan', 'B',
    'hariharan@gmail.com',
    '9876543210',
    TO_DATE('15-03-1995','DD-MM-YYYY'),
    v_cust_id);
  DBMS_OUTPUT.PUT_LINE
  ('Customer ID: ' || v_cust_id);
END;

-- Open account
DECLARE
  v_acc_id NUMBER;
BEGIN
  ACCOUNT_MANAGEMENT.OPEN_ACCOUNT(
    1001, 'SAVINGS', 10000, v_acc_id);
  DBMS_OUTPUT.PUT_LINE
  ('Account ID: ' || v_acc_id);
END;

-- Deposit money
DECLARE
  v_ref VARCHAR2(100);
BEGIN
  TRANSACTION_MANAGEMENT.DEPOSIT(
    2001, 5000, 'UPI', v_ref);
  DBMS_OUTPUT.PUT_LINE
  ('Reference: ' || v_ref);
END;

-- Fund transfer
DECLARE
  v_ref VARCHAR2(100);
BEGIN
  TRANSACTION_MANAGEMENT.TRANSFER_FUNDS(
    'ACC20260001',
    'ACC20260002',
    10000, v_ref);
  DBMS_OUTPUT.PUT_LINE
  ('Reference: ' || v_ref);
END;

-- Calculate EMI
DECLARE
  v_emi NUMBER;
BEGIN
  v_emi := INTEREST_MGMT.CALC_EMI(
    500000, 12, 60);
  DBMS_OUTPUT.PUT_LINE
  ('EMI: ' || v_emi);
END;

-- Get customer JSON
DECLARE
  v_json CLOB;
BEGIN
  v_json :=
  CUSTOMER_MANAGEMENT
  .GET_CUSTOMER_JSON(1001);
  DBMS_OUTPUT.PUT_LINE(v_json);
END;

-- Classify NPA
EXEC NPA_MGMT.CLASSIFY_NPA;

-- Get NPA summary
DECLARE
  v_json CLOB;
BEGIN
  v_json :=
  NPA_MGMT.GET_NPA_SUMMARY_JSON;
  DBMS_OUTPUT.PUT_LINE(v_json);
END;
```

---

## Key Business Validations
