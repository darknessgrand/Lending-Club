library('RPostgreSQL')
library('plyr')
library('grid')
library('ggplot2')

tryCatch({
	drv <- RPostgreSQL::PostgreSQL()
	con <- dbConnect(drv, host='localhost', dbname='lending_club', user='postgres', pass='postgres')
	TRUE
}, error = function(err) { print(err); stop(); }, warning = function(err) { print(err); stop(); } )

tryCatch({
	#stmt <- paste('WITH yearly AS (SELECT DISTINCT EXTRACT(YEAR FROM issue_d) AS yr, SUM(funded_amnt) as funded_amnt FROM loans GROUP BY yr)',
	#	'SELECT yearly.yr, loans.term, SUM(loans.funded_amnt)::FLOAT / yearly.sum as pct',
	#	'FROM loans LEFT JOIN yearly ON yearly.yr = EXTRACT(YEAR FROM loans.issue_d)',
	#	'GROUP BY yearly.yr, loans.term, yearly.sum ORDER BY yearly.yr, term')
	stmt <- paste('SELECT DISTINCT EXTRACT(YEAR from issue_d) AS yr, term, SUM(funded_amnt) AS funded_sum FROM loans GROUP BY yr, term ORDER BY yr, term')
	df <- dbGetQuery(con, stmt)
	TRUE
}, error = function(err) { print(err); stop(); }, warning = function(err) { print(err); stop(); } )


#ggplot(df, aes_string(x=factor(1), y='pct', fill='term')) +
#		geom_bar(stat='identity', color='black') +
#		guides(fill=guide_legend(override.aes=list(colour=NA))) + # removes black borders from legend
#		coord_polar(theta='y') +
#		facet_wrap(~ yr) +
#		scale_y_continuous(labels = percent_format())

ratios <- ddply(df, .(yr), summarize, ratio=funded_sum/sum(funded_sum))
df <- data.frame(df, ratios$ratio)
df <- ddply(df, .(yr), transform, position = cumsum(ratios.ratio) - 0.5 * ratios.ratio)
ggplot(df, aes(x = '', y = ratios.ratio, fill = term)) +
		geom_bar(stat = "identity", width = 1) +
		facet_wrap(~yr) +
		coord_polar(theta = "y") +
		geom_text(aes(label = sprintf("%1.2f%%", 100 * ratios.ratio), y=position, size=8)) +
		theme(axis.line=element_blank(),axis.text.x=element_blank(),
		axis.text.y=element_blank(),axis.ticks=element_blank(),axis.title.x=element_blank(),axis.title.y=element_blank(),
		panel.background=element_blank(),panel.border=element_blank(),panel.grid.major=element_blank(), panel.grid.minor=element_blank(),
		plot.background=element_blank(),plot.title=element_text(vjust=5)) +
		ggtitle('Total Amount Funded by Loan Length') + guides(colour=FALSE)
			
