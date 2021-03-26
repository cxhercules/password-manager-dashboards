#> ---------------------------------------------------------------------------------------------------------------------------------------------------------
#> Formatting functions:
#>	grph.getBinomialCIRadius(): Calculates a binomial confidence interval based on the normal approximation to the binomial distribution, as described in
#>		http://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval
#> 	grph.drawConfIntervals(): Given an open plot, it draws confidence intervals on it. It calls the previous function to calculate the width of the
#>		confidence intervals.

#> Graph functions:
#>	grph.proportionBarplot(): Draws a simple proportion barplot, with or without the ratio within each bar, with or without confidence intervals on top
#>		of each bar.
#>	grph.stackedProportionBarplot(): Draws a stacked proportion barplot; that is, M bars where each bar has N categories that do not add up to 100%. The
#>		graph may include the percentages within each bar segment, and by default includes a legend.
#>	grph.stackedFullProportionBarplot(): Draws a full stacked proportion barplot; that is, M bars where each bar has N categories that all add up to 100%.
#>		The graph may include the percentages within each bar segment, and by default includes a legend.
#> ---------------------------------------------------------------------------------------------------------------------------------------------------------

#> TODO: add fontzoom argument to all graph functions, as in grph.stackedFullProportionBarplot
#> TODO: add myscale argument to all graph functions, as in grph.proportionBarplot

#> mydata is matrix(ncol=2), format is 'AbsOverTotal', 'AbsFreqs', or 'RateOverTotal'.
#> format=='AbsOverTotal' means mydata[,1] is an absolute number of 'Yes', and mydata[,2] is the total (i.e., 'Yes'+'No')
#> format=='AbsFreqs' means mydata[,1] is an absolute number of 'Yes', and mydata[,2] is an absolute number of 'No'
#> format=='RateOverTotal' means 0<=mydata[,1]<=1, and mydata[,2] is the total (i.e., 'Yes'+'No')
grph.getBinomialCIRadius = function(mydata, format='AbsOverTotal', alpha=0.05) {
	#> Preconditions
	if (ncol(mydata)!=2)
		stop(paste('grph.getBinomialCIRadius(arg1) expects arg1[N,2]: arg1 has [', nrow(arg1), ',', ncol(arg1), ']', sep=''))
	if (alpha<.0001 | alpha>.9)
		warning('provided alpha was less than .0001 or more than .9')
	if (!is.numeric(mydata))
		stop('grph.getBinomialCIRadius(arg1) expects that arg1 is numeric. It is not.')

	if (format=='AbsOverTotal') {
		mydata[,1] = abs(mydata[,1]/mydata[,2])
	} else if (format=='AbsFreqs') {
		mydata[,2] = mydata[,1] + mydata[,2]
		mydata[,1] = abs(mydata[,1]/mydata[,2])
	} else if (format=='RateOverTotal') {
		if (sum(mydata[,1]>1)>0)
			stop("grph.getBinomialCIRadius with format='RateOverTotal' expects 0<mydata[,1]<1")
		mydata[,1] = abs(mydata[,1])
	} else {
		stop("grph.getBinomialCIRadius expects format==('AbsFreqs' | 'AbsOverTotal' | 'RateOverTotal')")
	}
	return(qnorm(1-alpha/2) * sqrt(abs(mydata[,1]) * (1-abs(mydata[,1])) / mydata[,2]))
}

grph.drawConfIntervals = function(mydata, coord, deltaless, deltaplus = deltaless, horizontal = TRUE) {
	if (horizontal)
		arrows(mydata + deltaplus, coord, mydata - deltaless, coord, angle = 90, code = 3, length = 0.02)
	else
		arrows(coord, mydata + deltaplus, coord, mydata - deltaless, angle = 90, code = 3, length = 0.02)
}

grph.createOutputDevice = function(name, width = NULL, height = NULL) {
	if (is.null(name))
		return(NULL)
	endswith = function(name, suffix) { return(substr(name, nchar(name)-nchar(suffix), nchar(name))==paste('.',suffix,sep='')) }

	if (endswith(name, 'pdf')) {
		pdf(file = name, width = width, height = height)
		return('scalable')
	}

	if (endswith(name, 'eps')) {
		postscript(file = name, width = width, height = height, horizontal = FALSE, onefile = FALSE, paper = 'special')
		return('scalable')
	}

	if (endswith(name, 'bmp')) {
		bmp(filename = name, width = width, height = height, units = 'px')
		return('bitmap')
	}

	if (endswith(name, 'jpeg') | endswith(name, 'jpg')) {
		jpeg(filename = name, width = width, height = height, units = 'px', quality = 80)
		return('bitmap')
	}

	if (endswith(name, 'png')) {
		png(filename = name, width = width, height = height, units = 'px')
		return('bitmap')
	}

	if (endswith(name, 'tif') | endswith(name, 'tiff')) {
		tiff(filename = name, width = width, height = height, units = 'px', compression = 'zip')
		return('bitmap')
	}
	return(NULL)
}


#> Preconditions:
#> thisdata has to be a Nx1 or Nx2 matrix.
#> If Nx1, this function expect values between 0 and 1. In this case, useconfidenceintervals cannot be TRUE (if so, it will issue a warning)
#> If Nx2, then [,1] will be interpreted as numerator and [,2] as denominator of a ratio.
#> outmargins is a list of 4 float values: the margins from the bottom in clockwise sense.
#> inmarginss is a list of 2 float values: [pending]
#> offsets is a list of 2 float values.
#>	offsets[1] is the base value for positioning the lables of ratios within.
#>	offsets[2] is the limit under which the label of the ratio will be put outside of the bar.
grph.proportionBarplot = function(mydata, filename = NULL, thiscolor = NULL,
					    useconfidenceintervals = FALSE, useratiowithin = TRUE, invert = FALSE, alpha = 0.05,
					    horizontal = TRUE, width = 4, height = 3,
					    outmargins = c(1.0,1.0,1.0,1.0), inmargins = c(0.4, 0.0), offsets = c(.05,.1), myscale=c(1,.2)) {

	#> Preconditions
	if (!is.numeric(mydata))
		stop('grph.proportionBarplot(arg1) expects arg1 to be numeric. It is not.')
	if (class(mydata)!='matrix' | ncol(mydata)==0 | ncol(mydata)>2)
		stop(paste('grph.ProportionBarplot(arg1) expects arg1[N,1] or arg1[N,2]: arg1 has [', nrow(mydata), ',', ncol(mydata), ']', sep=''))
	if (ncol(mydata)==1 & useconfidenceintervals) {
		warning('grph.ProportionBarplot(useconfidenceintervals=TRUE): Cannot create confidence intervals without knowing the totals.', immediate.=TRUE)
		useconfidenceintervals = FALSE
	}

	#> We copy the data we'll send to graph
	thisdata = if (ncol(mydata)==1) mydata[,1] else mydata[,1]/mydata[,2]
	usingratio = (ncol(mydata)==1)

	#> Preparation of arguments
	if (is.null(thiscolor))
		thiscolor = colors()[1:length(thisdata)]
	if (length(thiscolor)!=length(thisdata))
		warning('grph.proportionBarplot: number of colors != length(data)')
	thisspace = rep.int(0.2, nrow(mydata))

	#> We invert the data if needed
	if (invert) {
		thisdata = rev(thisdata)
		thiscolor = rev(thiscolor)
		mydata = mydata[nrow(mydata):1,]
	}

	#> We create the device and the main barplot within it.
	tmp = grph.createOutputDevice(filename, width = width, height = height)
	if (is.null(tmp)) { zoom = 1.4 } else if (tmp=='bitmap') { zoom = 1.4 } else { zoom = 1.0 }
	par(mar = outmargins, mgp = c(0.0, inmargins))

	#> We create the barplot
	yc = barplot(
		thisdata,
		xlim = if (horizontal) c(0,myscale[1]) else NULL,
		ylim = if (horizontal) NULL else c(0,myscale[1]),
		names.arg = rownames(thisdata),
		col = thiscolor,
		space = thisspace,
		horiz = horizontal,
		cex.names = 0.7*zoom, cex.lab = 0.5*zoom, cex.axis = 0.5*zoom,
		las = 1, font = 2, axes = FALSE
	)

	for (i in if (horizontal) c(1,3) else c(2,4))
		axis(i, at = seq(0, myscale[1], myscale[2]), labels = paste( seq(0, round(myscale[1]*100), round(myscale[2]*100)), '%', sep=''), cex.axis = 0.6*zoom, mgp = c(0.0,inmargins), las = 1)
	rm(i)

	#> We draw the confidence intervals (which in reality are arrows)
	if (useconfidenceintervals)
	{
		delta = grph.getBinomialCIRadius(mydata, alpha = alpha)
		grph.drawConfIntervals(thisdata, yc, delta, horizontal = horizontal)
	}
	else
	{ delta = rep.int(0, length(thisdata)) }

	#> We put the labels within the bars
	if (useratiowithin)
	{
		xc = rep.int(offsets[1], length(thisdata))
		for (i in 1:length(thisdata))
		{
			if (thisdata[i]-delta[i] <= offsets[2])
				xc[i] = xc[i] + thisdata[i] + delta[i]
		}
		text(if (horizontal) xc else yc,
		     if (horizontal) yc else xc,
		     if (usingratio) cf.asPercentage(thisdata, digits=0) else paste(mydata[,1], mydata[,2], sep='/'),
		     xpd = TRUE, cex = 0.7*zoom, adj = if (horizontal) c(0.5, NA) else c(NA, 0.5))
	}

	#> Turn off the device
	if (!is.null(filename)) dev.off()
}


#> This function expects a matrix of MxN, where 0<matrix[i,j]<1 for all i,j.
#> This type of graph with stacked=TRUE is confusing, as it presents several bars on top of each other. Use with moderation :)
grph.stackedProportionBarplot = function(mydata, filename=NULL, digits = 0, thiscolor = NULL,
						     useratiowithin = FALSE, uselegend = TRUE, invert = FALSE, stacked = FALSE,
						     horizontal = TRUE, width = 4, height = 3,
						     outmargins = c(1.0,1.0,1.0,1.0), inmargins = c(0.4, 0.0), legendoffset = 0.2) {

	#> Preconditions
	if (!is.numeric(mydata) | class(mydata)!='matrix')
		stop('grph.stackedProportionBarplot(arg1) expects arg1 to be a matrix of numeric values. It is not.')
	if (is.null(thiscolor))
		thiscolor = colors()[1:ncol(mydata)]
	if (length(thiscolor)!=ncol(mydata))
		warning(paste('grph.stackedProportionBarplot(arg1, ..., thiscolor=arg2) expects length(arg2)==ncol(arg1); it is not.'))
	if (ncol(mydata)<2)
		stop('grph.stackedProportionBarplot(arg1): arg1 has only one column. Use grph.proportionBarplot() instead.')

	#> We manipulate the data a little bit.
	thisdata = mydata
	if (stacked)
		for (i in ncol(thisdata):2)
			thisdata[,i] = thisdata[,i] - thisdata[,i-1]

	#> We invert the data if asked to
	if (invert) {
		thisdata = thisdata[nrow(thisdata):1,ncol(thisdata):1]
		mydata = mydata[nrow(mydata):1,ncol(thisdata):1]
	}

	#> We draw the graph
	tmp = grph.createOutputDevice(filename, width = width, height = height)
	if (is.null(tmp)) { zoom = 1.5 } else if (tmp=='bitmap') { zoom = 1.5 } else { zoom = 1.0 }
	par(mar = outmargins, mgp = c(0, inmargins), xpd = TRUE)
	yc = barplot(t(thisdata),
			 horiz = horizontal,
			 beside = !stacked,
			 width = 0.2,
			 las = 1,
			 cex.names = 0.8*zoom,
			 cex.axis = 0.7*zoom,
			 font = 2,
			 col = if (invert) rev(thiscolor) else thiscolor,
			 axes = FALSE
	)

	#> Ratio within each bar segment
	if (useratiowithin) {
		if (stacked) {
			suple = thisdata*.99
			for (i in 2:ncol(suple))
				for (j in 1:(i-1))
					suple[,i] = suple[,i] + thisdata[,j]
			mydata2 = mydata
			for (i in ncol(mydata2):2)
				mydata2[,i] = mydata2[,i] - mydata2[,i-1]
			mydata2 = mydata2>=.07
			mylabs = mydata
			for (i in 1:nrow(mylabs))
				for (j in 1:ncol(mylabs))
					mylabs[i,j] = if (mydata2[i,j]) paste(round(100*mydata[i,j],digits), '%', sep='') else ''
			text(if (horizontal) suple else yc, if (horizontal) yc else suple, mylabs, xpd = TRUE, cex = 0.6*zoom, adj = if (horizontal) c(0.5, NA) else c(NA, 0.5))
		} else {
			suple = as.numeric(t(thisdata))/2
			mylabs = paste(round(100*t(thisdata), 0), '%', sep='')
			text(if (horizontal) suple else yc, if (horizontal) yc else suple, mylabs, xpd = TRUE, cex = 0.6*zoom, adj = if (horizontal) c(0.5, NA) else c(NA, 0.5))
		}
	}

	#> Legend
	if (uselegend & !is.null(colnames(thisdata)))
		legend('right', if (invert) rev(colnames(thisdata)) else colnames(thisdata),
			 inset = -1*legendoffset,
			 fill = thiscolor,
			 cex = 0.7*zoom,
			 xpd = TRUE)

	#> Axes
	for (i in if (horizontal) c(1,3) else c(2,4))
		axis(i, at = seq(0,1,.2), labels = paste(seq(0,100,20), '%', sep=''), cex.axis = 0.7*zoom, mgp = c(0.0, if (horizontal) 0.4 else 0.6, 0.0))
	if (!is.null(filename)) dev.off()
}


#> This function expects a matrix of MxN. It draws each row as a set of stacked bars, with the ratio within each segment.
#> If the sum of the values of the first row add up to 1.0, then rows will be interpreted as proportions. Otherwise, rows
#> will be summed up and divided by the total.
grph.stackedFullProportionBarplot = function(mydata, filename = NULL, digits = 0, thiscolor = NULL,
						     useratiowithin = FALSE, uselegend = TRUE, legendoffset = 0.2, invert = FALSE, showaxes = TRUE,
						     horizontal = TRUE, width = 4, height = 3, 
						     outmargins = c(1.0,1.0,1.0,1.0), inmargins = c(0.4, 0.0), fontzoom = 1.0) {

	#> Preconditions
	if (is.null(thiscolor))
		thiscolor = colors()[1:ncol(mydata)]
	if (length(thiscolor)!=ncol(mydata))
		warning(paste('grph.stackedFullProportionBarplot(arg1, ..., thiscolor=arg2) expects length(arg2)==ncol(arg1); it is not.'))

	#> We manipulate the data a little bit.
	if (abs(sum(mydata[1,])-1.0)<=0.001) {
		thisdata = mydata
	} else {
		thisdata = mydata / rowSums(mydata)
	}

	#> We invert the data if asked to
	if (invert) thisdata = thisdata[nrow(thisdata):1,]

	#> We draw the graph
	tmp = grph.createOutputDevice(filename, width = width, height = height)
	if (is.null(tmp)) { zoom = 1.5 } else if (tmp=='bitmap') { zoom = 1.5 } else { zoom = 1.0 }
	par(mar = outmargins, mgp = c(0, inmargins), xpd = TRUE)
	yc = barplot(t(thisdata),
			 horiz = horizontal,
			 width = 0.2,
			 las = 1,
			 cex.names = 0.8*fontzoom,
			 cex.axis = 0.7*fontzoom,
			 font = 2,
			 col = thiscolor,
			 axes = FALSE
	)

	#> Ratio within each bar segment
	if (useratiowithin) {
		suple = thisdata/2
		for (i in 2:ncol(suple))
			for (j in 1:(i-1))
				suple[,i] = suple[,i] + thisdata[,j]
		mylabs = apply(thisdata, c(1,2), function(x) {if (x>=.05) paste(round(100*x,digits), '%', sep='') else ''})
		text(if (horizontal) suple else yc, if (horizontal) yc else suple, mylabs, xpd=TRUE, cex=0.6*fontzoom)
	}

	#> Legend
	if (uselegend & !is.null(colnames(thisdata)))
		legend('right', colnames(thisdata), inset = -1*legendoffset, fill = thiscolor, cex = 0.7*fontzoom, xpd = TRUE)

	#> Axes
	if (showaxes) {
		for (i in if (horizontal) c(1,3) else c(2,4))
			axis(i, at = seq(0,1,.2), labels = paste(seq(0,100,20), '%', sep=''), cex.axis = 0.7*fontzoom, mgp = c(0.0, if (horizontal) 0.4 else 0.6, 0.0))
	}
	if (!is.null(filename)) dev.off()
}



#> Preconditions:
#> thisdata has to be an Mx2 matrix, where matrix[,1] is the numerator and matrix[,2] is the denominator of a proportion.
#> M has to be equal to length(outerlabels)*length(innerlabels).
#> THIS FUNCTION IS WRONG. NO TIME NOW TO FIX IT, BUT IT REQUIRES CAREFUL TESTING.
# grph.ProportionGroupHorizontalBarplot = function(thisdata, outerlabels = outerlabels, innerlabels = innerlabels,
# 								 filename = NULL, width = 4, height = 6, mycolors = NULL, xlab = '', useratiowithin = TRUE,
# 								 useconfidenceintervals = FALSE, inaddition = NULL) {
# 	if (nrow(thisdata) != length(outerlabels)*length(innerlabels))
# 		stop("number of columns does not match (number of groups)*(elements within a group)")
# 	if (!is.null(mycolors) & length(mycolors)!=length(outerlabels)*length(innerlabels))
# 		stop("number of colors does not match number of columns in data")
# 	
# 	mydata = rev(thisdata[,1]/(thisdata[,1]+thisdata[,2]))
# 	outerlabels = rev(outerlabels)
# 	innerlabels = rev(innerlabels)
# 	
# 	#> We configure the spaces between all bars
# 	spaces = rep.int(0.3, length(mydata))
# 	for (i in 1:(length(outerlabels)-1)*length(innerlabels)+1) spaces[i] = 0.9
# 	
# 	#> We create the labels that will go to the left of each bar
# 	barnames = rep.int(innerlabels, length(outerlabels))
# 	
# 	#> We set up the colors for each bar
# 	if (is.null(mycolors))
# 		mycolors = rep.int(colors()[1:length(innerlabels)], length(outerlabels))
# 	
# 	#> We create the canvas for the graph
# 	pdf(file = filename, width = width, height = height)
# 	par(mar = c(2.0, 5.5, 0.6, 1.7), mgp = c(0.9, 0.3, 0), xpd = TRUE, lwd = 0.5)
# 	yc = barplot(mydata,
# 			 horiz = TRUE,
# 			 space = spaces,
# 			 las = 1,
# 			 cex.names = 0.6,
# 			 cex.axis = 0.6,
# 			 font = 1,
# 			 names.arg = barnames,
# 			 axes = FALSE,
# 			 col = mycolors,
# 			 xlab = xlab,
# 			 cex.lab = 0.7,
# 			 xlim = c(0.0,1.0)
# 	)
# 	
# 	#> We put the big labels for each group
# 	wherelab = NULL
# 	for (i in 1:length(outerlabels)) wherelab = c(wherelab, mean(yc[((i-1)*length(innerlabels)+1):(i*length(innerlabels))]))
# 	
# 	#> The two axes, one on the bottom (1) and the other one on top (3)
# 	for (i in c(1,3))
# 		axis(i, labels = paste(seq(0,100,20), '%', sep=''), at = seq(0.0,1.0,0.2), cex.axis = 0.5, mgp = c(0.0, 0.4, -0.5), lwd = 0.5)
# 	axis(2, at = wherelab, labels = outerlabels, mgp = c(0.0, 2.5, 0.0), las = 1, tick = FALSE, cex.axis=0.7)
# 	
# 	#> We draw dashed lines between each group
# 	for (i in 1:(length(outerlabels)-1))
# 	{
# 		man = (yc[i*length(innerlabels)] + yc[i*length(innerlabels)+1])/2
# 		lines(c(0.0,1.0),c(man,man), lty=2, lwd=0.6)
# 	}
# 	
# 	#> We draw the confidence intervals (which in reality are arrows)
# 	intoffset = 0.02
# 	if (useconfidenceintervals)
# 	{
# 		delta = cf.getBinCIRadius(mydata)
# 		arrows(mydata+delta, yc, mydata-delta, yc, angle = 90, code = 3, length = 0.02)
# 		intoffset = 0.09
# 	}
# 	else
# 	{ delta = rep.int(0, nrow(thisdata)) }
# 	
# 	#> We put the labels within the bars
# 	if (useratiowithin)
# 	{
# 		xc = rep.int(0.02, nrow(thisdata))
# 		for (i in 1:length(mydata))
# 		{
# 			if (mydata[i]<0.15)
# 				xc[i] = mydata[i] + intoffset
# 		}
# 		text(xc, yc, rev(paste(thisdata[,1], thisdata[,1]+thisdata[,2], sep = '/')), xpd = TRUE, cex = 0.6, adj = c(0, NA))
# 	}
# 	
# 	if (!is.null(inaddition))
# 	{
# 		inaddition = paste(inaddition, 'exps.', sep=' ')
# 		text(1.21, yc[0:5*4+1], rev(inaddition), xpd = TRUE, cex=0.6, adj = c(1,NA), col = 'indianred1')
# 	}
# 	
# 	#> Finally, we put the legend and we close the canvas
# 	#legend(x=53, y=29.5, retention.names, fill = barcolors, cex = 0.6, xpd = TRUE)
# 	dev.off()
# }
