
#> We load and clean the data
thesedata <- read.csv('./data/Pilot-20210315.csv')
thesedata$gender <- factor(thesedata$X5.3)
thesedata$age <- thesedata$X5.2

for (i in c('Status','Progress','Finished','DistributionChannel','UserLanguage','ResponseId','RandomNumber',
			'SESSION_ID','StudyID','ResponseID','Referer','SurveyID','X5.3','X5.2','Q_RecaptchaScore'))
	thesedata[,c(i)] <- NULL
rm(i)

#> Compacting specific columns
thesedata$Q.WhichPwdManager <- factor(thesedata$Q.WhichPwdManager)
thesedata$Q.WhichPwdManager.other <- NA
thesedata$Q.WhichPwdManager.other[thesedata$Q.WhichPwdManager=='Another Browser\'s Built-In Password Manager (please type the name below)'] <-
	paste(thesedata$Q.WhichPwdManager_17_TEXT[thesedata$Q.WhichPwdManager_17_TEXT!=''])
thesedata$Q.WhichPwdManager[thesedata$Q.WhichPwdManager=='Another Browser\'s Built-In Password Manager (please type the name below)'] <- as.factor("another.browser")

thesedata$Q.WhichPwdManager.other[thesedata$Q.WhichPwdManager=='Other Password Manager (please type the name below)'] <-
	paste(thesedata$Q.WhichPwdManager_18_TEXT[thesedata$Q.WhichPwdManager_18_TEXT!=''])
thesedata$Q.WhichPwdManager[thesedata$Q.WhichPwdManager=='Other Password Manager (please type the name below)'] <- "another.pwdmanager"

thesedata$Q.WhichPwdManager_17_TEXT <- NULL
thesedata$Q.WhichPwdManager_18_TEXT <- NULL


#> We count how many people gave their consent
thesedata$Q.Duration <- paste(thesedata$Q.Duration)



#> We create convenient names for the variables that are interesting
results$total <- results$How.many.passwords.in.total.does.your.Password.Manager.manage.for.you.
results$weak <- results$How.many.weak.passwords.in.total.does.your.Password.Manager.report.
results$duplicate <- results$How.many.duplicate.reused.repeated.non.unique.passwords.in.total.does.your.Password.Manager.report.
results$method <- results$When.you.are.creating.an.account.on.a.website.or.changing.your.password..are.you.more.likely.to...Selected.Choice

#> Let's check demographics
summary(results$What.is.your.age.)
table(results$What.is.your.gender....Selected.Choice)

#> We examine normality for variables (not expecting it... just taking a look)
hist(results$total)
hist(results$weak)
hist(results$duplicate)
table(results$method)

#> Let's check whether distributions for both methods are different
kruskal.test(total ~ method, data = results)
kruskal.test(weak ~ method, data = results)
kruskal.test(duplicate ~ method, data = results)

#> We remove those folks with less than 10 passwords
results <- results[ -c(results$total<10), ]

#> Let's check again whether distributions for both methods are different
kruskal.test(total ~ method, data = results)
kruskal.test(weak ~ method, data = results)
kruskal.test(duplicate ~ method, data = results)

