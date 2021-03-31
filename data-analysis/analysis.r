
#> Initialization
library(corrplot)
createlog <- TRUE
source('./config.r')
source('./graphs.r')

if (createlog) log.startLogFile('./output.log')
mydata <- read.csv('./data/Pilot-20210331.csv')

#> We load and clean the data
mydata$gender <- factor(mydata$Q.gender)
mydata$age <- mydata$Q.age
mydata$Q.Duration <- factor(mydata$Q.Duration,
							levels = c("Less than 2 months","Between 2 months to 1 year", "Between 1 to 2 years", "Between 2 to 3 years", "Between 3 to 4 years", "More than 4 years"))
mydata$Q.LearnMore <- factor(mydata$Q.learningMore)
mydata$Passwords.Total <- mydata$Q.Pwds.Total
mydata$Passwords.reused <- mydata$Q.Pwds.R
mydata$Passwords.weak <- mydata$Q.Pwds.W
mydata$Passwords.compromised <- mydata$Q.Pwds.C

#> Compacting specific columns
mydata$Q.WhichPwdManager <- paste(mydata$Q.WhichPwdManager)
mydata$Q.WhichPwdManager.other <- NA
mydata$Q.WhichPwdManager.other[mydata$Q.WhichPwdManager=='Another Browser\'s Built-In Password Manager (please type the name below)'] <-
	paste(mydata$Q.WhichPwdManager_17_TEXT[mydata$Q.WhichPwdManager_17_TEXT!=''])
mydata$Q.WhichPwdManager[mydata$Q.WhichPwdManager=='Another Browser\'s Built-In Password Manager (please type the name below)'] <- "Another Browser\'s Built-In Password Manager"

mydata$Q.WhichPwdManager.other[mydata$Q.WhichPwdManager=='Other Password Manager (please type the name below)'] <-
	paste(mydata$Q.WhichPwdManager_18_TEXT[mydata$Q.WhichPwdManager=='Other Password Manager (please type the name below)'])
mydata$Q.WhichPwdManager[mydata$Q.WhichPwdManager=='Other Password Manager (please type the name below)'] <- "Other Password Manager"
mydata$Q.WhichPwdManager.other <- factor(mydata$Q.WhichPwdManager.other)

mydata$Q.WhichPwdManager_17_TEXT <- NULL
mydata$Q.WhichPwdManager_18_TEXT <- NULL

mydata$Q.Consent.other <- NA
mydata$Q.Consent.other[mydata$Q.Consent == 'I do not want to participate because the study doesn\'t pay as much as I\'d like. (Enter the price you would participate for.)'] <-
	mydata$Q.Consent_6_TEXT[mydata$Q.Consent == 'I do not want to participate because the study doesn\'t pay as much as I\'d like. (Enter the price you would participate for.)']
mydata$Q.Consent.other[mydata$Q.Consent == 'I am unable to participate for other reasons. (Please tell us why.)'] <-
	mydata$Q.Consent_11_TEXT[mydata$Q.Consent == 'I am unable to participate for other reasons. (Please tell us why.)']
mydata$Q.Consent.other[mydata$Q.Consent == 'I do not want to participate for other reasons. (Please tell us why.)'] <-
	mydata$Q.Consent_12_TEXT[mydata$Q.Consent == 'I do not want to participate for other reasons. (Please tell us why.)']

for (i in c('Status','Progress','Finished','DistributionChannel','UserLanguage','ResponseId', 'SESSION_ID','StudyID','ResponseID','Referer','SurveyID',
			'Q.gender','Q.age','Q.learningMore','Q.Pwds.Total','Q.Pwds.R','Q.Pwds.W','Q.Pwds.C','Q.Consent_6_TEXT','Q.Consent_11_TEXT','Q.Consent_12_TEXT'))
	mydata[,c(i)] <- NULL
rm(i)

#> We count how many people qualify
table1 <- sort(table(mydata$Q.WhichPwdManager), decreasing=TRUE)

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
	 	mydata$Q.WhichPwdManager == 'RoboForm' |
	 	mydata$Q.WhichPwdManager == 'StickyPassword' |
	 	mydata$Q.WhichPwdManager == 'Zoho Vault') &
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
	mydata$Q.Consent == "I am qualified and would like to participate, but I am not at a desktop computer right now. Please contact me later." |
	mydata$Q.Consent == "I am qualified and would like to participate, but I don't have time right now. Please contact me later." |
	mydata$Q.Consent == "I do not want to participate because the study doesn't pay as much as I'd like. (Enter the price you would participate for.)" |
	mydata$Q.Consent == "I do not qualify because I do not have a desktop computer on which to perform the study tasks." |
	mydata$Q.Consent == "I do not qualify because I cannot use my password manager's desktop or web interface." |
	mydata$Q.Consent == "I am not comfortable uploading the screenshot of aggregate statistics or answering questions about my password manager." |

	mydata$Q.Consent == "I am unable to participate for other reasons. (Please tell us why.)" |
	mydata$Q.Consent == "I do not want to participate for other reasons. (Please tell us why.)" |
	mydata$Q.Consent == "I decline to participate and decline to provide a reason."
] <- FALSE
mydata$status.consented[
	mydata$Q.Consent == "Yes, I am qualified to participate in the full $5.00 study and want to start immediately."
] <- TRUE

mydata$status.contactMeLater <- FALSE
mydata$status.contactMeLater[
	mydata$Q.Consent == "I am qualified and would like to participate, but I am not at a desktop computer right now. Please contact me later." |
	mydata$Q.Consent == "I am qualified and would like to participate, but I don't have time right now. Please contact me later."
] <- TRUE

#> We analyze the qualifying info
#tmp <- mydata[,c('Q.WhichPwdManager','Q.WhichPwdManager.other','Q.Duration','Q.LearnMore','Q.Consent','status.qualified','status.declined','status.consented')]

#> We work to show tables to summarize
table2 <- table(mydata$status.qualified, mydata$status.declined, useNA = "ifany")
rownames(table2) <- c("Didn't qualify", "Qualified")
colnames(table2) <- c("Wanted to continue", "Didn't want to continue", "Didn't answer")
if (table2[1,1]!=0 | table2[1,2]!=0 | table2[2,3]!=0) {
	log.printTable(table2)
	log.spit("\nERROR: Some answers are inconsistent! Please check the table!")
	if (createlog) sink()
	stop()
}

table3 <- table(mydata$status.declined, mydata$status.consented, useNA = "ifany")
rownames(table3) <- c("Qualified and wanted to continue", "Qualified and didn't want to continue", "Didn't qualify")
colnames(table3) <- c("Didn't consent", "Consented","Didn't answer")

if (table3[1,3]!=0 | table3[2,1]!=0 | table3[2,2]!=0 | table3[3,1]!=0 | table3[3,2]!=0) {
	log.printTable(table3)
	log.spit("\nERROR: Some answers are inconsistent! Please check the table!")
	if (createlog) sink()
	stop()
}

table4 <- sort(table(mydata$Q.Consent[ !mydata$status.declined & !mydata$status.consented & !is.na(mydata$status.declined) & !is.na(mydata$status.consented) ]), decreasing = TRUE)
googlepm <- mydata[mydata$Q.WhichPwdManager == 'The Password Manager Built into Google\'s Chrome Browser (Google Password Manager)', ]

#> We isolate those who consented
consented <- mydata[mydata$status.consented & !is.na(mydata$status.consented),]
consented$Q.Generating <- factor(consented$Q.Generating.In)
consented$Q.Duration <- factor(paste(consented$Q.Duration),
							   levels = c("Between 2 months to 1 year", "Between 1 to 2 years", "Between 2 to 3 years", "Between 3 to 4 years", "More than 4 years")
)
consented$HowLongTookSurvey <- consented$Duration..in.seconds.
consented$Q.HowLongUsingPasswordManager <- as.numeric(consented$Q.Duration)
consented$Q.KnewDash <- factor(consented$Q.KnewDash, levels = c("Yes", "No"))
consented$Q.KnewDash.HowOften <- factor(consented$Q.KnewDash.HowOften, levels = c("Never", "Very Rarely", "Rarely", "Frequently", "Very Frequently"))
consented$Q.KnewDash.WilUse <- factor(consented$Q.KnewDash.WilUse, levels = c("Definitely not", "Probably not", "Maybe", "Probably", "Definitely"))
consented$Q.Duration <- factor(paste(consented$Q.Duration),
							   labels = 1:5,
							   levels = c("Between 2 months to 1 year", "Between 1 to 2 years", "Between 2 to 3 years", "Between 3 to 4 years", "More than 4 years")
)



#> We display the numbers
log.spit("Number of observations: ", nrow(mydata))
log.printTable(table1)
log.spit("")
log.spit("Participants who:")
log.spit("\t* Completed the study: ", nrow(mydata), " (100%)")
log.spit("\t* Didn't qualify: ", table3[3,3], " (", cf.asPercentage(table3[3,3]/nrow(mydata)), ")")
log.spit("\t* Qualified and didn't want to continue: ", table3[2,3], " (", cf.asPercentage(table3[2,3]/nrow(mydata)), ")")
log.spit("\t* Qualified, wanted to continue but didn't consent: ", table3[1,1], " (", cf.asPercentage(table3[1,1]/nrow(mydata)), ")")
#log.spit("\t\t- Wanted to be contacted later: ", sum(mydata$status.contactMeLater), " (", cf.asPercentage(sum(mydata$status.contactMeLater)/nrow(mydata)), ")")
log.printTable(table4, head = "\t\t - ")
log.spit("\t* Qualified, wanted to continue and consented: ", table3[1,2], " (", cf.asPercentage(table3[1,2]/nrow(mydata)), ")")

log.spit("\nParticipants who \"Won the lottery\" (users of Google Passwords Manager): ",
		 nrow(googlepm[googlepm$RandomNumber<1000,]), " of ",  nrow(googlepm),
		 " (", cf.asPercentage(nrow(googlepm[googlepm$RandomNumber<1000,])/nrow(googlepm)), ", should be ~1/15 = 6.667%)"
)
log.spit("\n------------------------------------------------------------------------------------------------\n")

#> -------------------------------------------------------------------------------------------
#> Now some analysis

log.spit("Which password manager are you using for your personal accounts? (if you use more than one, please report the one that manages the most accounts.)")
log.printTable(sort(table(consented$Q.WhichPwdManager), decreasing = TRUE))

log.spit("\nHow long have you been using a password manager?")
log.printTable(table(consented$Q.Duration))

log.spit("\nDid you know about your password manager's security dashboard (the screen you captured and uploaded) before taking this survey?")
log.printTable(table(consented$Q.KnewDash))

log.spit("\nHow often do you use the security dashboard?")
log.printTable(table(consented$Q.KnewDash.HowOften))

log.spit("\nDo you expect to use your password manager's security dashboard (the screen you captured and uploaded) in the future?")
log.printTable(table(consented$Q.KnewDash.WilUse))

#> Correlation between numerical answers
res <- cor(consented[,c('Q.HowLongUsingPasswordManager','Passwords.Total','Passwords.reused','Passwords.weak','Passwords.compromised','HowLongTookSurvey','age')])
print(res)
corrplot(res, type='upper')

#> We analyze answers of those who didn't use a password manager
log.spit("\n------------------------------------------------------------------------------------------------\n")


#> Wrap it up
rm(googlepm, res)
if (createlog) sink()
