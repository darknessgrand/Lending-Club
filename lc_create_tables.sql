CREATE EXTENSION pg_trgm;
CREATE EXTENSION fuzzystrmatch;

CREATE TYPE e_term AS ENUM ('36 months', '60 months');

CREATE TYPE e_grade AS ENUM ('A', 'B', 'C', 'D', 'E', 'F', 'G');

CREATE TYPE e_sub_grade AS ENUM (
'A1', 'A2', 'A3', 'A4', 'A5',
'B1', 'B2', 'B3', 'B4', 'B5',
'C1', 'C2', 'C3', 'C4', 'C5',
'D1', 'D2', 'D3', 'D4', 'D5',
'E1', 'E2', 'E3', 'E4', 'E5',
'F1', 'F2', 'F3', 'F4', 'F5',
'G1', 'G2', 'G3', 'G4', 'G5');

CREATE TYPE e_home_ownership AS ENUM ('NONE', 'ANY', 'OTHER', 'RENT', 'MORTGAGE', 'OWN');

CREATE TYPE e_verification_status AS ENUM ('not verified', 'VERIFIED - income source', 'VERIFIED - income');

CREATE TYPE e_loan_status AS ENUM ('In Review', 'Expired', 'Removed', 'Withdrawn by Applicant', 'In Funding', 'Issuing', 'Not Yet Issued', 'Current', 'In Grace Period', 'Late (16-30 days)', 'Late (31-120 days)', 'Fully Paid', 'Default', 'Charged Off', 'Partially Funded');

CREATE TYPE e_purpose AS ENUM ('car', 'credit_card', 'major_purchase', 'wedding', 'house', 'home_improvement', 'debt_consolidation', 'moving', 'educational', 'vacation', 'other', 'medical', 'renewable_energy', 'small_business');

CREATE TYPE e_addr_state AS ENUM (
'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DC', 'DE', 'FL', 'GA', 
'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 
'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 
'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 
'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY');

CREATE TYPE e_initial_list_status AS ENUM ('w', 'f');

CREATE TABLE public.loans (
	id INTEGER PRIMARY KEY, 
	member_id INTEGER, 
	loan_amnt INTEGER, 
	funded_amnt INTEGER, 
	funded_amnt_inv INTEGER, 
	term e_term, 
	int_rate NUMERIC(4,3), 
	installment FLOAT, 
	grade e_grade, 
	sub_grade e_sub_grade, 
	emp_title VARCHAR, 
	emp_length INTEGER, 
	home_ownership e_home_ownership, 
	annual_inc FLOAT, 
	verification_status e_verification_status, 
	issue_d DATE, 
	loan_status e_loan_status, 
	pymnt_plan BOOLEAN, 
	url VARCHAR, 
	"desc" VARCHAR, 
	purpose e_purpose, 
	zip_code VARCHAR, 
	addr_state e_addr_state, 
	dti NUMERIC(4,3), 
	delinq_2yrs INTEGER, 
	earliest_cr_line DATE, 
	fico_range_low INTEGER, 
	fico_range_high INTEGER, 
	inq_last_6mths INTEGER, 
	mths_since_last_delinq INTEGER, 
	mths_since_last_record INTEGER, 
	open_acc INTEGER, 
	pub_rec INTEGER, 
	revol_bal INTEGER, 
	revol_util NUMERIC(4,3), 
	total_acc INTEGER, 
	initial_list_status e_initial_list_status, 
	out_prncp NUMERIC(8,2), 
	out_prncp_inv NUMERIC(8,2), 
	total_pymnt NUMERIC(8,2), 
	total_pymnt_inv NUMERIC(8,2), 
	total_rec_prncp NUMERIC(8,2), 
	total_rec_int NUMERIC(8,2), 
	total_rec_late_fee NUMERIC(8,2), 
	recoveries NUMERIC(8,2), 
	collection_recovery_fee NUMERIC(8,2), 
	last_pymnt_d DATE, 
	last_pymnt_amnt NUMERIC(8,2), 
	next_pymnt_d DATE, 
	last_credit_pull_d DATE, 
	last_fico_range_high INTEGER, 
	last_fico_range_low INTEGER, 
	collections_12_mths_ex_med INTEGER, 
	mths_since_last_major_derog INTEGER, 
	policy_code INTEGER);
