
#> Initialization
library(corrplot)
createlog <- TRUE
source('./config.r')
source('./graphs.r')

if (createlog) log.startLogFile('./output.md')
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
#table1 <- sort(table(mydata$Q.WhichPwdManager), decreasing=TRUE)

# consented$WhichPM <- 'Other'
# consented$WhichPM[ consented$Q.WhichPwdManager=='LastPass' ] <- 'LastPass'
# consented$WhichPM[ consented$Q.WhichPwdManager=='The Password Manager Built into Google\'s Chrome Browser (Google Password Manager)' ] <- 'Google PM'

mydata$status.hadgoodPM <- 'Other PM or No PM'
mydata$status.hadgoodPM[
	mydata$Q.WhichPwdManager == '1Password' |
 	mydata$Q.WhichPwdManager == 'Bitwarden (Premium Edition)' |
 	mydata$Q.WhichPwdManager == 'Dashlane' |
 	mydata$Q.WhichPwdManager == 'KeePassXC' |
 	mydata$Q.WhichPwdManager == 'Keeper Password Manager' |
 	mydata$Q.WhichPwdManager == 'Norton Password Manager' |
 	mydata$Q.WhichPwdManager == 'Password Boss' |
 	mydata$Q.WhichPwdManager == 'RoboForm' |
 	mydata$Q.WhichPwdManager == 'StickyPassword' |
 	mydata$Q.WhichPwdManager == 'Zoho Vault'
] <- '3rd party PM'
mydata$status.hadgoodPM[
	mydata$Q.WhichPwdManager == 'LastPass'
] <- 'LastPass'
mydata$status.hadgoodPM[
	mydata$Q.WhichPwdManager == 'The Password Manager Built into Google\'s Chrome Browser (Google Password Manager)' & mydata$RandomNumber < 1000
] <- 'Google PM & Won Lottery'

mydata$status.qualified <- FALSE
mydata$status.qualified[ mydata$status.hadgoodPM!='Other PM' & mydata$Q.Duration!="Less than 2 months" ] <- TRUE

mydata$status.continued <- NA
mydata$status.continued[mydata$Q.LearnMore == "No thanks. I'm done."] <- FALSE
mydata$status.continued[mydata$Q.LearnMore == "Yes, I'll spend one more minute for a USD $0.25 bonus."] <- TRUE

table_1 <- table(mydata$status.hadgoodPM, mydata$status.qualified)
table_1 <- cbind(table_1, rowSums(table_1))
table_1 <- rbind(table_1, colSums(table_1))
colnames(table_1) <- c('Less than 2 months', 'More than 2 months', 'Subtotal')

table_1b <- table(mydata$Q.WhichPwdManager, mydata$status.qualified)
table_1b <- cbind(table_1b, rowSums(table_1b))
table_1b <- rbind(table_1b, colSums(table_1b))
colnames(table_1b) <- c('Less than 2 months', 'More than 2 months', 'Subtotal')


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

# table_2 <- table(mydata$status.hadgoodPM[mydata$status.qualified], mydata$status.consented[mydata$status.qualified], useNA = "ifany")
# table_2 <- cbind(table_2, rowSums(table_2))
# table_2 <- rbind(table_2, colSums(table_2))

table_2 <- table(mydata$status.hadgoodPM, mydata$status.continued)[1:3,]
table_2 <- cbind(table_2, rowSums(table_2))
table_2 <- rbind(table_2, colSums(table_2))
colnames(table_2) <- c("No thanks. I'm done", "Yes, I want to know more", "Subtotal")

table_2b <- table(mydata$Q.WhichPwdManager, mydata$status.continued)
table_2b <- cbind(table_2b, rowSums(table_2b))
table_2b <- rbind(table_2b, colSums(table_2b))
colnames(table_2b) <- c("No thanks. I'm done", "Yes, I want to know more", "Subtotal")

table_3 <- table(mydata$status.hadgoodPM, mydata$status.consented)[1:3,]
table_3 <- cbind(table_3, rowSums(table_3))
table_3 <- rbind(table_3, colSums(table_3))
colnames(table_3) <- c("Did not consent", "Consented", "Subtotal")

table_3b <- table(mydata$Q.WhichPwdManager, mydata$status.consented)
table_3b <- cbind(table_3b, rowSums(table_3b))
table_3b <- rbind(table_3b, colSums(table_3b))
colnames(table_3b) <- c("Did not consent", "Consented", "Subtotal")

mydata <- mydata[ is.na(mydata$Passwords.Total) | mydata$Passwords.Total>=5, ]

table_4 <- table(mydata$status.hadgoodPM, mydata$status.consented)[1:3,]
table_4 <- cbind(table_4, rowSums(table_4))
table_4 <- rbind(table_4, colSums(table_4))
colnames(table_4) <- c("Did not consent", "Consented", "Subtotal")

table_4b <- table(mydata$Q.WhichPwdManager, mydata$status.consented)
table_4b <- cbind(table_4b, rowSums(table_4b))
table_4b <- rbind(table_4b, colSums(table_4b))
colnames(table_4b) <- c("Did not consent", "Consented", "Subtotal")

last_filter_out <- list(
	'5fa6b23a53b8a531f3fb0eec',
	'6045f3b682a9db75811a3bb1',
	'6036e0cfe413e512bdefeada',
	'5ffbbcd80d7ede0e60ed5b7d',
	'5cfaab352e080000016ec742',
	'5ef930974bc6e0000848aff7',
	'5f44fbb89d025504e21fe930'
)
for (i in last_filter_out)
	mydata <- mydata[ mydata$PROLIFIC_PID != i, ]
rm(i)

table_4c <- table(mydata$status.hadgoodPM, mydata$status.consented)[1:3,]
table_4c <- cbind(table_4c, rowSums(table_4c))
table_4c <- rbind(table_4c, colSums(table_4c))
colnames(table_4c) <- c("Did not consent", "Consented", "Subtotal")


mydata$status.contactMeLater <- FALSE
mydata$status.contactMeLater[
	mydata$Q.Consent == "I am qualified and would like to participate, but I am not at a desktop computer right now. Please contact me later." |
	mydata$Q.Consent == "I am qualified and would like to participate, but I don't have time right now. Please contact me later."
] <- TRUE

#> We analyze the qualifying info
#tmp <- mydata[,c('Q.WhichPwdManager','Q.WhichPwdManager.other','Q.Duration','Q.LearnMore','Q.Consent','status.qualified','status.declined','status.consented')]

#> We work to show tables to summarize
# table2 <- table(mydata$status.qualified, mydata$status.declined, useNA = "ifany")
# rownames(table2) <- c("Didn't qualify", "Qualified")
# colnames(table2) <- c("Wanted to continue", "Didn't want to continue", "Didn't answer")
# if (table2[1,1]!=0 | table2[1,2]!=0 | table2[2,3]!=0) {
# 	log.printTable(table2)
# 	log.spit("\nERROR: Some answers are inconsistent! Please check the table!")
# 	if (createlog) sink()
# 	stop()
# }

# table3 <- table(mydata$status.declined, mydata$status.consented, useNA = "ifany")
# rownames(table3) <- c("Qualified and wanted to continue", "Qualified and didn't want to continue", "Didn't qualify")
# colnames(table3) <- c("Didn't consent", "Consented","Didn't answer")

# if (table3[1,3]!=0 | table3[2,1]!=0 | table3[2,2]!=0 | table3[3,1]!=0 | table3[3,2]!=0) {
# 	log.printTable(table3)
# 	log.spit("\nERROR: Some answers are inconsistent! Please check the table!")
# 	if (createlog) sink()
# 	stop()
# }

# table4 <- sort(table(mydata$Q.Consent[ !mydata$status.declined & !mydata$status.consented & !is.na(mydata$status.declined) & !is.na(mydata$status.consented) ]), decreasing = TRUE)
# googlepm <- mydata[mydata$Q.WhichPwdManager == 'The Password Manager Built into Google\'s Chrome Browser (Google Password Manager)', ]

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


#> We display the numbers
log.spit("## Summary\n")
# log.spit("* Participants who:")
# log.spit("\t* Completed the study: ", nrow(mydata), " (100%)")
# log.spit("\t* Didn't qualify: ", table3[3,3], " (", cf.asPercentage(table3[3,3]/nrow(mydata)), ")")
# log.spit("\t* Qualified and didn't want to continue: ", table3[2,3], " (", cf.asPercentage(table3[2,3]/nrow(mydata)), ")")
# log.spit("\t* Qualified, wanted to continue but didn't consent: ", table3[1,1], " (", cf.asPercentage(table3[1,1]/nrow(mydata)), ")")
# #log.spit("\t\t- Wanted to be contacted later: ", sum(mydata$status.contactMeLater), " (", cf.asPercentage(sum(mydata$status.contactMeLater)/nrow(mydata)), ")")
# log.printTable(table4, head = "\t\t - ")
# log.spit("\t* Qualified, wanted to continue and consented: ", table3[1,2], " (", cf.asPercentage(table3[1,2]/nrow(mydata)), ")")
#
# log.spit("* Participants who \"Won the lottery\" (users of Google Passwords Manager): ",
# 		 nrow(googlepm[googlepm$RandomNumber<1000,]), " of ",  nrow(googlepm),
# 		 " (", cf.asPercentage(nrow(googlepm[googlepm$RandomNumber<1000,])/nrow(googlepm)), ", should be ~1/15 = 6.667%)"
# )

log.spit("------------------------------------------------------")
log.spit("\n\nThis table is before any filters:")
print(table_1)

log.spit("------------------------------------------------------")
log.spit("\n\nThis table is the same as above, but with all password managers disaggregated:")
print(table_1b)

log.spit("------------------------------------------------------")
log.spit("\n\nThis table shows how many people said \'Yes, I want to know more\':")
print(table_2)

log.spit("------------------------------------------------------")
log.spit("\n\nThis table shows how many people said \'Yes, I want to know more\':")
print(table_2b)

log.spit("------------------------------------------------------")
log.spit("\n\nOut of those people above who said \'Yes, I want to know more\', these are those who consented:")
print(table_3)

log.spit("------------------------------------------------------")
log.spit("\n\nOut of those people above who said \'Yes, I want to know more\', these are those who consented:")
print(table_3b)

log.spit("------------------------------------------------------")
log.spit("\n\nThis is the same as above, but having filtered out those 9 people who had less than 5 passwords total stored in their PM:")
print(table_4)

log.spit("------------------------------------------------------")
log.spit("\n\nThis is the same as above, but having filtered out those 9 people who had less than 5 passwords total stored in their PM:")
print(table_4b)

log.spit("------------------------------------------------------")
log.spit("\n\nFinally, this is the same as above, but after filtering out those 7 people reported by David, who couldn't be verified manually by their screenshot")
print(table_4c)
log.spit("------------------------------------------------------")
log.spit("------------------------------------------------------")
log.spit("------------------------------------------------------")


# log.spit("\n\n## Data before filtering out\n")
# log.spit("Number of observations: ", nrow(mydata))
#
# log.spit("Which password manager are you using for your personal accounts? (if you use more than one, please report the one that manages the most accounts.)")
# log.printTable(sort(table(mydata$Q.WhichPwdManager), decreasing = TRUE))
#
# log.spit("\nHow long have you been using a password manager?")
# log.printTable(table(mydata$Q.Duration))
#
# log.spit("\nDo you want to earn a USD $0.25 bonus spending one more minute learning about a USD $5.00 follow-up study?")
# log.printTable(sort(table(mydata$Q.LearnMore)[2:3], decreasing = TRUE))
#
# log.spit("\nCan you participate in this study and do you consent to do so? (We will pay you the USD $0.25 already promised regardless of your answer.)")
# tmp <- sort(table(mydata$Q.Consent), decreasing = TRUE)
# log.printTable(tmp[2:length(tmp)])


log.spit("\n\nWhich password manager are you using for your personal accounts? (if you use more than one, please report the one that manages the most accounts.)")
log.printTable(sort(table(consented$Q.WhichPwdManager), decreasing = TRUE))

log.spit("\nHow long have you been using a password manager?")
thistable <- table(consented$Q.Duration, consented$status.hadgoodPM)
thistable <- rbind(thistable, colSums(thistable))
thistable <- cbind(thistable, rowSums(thistable))
print(thistable)

log.spit("\nDid you know about your password manager's security dashboard (the screen you captured and uploaded) before taking this survey?")
thistable <- table(consented$Q.KnewDash, consented$status.hadgoodPM)
thistable <- rbind(thistable, colSums(thistable))
thistable <- cbind(thistable, rowSums(thistable))
print(thistable)

log.spit("\nHow often do you use the security dashboard?")
thistable <- table(consented$Q.KnewDash.HowOften, consented$status.hadgoodPM)
thistable <- rbind(thistable, colSums(thistable))
thistable <- cbind(thistable, rowSums(thistable))
print(thistable)

log.spit("\nDo you expect to use your password manager's security dashboard (the screen you captured and uploaded) in the future?")
thistable <- table(consented$Q.KnewDash.WilUse, consented$status.hadgoodPM)
thistable <- rbind(thistable, colSums(thistable))
thistable <- cbind(thistable, rowSums(thistable))
print(thistable)

#> Correlation between numerical answers
# res <- cor(consented[,c('Q.HowLongUsingPasswordManager','Passwords.Total','Passwords.reused','Passwords.weak','Passwords.compromised','HowLongTookSurvey','age')])
# print(res)
# corrplot(res, type='upper')

log.spit("\nWhen you are creating an account on a website or changing your password, are you more likely to (LastPass):")
log.printTable(sort(table(consented$Q.Generating[ consented$status.hadgoodPM=='LastPass' ]), decreasing = TRUE))

log.spit("\nWhen you are creating an account on a website or changing your password, are you more likely to (3rd party PM):")
log.printTable(sort(table(consented$Q.Generating[ consented$status.hadgoodPM=='3rd party PM' ]), decreasing = TRUE))

log.spit("\nWhen you are creating an account on a website or changing your password, are you more likely to (Google PM & Won Lottery):")
log.printTable(sort(table(consented$Q.Generating[ consented$status.hadgoodPM=='Google PM & Won Lottery' ]), decreasing = TRUE))

# log.spit("\nWhy are you more likely to create a password for yourself than let your password manager create one for you?")
# log.spit(paste("\t* \"", consented$Q.Generating.In.Why[consented$Q.Generating.In.Why!=''], "\"\n", collapse = "", sep = ""))

log.spit("\n")


#> Wrap it up
if (createlog) sink()
