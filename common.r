library('RPostgreSQL')
library('ggplot2')
library('plyr')
library('scales')

.get_connection <- function() {
	if (!exists('.connection') || is_null(.connection)) {
		.connection <- RPostgreSQL::dbConnect(RPostgreSQL::PostgreSQL(), host='localhost', dbname='lending_club', user='postgres', pass='postgres') 
	}
	.connection
}

.capwords <- function(s, strict = FALSE) {
	cap <- function(s) paste(toupper(substring(s, 1, 1)),
				{s <- substring(s, 2); if(strict) tolower(s) else s},
				sep = '', collapse = ' ' )
	sapply(strsplit(s, split = '[ _]'), cap, USE.NAMES = !is.null(names(s)))
}

lc_yearly_data <- function(average='funded_amnt', total=NULL, by=NULL) {
	target = paste0('SUM(', total, ') AS total, AVG(', average, ') AS average')
	group = if (!is.null(total)) total else average
	comma_by = if (!is.null(by)) paste0(', ', by) else ''
	stmt = sprintf('SELECT DISTINCT EXTRACT(YEAR from issue_d) AS yr%s, %s FROM loans GROUP BY yr%s ORDER BY yr%s', 
			comma_by, target, comma_by, comma_by)
	dbGetQuery(.get_connection(), stmt)
}

lc_yearly_pie <- function(df=NULL, total=NULL, by=NULL) {
	if (is.null(df)) {
		df <- lc_yearly_data(total=total, by=by)
	}
	ratios <- ddply(df, .(yr), summarize, ratio=total/sum(total))
	df <- data.frame(df, ratios$ratio)
	df <- ddply(df, .(yr), transform, position = cumsum(ratios.ratio) - 0.5 * ratios.ratio)
	var.titles <- maply(strsplit(total, '_')[[1]]
	ggplot(df, aes(x = '', y = ratios.ratio, fill = if (!is.null(by)) by else NULL +
			ggtitle('Total Amount Funded by Credit Grade') +
			geom_bar(stat='identity', color='black', width=1) +
			facet_wrap(~yr, nrow=1) +
			coord_polar(theta = 'y') +
			geom_text(show_guide=F, aes(x = 1.75 - ratios.ratio * 2.5 , label = sprintf('%1.2f%%', 100 * ratios.ratio), y=position, size=6)) +
			theme(axis.line=element_blank(), axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks=element_blank(),
					axis.title.x=element_blank(),axis.title.y=element_blank(),
					plot.title=element_text(vjust=1.5, size=12, face='bold'),
					legend.title = element_text(colour='chocolate', size=16, face='bold'))
}

print(lc_yearly_charts(average='funded_amnt', by='grade'))
