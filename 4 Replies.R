# In this exercise we will learn about searching for replies and mentions - for instance,
# if you were doing an analysis of conversations with a specific public official.

library(rtweet)
library(tidyverse)

# The search API is also how you retrieve replies to a particular user, or mentions of a user
# There is currently no way in rtweet to get replies to a specific tweet, but there is a
# new Twitter API feature to allow that, so maybe in a future version of rtweet.
replies_to_unc = search_tweets("to:UNC")
View(replies_to_unc)

# Most replies will have a reply-to status ID (the tweet they were responding to)
# and a reply-to user ID (the user they were responding to)
# Some replies do not have a reply-to status (if someone didn't
# reply to a specific tweet but just @-tagged a user at the start of the tweet).
# Retweets of replies don't contain reply_to_status_id or reply_to_user_id, it seems, so
# it may be useful to filter those out.
replies_to_unc = search_tweets("to:UNC -filter:retweets")

# If a user replied to a tweet directly, there should be a reply_to_status_id. We can use
# lookup_tweets to get the tweets referenced.
in_reply_to = lookup_tweets(unique(replies_to_unc$reply_to_status_id))

# we can then merge the data frames together to match tweets to replies
tweets_and_replies = left_join(replies_to_unc, in_reply_to, suffix=c("", "_reply"), by=c("reply_to_status_id"="status_id"))
View(select(tweets_and_replies, text, text_reply))

# Unfortunately, in the current version of rtweet, there is no way to do the reverse - get the replies
# to a particular tweet. Searching by user has to suffice for now.

# We can also broaden our search by not restricting to replies. In practice, this means
# including tweets that do not start with @UNC, but mention it elsewhere in the tweet.
mentions_unc = search_tweets("@UNC")
View(mentions_unc)


