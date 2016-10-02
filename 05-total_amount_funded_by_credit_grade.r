library('RPostgreSQL')
library('ggplot2')
library('plyr')

x11(width=16, height=5)

con <- dbConnect(RPostgreSQL::PostgreSQL(), host='localhost', dbname='lending_club', user='postgres', pass='postgres') 
df <- dbGetQuery(con, paste('SELECT DISTINCT EXTRACT(YEAR from issue_d) AS yr, grade, SUM(funded_amnt) AS funded_sum',
				'FROM loans GROUP BY yr, grade ORDER BY yr, grade'))



