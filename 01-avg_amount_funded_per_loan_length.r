library('RPostgreSQL')
library('ggplot2')
library('scales')

con <- dbConnect(RPostgreSQL::PostgreSQL(), host='localhost', dbname='lending_club', user='postgres', pass='postgres')
df <- dbGetQuery(con, 'SELECT DISTINCT EXTRACT(YEAR FROM issue_d) as yr, term, AVG(funded_amnt)::NUMERIC(5,0) AS funded_avg FROM loans GROUP BY yr, term ORDER BY term, yr')

ggplot(df, aes(yr, funded_avg, fill=term)) +
		ggtitle('Average Funded Amount Per Year') +
		geom_bar(stat="identity") +
		scale_y_continuous(labels = dollar) +
		facet_wrap(~ term) +
		geom_text(show_guide=F, aes(label = dollar(funded_avg), y=funded_avg/2, size=8, angle=90)) +
		theme(legend.title = element_text(colour="chocolate", size=16, face="bold"),
				axis.line=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank(),
				axis.title.x=element_blank(),axis.title.y=element_blank(),
			plot.title = element_text(face='bold', colour="black", size=12, vjust=1.5))
