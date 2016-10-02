#!/usr/bin/python
import csv
import calendar
import glob
import logging
import math
import re
import sys

logger = logging.getLogger('lc.py')
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.DEBUG)

id, member_id, loan_amnt, funded_amnt, funded_amnt_inv, term, int_rate, installment, grade, sub_grade, emp_title, emp_length, home_ownership, annual_inc, verification_status, issue_d, loan_status, pymnt_plan, url, desc, purpose, title, zip_code, addr_state, dti, delinq_2yrs, earliest_cr_line, fico_range_low, fico_range_high, inq_last_6_mths, mths_since_last_delinq, mths_since_last_row, open_acc, pub_rec, revol_bal, revol_util, total_acc, initial_list_status, out_prncp, out_prncp_inv, total_pymnt, total_pymnt_inv, total_rec_prncp, total_rec_int, total_rec_late_fee, recoveries, collection_recovery_fee, last_pymnt_d, last_pymnt_amnt, next_pymnt_d, last_credit_pull_d, last_fico_range_high, last_fico_range_low, collections_12_mths_ex_med, mths_since_last_major_derog, policy_code = range(56)

def to_date(input):
	return '%02d' % [i for i, j in enumerate(calendar.month_abbr) if j == input[:3]][0] + '-01-' + input[4:] if len(input) > 0 else input

for globfn in sys.argv[1:]:
	filenames = glob.glob(globfn)
	for fn in filenames:
		logger.info('\nProcessing CSV file: %s' % (fn)) 
		with open(fn, 'r') as csvfile:
			dialect = csv.Sniffer().sniff(csvfile.read(8192))
			csvfile.seek(0)
			reader = csv.reader(csvfile, dialect)
			reader.next()
			reader.next()
			row_number = 0
			for row in reader:
				try:
					row_number += 1
					if len(row) != 56:
						logger.warn('Skipping line %d with %d column(s).' % (row_number, len(row)))
						continue
					print '"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",'\
					'"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",'\
					'"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",'\
					'"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",'\
					'"%s","%s","%s","%s","%s","%s","%s","%s","%s","%s",'\
					'"%s","%s","%s","%s","%s"'\
					% (row[id].strip(),
					row[member_id].strip(),
					row[loan_amnt].strip(),
					row[funded_amnt].strip(),
					int(math.ceil(float(row[funded_amnt_inv]))),
					row[term].strip(),
					float(row[int_rate].strip('% ') or 0) / 100,
					row[installment].strip(),
					row[grade].strip(),
					row[sub_grade].strip(),
					row[emp_title].strip(),
					row[emp_length].strip('n/a <+years'),
					row[home_ownership].strip(),
					row[annual_inc].strip(),
					row[verification_status].strip(),
					to_date(row[issue_d].strip()),
					row[loan_status].strip().replace('Late (16-30)', 'Late (16-30 days)'),
					row[pymnt_plan].strip(),
					row[url].strip(),
					row[desc].strip(),
					row[purpose].strip(),
					row[zip_code].strip(),
					row[addr_state].strip(),
					float(row[dti].strip('% ') or 0) / 100,
					row[delinq_2yrs].strip(),
					to_date(row[earliest_cr_line].strip()),
					row[fico_range_low].strip(),
					row[fico_range_high].strip(),
					row[inq_last_6_mths].strip(),
					row[mths_since_last_delinq].strip(),
					row[mths_since_last_row].strip(),
					row[open_acc].strip(),
					row[pub_rec].strip(),
					row[revol_bal].strip(),
					float(row[revol_util].strip('% ') or 0)/ 100,
					row[total_acc].strip(),
					row[initial_list_status].strip(),
					row[out_prncp].strip(),
					row[out_prncp_inv].strip(),
					row[total_pymnt].strip(),
					row[total_pymnt_inv].strip(),
					row[total_rec_prncp].strip(),
					row[total_rec_int].strip(),
					row[total_rec_late_fee].strip(),
					row[recoveries].strip(),
					row[collection_recovery_fee].strip(),
					to_date(row[last_pymnt_d].strip()),
					row[last_pymnt_amnt].strip(),
					to_date(row[next_pymnt_d].strip()),
					to_date(row[last_credit_pull_d].strip()),
					row[last_fico_range_high].strip(),
					row[last_fico_range_low].strip(),
					row[collections_12_mths_ex_med].strip(),
					row[mths_since_last_major_derog].strip(),
					row[policy_code].strip())
				except e:
					logger.error(e)

