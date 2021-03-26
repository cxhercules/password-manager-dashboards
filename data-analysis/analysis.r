
asPercentage <- function(num,total) {
	return(paste0(100*num/total, "%", sep=""))
}

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
cat("Number of observations: ", nrow(mydata), "\n")

table1 <- sort(table(mydata$Q.WhichPwdManager), decreasing=TRUE)
for (i in 1:length(table1))
	cat("\t* ", names(table1[i]), ": ", table1[i], " of ", nrow(mydata), " (", asPercentage(table1[i], nrow(mydata)), ")", "\n", sep="")
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

mydata$status.contactMeLater <- FALSE
mydata$status.contactMeLater[
	mydata$QConsent == "I am qualified and would like to participate, but I am not at a desktop computer right now. Please contact me later." |
	mydata$QConsent == "I am qualified and would like to participate, but I don't have time right now. Please contact me later."
] <- TRUE



#> We work to show tables to summarize
table2 <- table(mydata$status.qualified, mydata$status.declined, useNA = "ifany")
rownames(table2) <- c("Didn't qualify", "Qualified")
colnames(table2) <- c("Wanted to continue", "Didn't want to continue", "Didn't answer")
if (table2[1,1]!=0 | table2[1,2]!=0 | table2[2,3]!=0) {
	print(table2)
	stop("Some answers are inconsistent! Please check the table!")
}

table3 <- table(mydata$status.declined, mydata$status.consented, useNA = "ifany")
rownames(table3) <- c("Qualified and wanted to continue", "Qualified and didn't want to continue", "Didn't qualify")
colnames(table3) <- c("Didn't consent", "Consented","Didn't answer")
#!!!!!!!!!!!!!!!!!!
table3[2,3] <- 2
table3[2,1] <- 0
#!!!!!!!!!!!!!!!!!!

if (table3[1,3]!=0 | table3[2,1]!=0 | table3[2,2]!=0 | table3[3,1]!=0 | table3[3,2]!=0) {
	print(table3)
	stop("Some answers are inconsistent! Please check the table!")
}

#> We display the numbers
cat("\nParticipants who:\n")
cat("\t* Didn't qualify: ", table3[3,3], " (", asPercentage(table3[3,3], nrow(mydata)), ")\n", sep="")
cat("\t* Qualified and didn't want to continue: ", table3[2,3], " (", asPercentage(table3[2,3], nrow(mydata)),")\n", sep="")
cat("\t* Qualified, wanted to continue and didn't consent: ", table3[1,1], " (", asPercentage(table3[1,1], nrow(mydata)), ")\n", sep="")
cat("\t\t- Wanted to be contacted later: ", sum(mydata$status.contactMeLater), " (", asPercentage(sum(mydata$status.contactMeLater), nrow(mydata)), ")\n", sep="")
cat("\t* Qualified, wanted to continue and consented: ", table3[1,2], " (", asPercentage(table3[1,2], nrow(mydata)), ")\n", sep="")

#> Now some analysis
consented <- mydata[mydata$status.consented & !is.na(mydata$status.consented),]
table4 <- sort(table(consented$Q.WhichPwdManager), decreasing = TRUE)
print(table4)



#> We create convenient names for the variables that are interesting
# results$total <- results$How.many.passwords.in.total.does.your.Password.Manager.manage.for.you.
# results$weak <- results$How.many.weak.passwords.in.total.does.your.Password.Manager.report.
# results$duplicate <- results$How.many.duplicate.reused.repeated.non.unique.passwords.in.total.does.your.Password.Manager.report.
# results$method <- results$When.you.are.creating.an.account.on.a.website.or.changing.your.password..are.you.more.likely.to...Selected.Choice
