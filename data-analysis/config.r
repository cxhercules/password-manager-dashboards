#> ---------------------------------------------------------------------------
#> Basic configuration. These variables and settings are supposed to be
#> available throughout the system.
#> ---------------------------------------------------------------------------
options(stringsAsFactors = FALSE)
#options(scipen=999)

log.startLogFile = function(log.file) {
	cat(paste("#> File", log.file, "created automatically on", date(), "\n\n"), file = log.file)
	sink(file = log.file, append = TRUE, type = 'output', split = TRUE)
}

log.spit = function(...) {
	cat(..., "\n", sep = "")
}

log.addLine = function(...) {
	log.spit(as.character(date()), ': ', ...)
}

log.printTable <- function(thistable) {
	for (i in 1:length(thistable))
		log.spit("\t* ", names(thistable[i]), ": ", thistable[i], " of ", sum(thistable), " (", cf.asPercentage(thistable[i]/sum(thistable)), ")")
	log.spit("\n")
}

#> ---------------------------------------------------------------------------
#> Formatting functions
#> ---------------------------------------------------------------------------
cf.replace = function(vec, from, to) {
  replace(vec, which(vec==from), to)
}

cf.asPercentage = function(val, digits=1) {
	if (class(val)=='numeric' | class(val)=='character') {
		tmp = paste(round(100*as.numeric(val),digits), '%', sep='')
		return(replace(tmp, which(tmp=='NA%' | tmp=='Inf%'), ''))
	} else if (class(val)=='matrix' | class(val)=='table') {
		return(apply(val, c(1,2), function(x) { paste(round(100*as.numeric(x),digits), '%', sep='') }))
	} else {
		stop(paste('cf.asPercentage(val): I don\'t know how to convert val, because class(val)==', class(val), sep=''))
	}
}

cf.asPValue = function(val, digits=4, latex=FALSE) {
	tp = round(as.numeric(val), digits)
	if (tp==0)
		fin = paste("<0.",paste(rep.int('0',digits-1), sep='', collapse=''), "1", sep='')
	else
		fin = paste("=",tp, sep='')

	if (latex)
		fin = paste('$', fin, '$', sep='')

	return(fin)
}

cf.asHTMLTable = function(mat, usenames = TRUE, usefirstcol = FALSE, usefirstrow = FALSE, usetopleft = FALSE) {
	mat = apply(mat, c(1,2), function(x) { if (is.na(x)) {''} else {x}})
	mat2 = mat3 = matrix(ncol=ncol(mat), nrow=nrow(mat), data = 'td')

	if (usefirstrow)
		mat2[1,] = "th class='t'"
	if (usefirstcol)
		mat2[,1] = "th class='l'"
	if (usefirstrow & usefirstcol) {
		mat2[1,1] = if (usetopleft) "th class='t l'" else 'td'
		if (!usetopleft) mat3[1,1] = 'td'
	}

	if (usenames) {
		if (!is.null(colnames(mat))) {
			mat = rbind(colnames(mat), mat)
			mat2 = rbind(rep.int("th class='t'", ncol(mat2)), mat2)
		}
		if (!is.null(rownames(mat))) {
			mat = cbind(rownames(mat), mat)
			mat2 = cbind(rep.int("th class='l'", nrow(mat2)), mat2)
		}
		if (!is.null(colnames(mat)) & !is.null(rownames(mat))) {
			mat2[1,1] = if (usetopleft) "th class='t l'" else 'td'
			if (!usetopleft) mat3[1,1] = 'td'
		}
	}

	tmp = matrix(ncol=ncol(mat), data = paste('<', mat2, '>', mat, '</', mat3, '>', sep=''))
	cal = NULL
	for (i in 1:nrow(tmp))
		cal = c(cal, '<tr>', paste(tmp[i,], sep='', collapse=''), '</tr>')
	return(paste(cal, collapse=''))
}

#> Use this function when you want to display the different levels of a categorical variable.
cf.asValueTable = function(col) {
	return(cf.asHTMLTable(t(as.matrix(table(col)))))
}

#> Use this function when you want to display a list of items as a bulleted HTML list.
cf.asHTMLBulletList = function(lst, item = 'li', type = 'ol') {
	return(paste('<', type, '>', paste('<',item,'>',lst,'</',item,'>', sep='', collapse='\n'), '</', type, '>', sep=''))
}

cf.secAsMinSec = function(seconds) {
  min = trunc(seconds/60)
  sec = trunc(seconds - min*60)
  return(paste(min,'min', sec, 'sec'))
}

cf.msAsSec = function(milliseconds, label = TRUE) {
  if (label)
    return(paste(round(milliseconds/1000,1),'sec'))
  else
    return(round(milliseconds/1000,1))
}


#> ---------------------------------------------------------------------------
#> Numerical functions
#> ---------------------------------------------------------------------------
num.coerceToLikert = function(lst, points = 5) {
	likert <- rep.int(0, points)
	for (i in 1:length(lst)) {
		likert[round(lst[i])] <- likert[round(lst[i])] + 1
	}
	return(likert)
}


#> ---------------------------------------------------------------------------
#> Power functions
#> ---------------------------------------------------------------------------

#> Returns power=1-probability(Type II error) for a linear model. Also called
#> sensitivity of a test.
pow.power.lm = function(predictors=NULL, n=NULL, R2=NULL, sig.level=0.05) {
	if (is.null(predictors) | is.null(n) | is.null(R2))
		stop("pow.beta.lm(predictors, n, R2): One of the arguments was not specified. All arguments must be present.")

	if (R2<0 | R2>1)
		stop("pow.beta.lm(predictors, n, R2): R2 is out of range [0,1].")

	library(pwr)
	tmp = pwr.f2.test(u=predictors-1, v=n-predictors, f2=R2/(1-R2), sig.level=sig.level)
	return(tmp$power)
}

#> Returns the number of participants needed to obtain a certain power, for a linear model.
#> The number of predictors is the number of variables plus the intercept. In a regression
#> with interactions, it is the total number of rows in the regression table including the
#> intercept.
pow.numparticipants.lm = function(predictors=NULL, R2=NULL, sig.level=0.05, power=NULL) {
	if (is.null(predictors) | is.null(R2) | is.null(power))
		stop("pow.numparticipants.lm(predictors, R2, power): One of the arguments was not specified. All arguments must be present.")

	if (power<0 | power>1)
		stop("pow.numparticipants.lm(predictors, R2, power): power is out of range [0,1].")

	if (R2<0 | R2>1)
		stop("pow.numparticipants.lm(predictors, R2, power): R2 is out of range [0,1].")

	library(pwr)
	tmp = pwr.f2.test(u=predictors-1, f2=R2/(1-R2), sig.level=sig.level, power=power)
	return(ceiling(tmp$v+predictors))
}

#> Returns the power for two proportions that have the same denominator.
pow.power.proportion.twoequalsamples = function(p1=NULL, p2=NULL, n=NULL, sig.level=0.05) {
	if (is.null(p1) | is.null(p2) | is.null(n))
		stop("pow.power.proportion.twoequalsamples(p1, p2, n): One of the arguments was not specified. All arguments must be present.")
	tmp = pwr.2p.test(h = 2*abs(asin(sqrt(p1))-asin(sqrt(p2))), n=n, sig.level=sig.level)
	return(tmp$power)
}

#> Returns the number of participants needed to obtain a certain power, for two proportions that have
#> the same denominators.
pow.numparticipants.proportion.twoequalsamples = function(p1=NULL, p2=NULL, sig.level=0.05, power=NULL) {
	if (is.null(p1) | is.null(p2) | is.null(power))
		stop("pow.numparticipants.proportion.twoequalsamples(p1, p2): One of the arguments was not specified. All arguments must be present.")
	tmp = pwr.2p.test(h = 2*abs(asin(sqrt(p1))-asin(sqrt(p2))), sig.level=sig.level, power=power)
	return(ceiling(tmp$n))
}

#> Returns the power for two proportions that do not have the same denominator. Alternatively to specifying two
#> proportions and two denominators (which is a bit lame), one can provide a 2x2 matrix wherein p1=mat[1,1]/mat[1,2]
#> and p2=mat[2,1]/mat[2,2].
pow.power.proportion.twounequalsamples = function(p1=NULL, p2=NULL, n1=NULL, n2=NULL, mat=NULL, sig.level=0.05) {
	if (!is.null(p1) & !is.null(p2) & !is.null(n1) & !is.null(n2)) {
		tmp = pwr.2p2n.test(h = 2*abs(asin(sqrt(p1))-asin(sqrt(p2))), n1=n1, n2=n2, sig.level=sig.level)
		return(tmp$power)
	}

	if (is.matrix(mat) & nrow(mat)==2 & ncol(mat)==2) {
		tmp = pwr.2p.test(h = 2*abs(asin(sqrt(mat[1,1]/mat[1,2]))-asin(sqrt(mat[2,1]/mat[2,2]))), n1=n1, n2=n2, sig.level=sig.level)
		return(tmp$power)
	}

	stop("pow.power.proportion.twoequalsamples(p1, p2, n1, n2, mat): One of the arguments was not specified. Not all arguments may be absent.")
}

pow.numparticipants.proportion.twounequalsamples = function(p1=NULL, p2=NULL, n1=NULL, n2=NULL, sig.level=0.05, power=NULL) {
	if (is.null(power) | power<0 | power>1)
		stop("pow.numparticipants.proportion.twounequalsamples(p1,p2,n1,n2,power): You must specify a 0<power<1 level.")

	if ((is.null(n1) & is.null(n2)) | (!is.null(n1) & !is.null(n2)))
		stop("pow.numparticipants.proportion.twounequalsamples(p1,p2,n1,n2,power): You must provide exactly one of n1 and n2.")

	if (is.null(p1) | is.null(p2))
		stop("pow.numparticipants.proportion.twounequalsamples(p1,p2,n1,n2,power): You must specify both p1 and p2.")

	if (is.null(n1)) {
		tmp = pwr.2p2n.test(h = 2*abs(asin(sqrt(p1))-asin(sqrt(p2))), n2=n2, sig.level=sig.level, power=power)
		return(ceiling(tmp$n1))
	} else {
		tmp = pwr.2p2n.test(h = 2*abs(asin(sqrt(p1))-asin(sqrt(p2))), n1=n1, sig.level=sig.level, power=power)
		return(ceiling(tmp$n2))
	}
}



# pow.check = function(mat, format) {
# 	if (class(mat)!='matrix' | nrow(mat)!=2 | ncol(mat)!=2)
# 		stop('stt.power(mat, format): mat has to be a 2x2 matrix.')
# 	if (format!='prop' & format!='yesno')
# 		stop('stt.power(mat, format): format has to be either \'prop\' or \'yesno\'')
# 	if (format=='yesno')
# 		mat[,2] = mat[,2] + mat[,1]
# 	return(mat)
# }
#
# pow.vals = function(mat) {
# 	p1 = mat[1,1]/mat[1,2]
# 	p2 = mat[2,1]/mat[2,2]
# 	h = 2*(asin(sqrt(p1))-asin(sqrt(p2)))
# 	return(c(p1, p2, h))
# }
#
# #> It receives a 2x2 matrix, and calculates current power based on two proportions, contained in rows of the matrix.
# #> If format=='prop', then [,1] is the number of 'yes'es, and [,2] is the total.
# #> If format=='yesno', then [,1] is the number of 'yes'es, and [,2] is the number of 'no's.
# pow.single = function(mat, format, alpha=0.05) {
# 	mat = pow.check(mat, format)
# 	vals = pow.vals(mat)
# 	library(pwr)
# 	return(pwr.2p2n.test(h=vals[3],
# 				   n1=mat[1,2],
# 				   n2=mat[2,2],
# 				   sig.level=alpha)$power)
# }
#
# pow.samplesize.matrix = function(mat, format, alpha=0.05, scale=seq(0.5, 5, 0.5)) {
# 	mat = pow.check(mat, format)
# 	vals = pow.vals(mat)
# 	library(pwr)
# 	narf = matrix(ncol=length(scale), nrow=length(scale))
# 	for (i in 1:length(scale))
# 		for (j in 1:length(scale))
# 			narf[i,j] = pwr.2p2n.test(h=vals[3], n1=floor(mat[1,2]*scale[i]), n2=floor(mat[2,2]*scale[j]), sig.level=alpha)$power
# 	rownames(narf) = colnames(narf) = paste(scale,'X', sep='')
# 	return(narf)
# }
