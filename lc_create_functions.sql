
DROP FUNCTION IF EXISTS get_emp_stats(
	pattern VARCHAR,
	case_sensitive BOOLEAN,
	inc_agg BOOLEAN,
	min_matching INT,
	min_matching_bad INT,
	where_sql1 VARCHAR,
	where_sql2 VARCHAR);

/**
 * Function: get_emp_stats
 */
CREATE OR REPLACE FUNCTION get_emp_stats(
	pattern VARCHAR DEFAULT '',
	case_sensitive BOOLEAN DEFAULT FALSE,
	inc_agg BOOLEAN DEFAULT FALSE,
	min_matching INT DEFAULT 1,
	min_matching_bad INT DEFAULT 1,
	where_sql1 VARCHAR DEFAULT $$TRUE$$,
	where_sql2 VARCHAR DEFAULT $$issue_d >='01/01/2014'$$)
RETURNS TABLE(
	emp_title VARCHAR,
	n_bad_loans INT, n_loans INT, ratio NUMERIC(4,3),
	bad_a INT, a INT, a_ratio NUMERIC(4,3),
	bad_b INT, b INT, b_ratio NUMERIC(4,3),
	bad_c INT, c INT, c_ratio NUMERIC(4,3),
	bad_d INT, d INT, d_ratio NUMERIC(4,3),
	bad_e INT, e INT, e_ratio NUMERIC(4,3),
	bad_f INT, f INT, f_ratio NUMERIC(4,3),
	bad_g INT, g INT, g_ratio NUMERIC(4,3)) AS
$$DECLARE
	match_op VARCHAR := '~*';
BEGIN
	IF (case_sensitive) THEN
		match_op := '*';
	END IF;
	
	EXECUTE 'CREATE TEMP TABLE sel ON COMMIT DROP AS (SELECT emp_title, grade, loan_status'
		|| ' FROM loans WHERE '|| where_sql1 || ' AND ' || where_sql2
		|| ' AND (loan_status = ''Fully Paid'' OR loan_status = ''Charged Off'' OR loan_status = ''Default'')'
		|| ' AND length(emp_title) > 1' || ' AND emp_title ' || match_op || '''' || pattern || ''');';

	CREATE TEMP TABLE emp_stats ON COMMIT DROP AS (SELECT DISTINCT(sel.emp_title),
		SUM(CASE WHEN loan_status <> 'Fully Paid' THEN 1 ELSE 0 END)::INT AS bad,
		COUNT(*)::INT AS cnt,
		SUM(CASE WHEN grade = 'A' THEN 1 ELSE 0 END)::INT AS a,
		SUM(CASE WHEN loan_status <> 'Fully Paid' AND grade = 'A' THEN 1 ELSE 0 END)::INT AS bad_a,
		SUM(CASE WHEN grade = 'B' THEN 1 ELSE 0 END)::INT AS b,
		SUM(CASE WHEN loan_status <> 'Fully Paid' AND grade = 'B' THEN 1 ELSE 0 END)::INT AS bad_b,
		SUM(CASE WHEN grade = 'C' THEN 1 ELSE 0 END)::INT AS c,
		SUM(CASE WHEN loan_status <> 'Fully Paid' AND grade = 'C' THEN 1 ELSE 0 END)::INT AS bad_c,
		SUM(CASE WHEN grade = 'D' THEN 1 ELSE 0 END)::INT AS d,
		SUM(CASE WHEN loan_status <> 'Fully Paid' AND grade = 'D' THEN 1 ELSE 0 END)::INT AS bad_d,
		SUM(CASE WHEN grade = 'E' THEN 1 ELSE 0 END)::INT AS e,
		SUM(CASE WHEN loan_status <> 'Fully Paid' AND grade = 'E' THEN 1 ELSE 0 END)::INT AS bad_e,
		SUM(CASE WHEN grade = 'F' THEN 1 ELSE 0 END)::INT AS f,
		SUM(CASE WHEN loan_status <> 'Fully Paid' AND grade = 'F' THEN 1 ELSE 0 END)::INT AS bad_f,
		SUM(CASE WHEN grade = 'G' THEN 1 ELSE 0 END)::INT AS g,
		SUM(CASE WHEN loan_status <> 'Fully Paid' AND grade = 'G' THEN 1 ELSE 0 END)::INT AS bad_g
	FROM sel
		GROUP BY sel.emp_title);
		
	RETURN QUERY SELECT
		DISTINCT(emp_stats.emp_title),
		emp_stats.bad, emp_stats.cnt, (emp_stats.bad::FLOAT/emp_stats.cnt)::NUMERIC(4,3),
		emp_stats.bad_a, emp_stats.a, (emp_stats.bad_a::FLOAT/GREATEST(1,emp_stats.a))::NUMERIC(4,3),
		emp_stats.bad_b, emp_stats.b, (emp_stats.bad_b::FLOAT/GREATEST(1,emp_stats.b))::NUMERIC(4,3),
		emp_stats.bad_c, emp_stats.c, (emp_stats.bad_c::FLOAT/GREATEST(1,emp_stats.c))::NUMERIC(4,3),
		emp_stats.bad_d, emp_stats.d, (emp_stats.bad_d::FLOAT/GREATEST(1,emp_stats.d))::NUMERIC(4,3),
		emp_stats.bad_e, emp_stats.e, (emp_stats.bad_e::FLOAT/GREATEST(1,emp_stats.e))::NUMERIC(4,3),
		emp_stats.bad_f, emp_stats.f, (emp_stats.bad_f::FLOAT/GREATEST(1,emp_stats.f))::NUMERIC(4,3),
		emp_stats.bad_g, emp_stats.g, (emp_stats.bad_g::FLOAT/GREATEST(1,emp_stats.g))::NUMERIC(4,3)
			FROM emp_stats
		WHERE emp_stats.bad >= min_matching_bad OR emp_stats.cnt >= min_matching
			GROUP BY emp_stats.emp_title, emp_stats.bad, emp_stats.cnt,
			emp_stats.a, emp_stats.b, emp_stats.c, emp_stats.d, emp_stats.e, emp_stats.f, emp_stats.g,
			emp_stats.bad_a, emp_stats.bad_b, emp_stats.bad_c, emp_stats.bad_d, emp_stats.bad_e, emp_stats.bad_f, emp_stats.bad_g;
END;
$$ LANGUAGE plpgsql;

/*
SELECT * FROM get_emp_stats($$\mnurse\M$$, FALSE, FALSE, 1, 1) ORDER BY n_loans DESC, ratio DESC, emp_title;
*/
