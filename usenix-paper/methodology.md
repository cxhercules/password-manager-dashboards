# Methodology
## Recruitment
We recruited participants by advertising a $0.20 screening survey on Prolific, a task marketplace and payment intermediary similar to Amazon's Mechanical Turk but designed specifically for ``surveys and market research''[[cite: page title of prolific.co]].

> Do You Use a Password Manager and, if so, Which One?
>
> **A 1-minute survey with 3 multiple-choice questions.**
>
> We will ask (1) which password manager you use or if you don't use one, (2) a multiple-choice follow-up question, and (3) a final one-sentence yes/no question.

We worded the advertisement so that prospective participants could read it in under ten seconds and be confident that we had scoped the survey to take under a minute.  We did not identify it as a screening survey so as not to create an opportunity for participants to try to identify which answers led to additional opportunities.

We used an option provided by prolific to display the advertisement only to participants using their browser's desktop mode, as such participants using a mobile device would be less likely to have access to their password manager's desktop/web interface.

We [used | did not use] the option Prolific offers for "representative sampling."

We started our screening survey with two sentences to ensure that users of browser-based password managers knew they were, in fact, using a password manager.

> A password manager is a program that saves your passwords and enters them for you.  If you allow your web browser to save your passwords, you are using your browser's password manager.

We first asked all participants in the screening survey which password manager they used for their personal accounts. (Appendix A, Q.WhichPwdManager)

If a participant reported not using a password manager, we asked why (Appendix A, Q.WhyNay) and concluded the screening survey without asking a third question. We thanked the participants for successfully completing the survey without revealing that we were screening for a larger study.

If a participant reported using a password manager, we asked how long they had been using it. (Appendix A, Q.Duration)

We only qualified participants for the screening study if they used a qualifying password manager for over two months. (FIXME -- add who we excluded because they used a disqualified password manager.)

Of the qualifying password managers, two were most represented in our pilot samples: Google Chrome and LastPass. Were we to include all users of Chrome's password manager, the great majority of participants would be using that password manager and only a tiny fraction of our participant budget would got of third-party password managers.  We thus down-sampled Google Chrome users by randomly excluding 14 of 15 from receiving the offer to participate in the follow-up study.  (FIXME -- do we do the same for LastPass?)

The few seconds remaining of the minute of participants' time we had contracted for third question of the screening study was insufficient to explain the privacy implications of the full study and get consent, so we instead asked the following question to those who qualified for the full study.

> Do you want to earn a USD $0.40 bonus by spending up to two more minutes learning about a follow-up study that pays USD $5.00? (Appendix A, Q.FIXME) (FIXME - survey should be updated to match this question text once we all agree on it)

We showed participants who answered yes the full consent form for our study. We disclosed that we would require participants to upload a screenshot of information from their password manager and included a sample screenshot taken from the password manager they had reported using.


-- Stuarts edit stops here --


### Qualification 2
For those who passed the first qualification test, we asked:

> How long have you been using a password manager?

> This includes other password managers that you have used before.

**Stuart asks: wait?  did we just add the bit about including password manager you have used before?  Don't we want to know that they've been using the current password manager for at least two months?**

**Cristian answers: I removed the second part of the question in the last survey draft.**

We categorized the participants who responded "Less than 2 months" as having failed the second qualification test. We thanked them for successfully participating in the two-question study, without revealing that the two questions were intended to determine qualification for our full study.

The remaining participants qualified for our full study, but had only agreed to complete a two-question study.  We were obligated to pay them without burdening them with additional questions.

**Stuart asks: we could have described this as a three-question study with the same amount of time and avoided an ethical issue here.  I think we should!**

## Study Description and Consent
> We will pay you USD \$5 bonus to participate in a 15-minute follow-up study, or USD \$0.25 bonus to answer one question about why you cannot or do not want to participate.

> Otherwise, click this link to decline the bonus study, complete this survey, and accept our thanks as you have already completed your commitment to the initial two questions.

 > To participate in the full USD $5.00 follow-up study:
1. You must take this survey on a computer (not a mobile phone or tablet) on which you have your password manager installed.
2. You must be able to access to your password manager through either a desktop or web interface, as this is necessary to capture a screenshot (iOS and Android apps prevent these screenshots).
3. You must be willing to upload a screenshot of statistics generated by your password manager from your usage data. We will not ask you to upload any passwords or provide any information that would allow us to identify you.  (The statistics we are looking for are three numbers, typically from 0 to 1000.).   
(Screenshot examples)

[illustration here]     

The purpose of this study is determine whether people who password managers are benefiting from all their security features.



## Measurements
We will observe and report:

1. The proportion of reused/weak/compromised passwords that users maintain (i.e., Q2 over Q1),
1. The proportion of subjects who assert that they would rather create a password themselves instead of creating a random password (Q3),
1. What reasons people report to maintain reused/weak/compromised passwords (Q4 and related questions),
1. How do people report creating their master password, and whether they have taken precautions to not lose access to it (Q5 and related questions),
1. The proportion of subjects who recall having received a notification to change their reused/weak passwords (Q6).

## Pre-registration
The practice committing to a set of statistical tests to run prior to collecting data, or *pre-registering* the study, is becoming more commonplace given the reproducibility crisis in social science.  We pre-registered this study by publishing a SHA256 hash of this the draft of this document at is existed prior to the start of data collection.




## Hypotheses we may run
1. *Older participants are less likely to let a password manager generate random passwords for them*. We will run a logistic regression with subjects' age and gender as input, and Q3 (above) as output. We expect that since older users trust less on technology, they are less likely to let a password manager create a random password for them. We are including gender to check whether it makes a difference in terms of this behavior.

1. *Participants who have used password managers longer (B.Duration) are more likely to have fewer weak/reused passwords*. We will use a linear regression with age, gender, and how long has the person used password managers as input, and the proportion of weak/reused passwords out of the total number of stored passwords as output.

1. *Participants who have used password managers longer (B.Duration) are more likely to use a random master password*. The time that has passed since the participant starting using the password manager (B.Duration) is correlated with whether they use a random master password.

1. *Participants who have removed all weak/re-used/compromised passwords are more likely to have chosen a randomly generated master password.* We wil use a Fisher's Exact Test 2x2 contingency table with the following dimensions:
    + **Dimension 1**: "How did you create and memorize the master password for your password manager?" ("I used a random password" or "I created a password using physical randomness" or "other" has text response indicating randomization via documented coding rule.)
    + **Dimension 2**: Does uploaded dashboard image indicate 0 for weak, reused, and compromised passwords in the dashboard image.

1. *The participant's password manager is correlated with whether they choose to opt into the full study.* Participants of the password managers with the most extra information in the dashboard, which are [FIXME WITH LIST], are less likely to participate, presumably due to privacy reasons. We will use a Fisher's Exact Test with 4x4 contingency table: participated/declined, password manager is in this group/outside this group. We will exclude data for those who did not respond to the request.

1. *The participant's password manager is correlated with achieving zero weak/re-used passwords*, as measured by the number we will read from their submitted screenshot (same caveat about using the self reported number in the event of data collection failures).

1. *The participant's password manager is correlated with them achieving zero compromised passwords*, as measured by the number we will read from their submitted screenshot (using self reported data if errors in our screen shot methodology require us to disregard the screenshot).

1. *The participant's password manager is correlated with having only weak/re-used/compromised passwords for accounts they don't think it's necessary to replace* (answered 4.3.1 with "I do not need to replace any of the passwords reported as weak or re-used").

1. *The participant's password manager is correlated with whether they have known about the dashboard* (2.3, Chi2 test where table is number of yes/no answers categorized by password manager). Used to determine whether some password managers are doing more to highlight the existence of the dashboard. Newer password managers (e.g. BitWarden) may have fewer users who started using the product prior to the dashboard creation, so might want to test this hypothesis only with users who started using a password manager in the past few years.

1. *The participant's password manager is correlated with whether they use a random master password* (Q44: "I used a random password suggested by my password manager", "I created a password using a physical randomness, software, or other non-mental process. (please explain)", or if indicated by transparent researcher coding of "Other (please explain)".

1. The participant's password manager is correlated with whether they have a printed recovery kit or written password (Q45, first three answers).

*Many of the above hypotheses could be re-written for third-party password managers vs. chrome or third-party password managers vs. Safari/KeyChain.*
