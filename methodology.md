## Context of the study
One major problem today is that Internet users are able to remember fewer passwords than the amount of authenticated websites or apps they visit. One possible solution is provided by password managers - most (if not all) major brands offer the possibility of generating unique, random passwords for every authenticated website that a user visits. Password managers offer also other benefits, such as entering passwords automatically in authenticated websites, and doing it based only on websites' URLs, which provides some protection against phishing.

However, since vendors have incentives to not look at users' data, we don't know whether people are using password managers to either generate random passwords or to store their manually created passwords instead. One way to know this is by looking at how many passwords are classified as "weak" or "repeated" by password managers.



## Purpose of the study

Our main goal is to determine how are people using password managers. In particular, for a set of 10 third-party password managers (1Password, Bitwarden Premium Edition, Dashlane, KeePassXC, Keeper Password Manager, Lastpass, Norton Password Manager, Password Boss, Roboform and StickyPassword), we are interested in knowing:

1. How many passwords in total does each person store in their password manager (Q1),
2. How many passwords are marked as reused, weak or compromised by password managers (Q2),
3. Whether people are more likely to create a password themselves and let the password manager store it, or whether they would let their password manager create a random password instead when creating an account on a website (Q3),
4. Whether people feel it's okay to have either reused, weak or compromised passwords (Q4),
5. How do people report to create their master password (Q5),
6. Whether people recall receiving notifications from their password managers urging them to change repeated, weak or compromised passwords (Q6).
7. How long has the person used passwords managers (Q7).

To do this, we plan to run a survey through Prolific (https://www.prolific.co/). To those subjects that claim to use one of the password managers we are interested in, we will ask to upload a picture of the dashboard provided by their password manager, masking those areas of the image that may contain private information. Responses are anonymous, and we are not asking for any private information to our subjects. Our study was approved by the IRB at the University of California, Berkeley.


## Methodology

We will observe and report:

1. The proportion of reused/weak/compromised passwords that users maintain (i.e., Q2 over Q1),
2. The proportion of subjects who assert that they would rather create a password themselves instead of creating a random password (Q3),
3. What reasons people report to maintain reused/weak/compromised passwords (Q4 and related questions),
4. How do people report creating their master password, and whether they have taken precautions to not lose access to it (Q5 and related questions),
5. The proportion of subjects who recall having received a notification to change their reused/weak passwords (Q6).

### Hypotheses we will run

1. *Older participants are less likely to let a password manager generate random passwords for them*. We will run a logistic regression with subjects' age and gender as input, and Q3 (above) as output. We expect that since older users trust less on technology, they are less likely to let a password manager create a random password for them. We are including gender to check whether it makes a difference in terms of this behavior.

1. *Participants who have used password managers longer (B.Duration) are more likely to have less weak/reused passwords*. We will use a linear regression with age, gender, and how long has the person used password managers as input, and the proportion of weak/reused passwords out of the total number of stored passwords as output.

1. *Participants who have used password managers longer (B.Duration) are more likely to use a random master password*. The time that has passed since the participant starting using the password manager (B.Duration) is correlated with whether they use a random master password.

1. *Participants who have removed all weak/re-used/compromised passwords are more likely to have chosen a randomly generated master password.* We wil use a Fisher's Exact Test 2x2 contingency table with the following dimensions:
    + Dimension 1: "How did you create and memorize the master password for your password manager?" ("I used a random password" or "I created a password using physical randomness" or "other" has text response indicating randomization via documented coding rule.)
    + Dimension 2: Does uploaded dashboard image indicate 0 for weak, reused, and compromised passwords in the dashboard image.

1. *The participant's password manager is correlated with whether they choose to opt into the full study.* Participants of the password managers with the most extra information in the dashboard, which are [FIXME WITH LIST], are less likely to participate, presumably due to privacy reasons. We will use a Fisher's Exact Test with 4x4 contingency table: participated/declined, password manager is in this group/outside this group. We will exclude data for those who did not respond to the request.

1. *The participant's password manager is correlated with achieving zero weak/re-used passwords*, as measured by the number we will read from their submitted screenshot (same caveat about using the self reported number in the event of data collection failures).

1. *The participant's password manager is correlated with them achieving zero compromised passwords*, as measured by the number we will read from their submitted screenshot (using self reported data if errors in our screen shot methodology require us to disregard the screenshot).

1. *The participant's password manager is correlated with having only weak/re-used/compromised passwords for accounts they don't think it's necessary to replace* (answered 4.3.1 with "I do not need to replace any of the passwords reported as weak or re-used").

1. *The participant's password manager is correlated with whether they have known about the dashboard* (2.3, Chi2 test where table is number of yes/no answers categorized by password manager). Used to determine whether some password managers are doing more to highlight the existence of the dashboard. Newer password managers (e.g. BitWarden) may have fewer users who started using the product prior to the dashboard creation, so might want to test this hypothesis only with users who started using a password manager in the past few years.

1. *The participant's password manager is correlated with whether they use a random master password* (Q44: "I used a random password suggested by my password manager", "I created a password using a physical randomness, software, or other non-mental process. (please explain)", or if indicated by transparent researcher coding of "Other (please explain)".

1. The participant's password manager is correlated with whether they have a printed recovery kit or written password (Q45, first three answers).

*Many of the above hypotheses could be re-written for third-party password managers vs. chrome or third-party password managers vs. Safari/KeyChain.*


### Possible changes to methodology proposed by Stuart

Since we know what password manager the participant is using when we show the consent form, should we show our example dashboard for that specific password manager instead of the generic one.


## Research team
* Stuart Schechter, imposter@berkely.edu
* David Ng, davidng@berkeley.edu
* Jacky Ho, pt.ho@berkeley.edu
* Christian Hercules, cxhercules@berkeley.edu
* Cristian Bravo-Lillo, cbravolillo@berkeley.edu

