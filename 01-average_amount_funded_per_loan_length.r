library('RPostgreSQL')
library('reshape2')
library('ggplot2')

drv <- RPostgreSQL::PostgreSQL()
con <- dbConnect(drv, host='localhost', dbname='lending_club', user='postgres', pass='postgres')

df <- dbGetQuery(con, 'SELECT DISTINCT EXTRACT(YEAR FROM issue_d) as yr, term, AVG(funded_amnt) AS funded_avg FROM loans GROUP BY yr, term ORDER BY term, yr')

ggplot(df, aes(yr, funded_avg, fill=factor(term))) + geom_bar(stat="identity") + facet_wrap(~ term) + ggtitle('Average Amount Funded Per Loan Length')

#n_years <- length(unique(df$yr))
#barplot(data$funded_avg, col=c(rep('blue', n_years), rep('orange', n_years)), xlab='Year', names.arg=data$yr)
#title('Average Amount Funded Per Loan Length')

RPostgreSQL::postgresqlCloseClonnection(con)
RPostgreSQL::postgresqlClostDriver(drv);
