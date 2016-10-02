library('RPostgreSQL')
library('ggplot2')
library('plyr')

con <- dbConnect(RPostgreSQL::PostgreSQL(), host='localhost', dbname='lending_club', user='postgres', pass='postgres') 
df <- dbGetQuery(con, paste('SELECT DISTINCT EXTRACT(YEAR from issue_d) AS yr, term, SUM(funded_amnt) AS funded_sum',
	'FROM loans GROUP BY yr, term ORDER BY yr, term'))

ratios <- ddply(df, .(yr), summarize, ratio=funded_sum/sum(funded_sum))
df <- data.frame(df, ratios$ratio)
df <- ddply(df, .(yr), transform, position = cumsum(ratios.ratio) - 0.5 * ratios.ratio)
ggplot(df, aes(x = '', y = ratios.ratio, fill = term)) +
		ggtitle('Total Amount Funded by Loan Length') +
		geom_bar(stat='identity', color='black', width=1) +
		facet_wrap(~yr) +
		coord_polar(theta = "y") +
		geom_text(show_guide=F, aes(label = sprintf("%1.2f%%", 100 * ratios.ratio), y=position, size=8)) +
		theme(axis.line=element_blank(), axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank(),
				axis.title.x=element_blank(),axis.title.y=element_blank(),
				plot.title=element_text(vjust=1.5, size=12, face='bold'),
				legend.title = element_text(colour="chocolate", size=16, face="bold"))

