
#> We load and clean the data
mydata <- read.csv('./data/Pilot-20210315.csv')
mydata$gender <- factor(mydata$X5.3)
mydata$age <- mydata$X5.2

for (i in c('Status','Progress','Finished','DistributionChannel','UserLanguage','ResponseId',
			'SESSION_ID','StudyID','ResponseID','Referer','SurveyID','X5.3','X5.2','Q_RecaptchaScore'))
	mydata[,c(i)] <- NULL
rm(i)

mydata$Q.Duration <- factor(mydata$Q.Duration)
mydata$Q.LearnMore <- factor(mydata$Q.LearnMore)

#> Compacting specific columns
mydata$Q.WhichPwdManager <- paste(mydata$Q.WhichPwdManager)
mydata$Q.WhichPwdManager.other <- NA
mydata$Q.WhichPwdManager.other[mydata$Q.WhichPwdManager=='Another Browser\'s Built-In Password Manager (please type the name below)'] <-
	paste(mydata$Q.WhichPwdManager_17_TEXT[mydata$Q.WhichPwdManager_17_TEXT!=''])
mydata$Q.WhichPwdManager[mydata$Q.WhichPwdManager=='Another Browser\'s Built-In Password Manager (please type the name below)'] <- "another.browser"

mydata$Q.WhichPwdManager.other[mydata$Q.WhichPwdManager=='Other Password Manager (please type the name below)'] <-
	paste(mydata$Q.WhichPwdManager_18_TEXT[mydata$Q.WhichPwdManager_18_TEXT!=''])
mydata$Q.WhichPwdManager[mydata$Q.WhichPwdManager=='Other Password Manager (please type the name below)'] <- "another.pwdmanager"
mydata$Q.WhichPwdManager.other <- factor(mydata$Q.WhichPwdManager.other)

mydata$Q.WhichPwdManager_17_TEXT <- NULL
mydata$Q.WhichPwdManager_18_TEXT <- NULL

#> We count how many people qualify
cat("Number of observations: ", nrow(mydata))

table1 <- sort(table(mydata$Q.WhichPwdManager), decreasing=TRUE)
for (i in 1:length(table1))
	cat("\t", names(table1[i]), ": ", table1[i], " of ", nrow(mydata), " (", table1[i]*100/nrow(mydata), "%)", "\n", sep="")
rm(i)

mydata$status.qualified <- FALSE
mydata$status.qualified[
	(mydata$Q.WhichPwdManager == '1Password' |
		mydata$Q.WhichPwdManager == 'Bitwarden (Premium Edition)' |
		mydata$Q.WhichPwdManager == 'Dashlane' |
		mydata$Q.WhichPwdManager == 'KeePassXC' |
		mydata$Q.WhichPwdManager == 'Keeper Password Manager' |
		mydata$Q.WhichPwdManager == 'LastPass' |
		mydata$Q.WhichPwdManager == 'Norton Password Manager' |
	 	mydata$Q.WhichPwdManager == 'Password Boss' |
	 	mydata$Q.WhichPwdManager == 'Roboform' |
	 	mydata$Q.WhichPwdManager == 'StickyPassword') &
	mydata$Q.Duration!="Less than 2 months"
] <- TRUE
mydata$status.qualified[
	mydata$Q.WhichPwdManager == 'The Password Manager Built into Google\'s Chrome Browser (Google Password Manager)' &
	mydata$Q.Duration != "Less than 2 months" &
	mydata$RandomNumber < 1000
] <- TRUE


mydata$status.declined <- NA
mydata$status.declined[mydata$Q.LearnMore == "No thanks. I'm done."] <- TRUE
mydata$status.declined[mydata$Q.LearnMore == "Yes, I'll spend one more minute for a USD $0.25 bonus."] <- FALSE
mydata$status.consented <- NA
mydata$status.consented[
	mydata$QConsent == "I am not comfortable uploading the screenshot of aggregate statistics or answering questions about my password manager." |
	mydata$QConsent == "I am qualified and would like to participate, but I am not at a desktop computer right now. Please contact me later." |
	mydata$QConsent == "I am qualified and would like to participate, but I don't have time right now. Please contact me later." |
	mydata$QConsent == "I decline to participate and decline to provide a reason." |
	mydata$QConsent == "I do not qualify because I cannot use my password manager's desktop or web interface." |
	mydata$QConsent == "I do not qualify because I do not have a desktop computer on which to perform the study tasks." |
	mydata$QConsent == "I do not want to participate because the study doesn't pay as much as I'd like. (Enter the price you would participate for.)" |
	mydata$QConsent == "I do not want to participate for other reasons. (Please tell us why.)"
] <- FALSE
mydata$status.consented[
	mydata$QConsent == "Yes, I am qualified to participate in the full $5.00 study and want to start immediately."
] <- TRUE

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

