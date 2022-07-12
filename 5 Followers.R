# In addition to tweets, we can find information about the relationships between users
# based on who they follow.

library(rtweet)
library(tidyverse)

# There are two functions in rtweet for retrieving followers: get_friends and get_followers
# get_friends returns the accounts a person is following, and get_followers returns the
# accounts following a person

odum_follows = get_friends("Odum_Institute")
View(odum_follows)

# the odum_follow dataframe contains the user IDs of the users Odum follows. We can
# use the lookup_users function to get their screen names.
odum_follows_users = lookup_users(odum_follows$user_id)
odum_follows = left_join(odum_follows, odum_follows_users, by="user_id")
odum_follows

# Like other rtweet functions, get_friends has an n= parameter, which is by default
# 5000. Twitter restricts most accounts to following no more than 5000 people so this
# is generally not an issue.

# get_followers gets the people who follow a user.
odum_followers = get_followers("Odum_Institute")
odum_followers

# as before, we can use lookup_users to get more information about these users
odum_followers_users = lookup_users(odum_followers$user_id)
odum_followers_users

# Like get_friends, get_followers has an n= parameter, which also defaults to 5000.
# Twitter does not have a similar limit on the number of people who can follow an account,
# so it may be advantageous to increase the n= parameter for accounts with many followers.
# You can determine how many followers a user has using the lookup_users functions. For instance,
# let's see how many followers @UNC has.
unc = lookup_users("UNC")
unc$followers_count

# UNC has 140,000 followers at this writing. If we set n that high we will exceed the rate limit
# of 75,000, so we need to set retryonratelimit=T so rtweet will split our request into multiple
# requests over time. Don't run this now, as it will lock your account for a while due to rate limits.
#unc_followers = get_followers("UNC", n=150000, retryonratelimit = T)

# User information
# lookup_users returns a wealth of information about each user. For instance, we can look
# at when the users that follow Odum_Institute joined Twitter.
# Currently, the information returned by lookup_users is actually the most recent tweet from
# each user, but that will change in future version of rtweet. This can be confusing, as
# some information may be about the tweet (e.g. created_at) rather than the user.
# For instance, we can see where Odum Institute followers are located
unique(odum_followers_users$location)

# or when their accounts were created
summary(odum_followers_users$account_created_at)

