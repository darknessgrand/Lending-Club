
# stability <- emp_length, annual_inc, simple emp_title rules, home ownership
# debt <- dti, revol/util
# credit <- fico, delinq, derog, pub_rec, first credit line; simple rules
# output (paid): color

library('RPostgreSQL')
library('scatterplot3d')

#######################
# Function definitions

s <- function(rslt) {
	sz <- dim(rslt)[1]
	rv <- rep(0.0, sz)
	for (i in 1:sz) {
		loan_amnt <- rslt$loan_amnt[i]
		annual_inc <- rslt$annual_inc[i]
		home_ownership = rslt$home_ownership[i]
		emp_title <- rslt$emp_title[i]
		emp_length <- rslt$emp_length[i]
		max_plausible_inc <- max(100000, loan_amnt * 4);
		rv[i] <- annual_inc / 10000;
		if (annual_inc > max_plausible_inc) {
			rv[i] = rv[i] - (annual_inc - max_plausible_inc) / 10000;
		}
		if (home_ownership == 'mortgage') {
			rv[i] = rv[i] * 2.0;
		}
		rv[i] = rv[i] * (emp_length / 2.0);
	}
	rv
}

d <- function(rslt) {
	sz <- dim(rslt)[1]
	rv <- rep(0.0, sz)
	for (i in 1:sz) {
		rv[i] = rslt$dti[i]
	}
	rv
}

c <- function(rslt) {
	sz <- dim(rslt)[1]
	rv <- rep(0.0, sz)
	for (i in 1:sz) {
		rv[i] = rslt$fico_range_low[i]
	}
	rv
}

output_color <- function(rslt) {
	sz <- dim(rslt)[1]
	rv <- rep('red', sz)
	for (i in 1:sz) {
		if (rslt$loan_status[i] == 'Fully Paid') {
			rv[i] = 'green'
		}
	}
	rv
}


#######################

con <- dbConnect(RPostgreSQL::PostgreSQL(), host='localhost', dbname='lending_club', user='postgres', pass='postgres')

stmt <- paste('SELECT id, loan_status, loan_amnt, issue_d, int_rate, grade, sub_grade, purpose,',
			'emp_title, emp_length, annual_inc, home_ownership, dti, revol_bal, revol_util,',
			'earliest_cr_line, fico_range_low, delinq_2yrs, mths_since_last_delinq, pub_rec, mths_since_last_record,',
			'mths_since_last_major_derog',
			'FROM loans WHERE (issue_d >= \'01/01/2013\' AND issue_d < \'02/01/2013\')',
			'AND grade>=\'E\' AND dti < 20 AND emp_length > 0 AND collections_12_mths_ex_med=0',
			'AND (loan_status=\'Fully Paid\' OR loan_status=\'Charged Off\' OR loan_status=\'Default\');');
rslt <- dbGetQuery(con, stmt);

s_ = s(rslt)
d_ = d(rslt)
c_ = c(rslt)
o_ = output_color(rslt)

graph <- scatterplot3d(s_, d_, c_, main='sdc', type='h', color=o_)

fit <- lm(o_ ~ c_ ) 

graph$plane3d(fit)

postgresqlCloseConnection(con)

