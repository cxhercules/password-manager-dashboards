#> We load the data
results <- read.csv('./results.csv')

#> We create convenient names for the variables that are interesting
results$age <- results$What.is.your.age.
results$gender <- results$What.is.your.gender....Selected.Choice
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

