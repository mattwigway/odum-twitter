# Searching tweets
# We might not want to only get tweets from specific users. For some projects, we will
# want to retrieve tweets about particular topics. For instance, let's find tweets
# using the #chapelhill hashtag.
# The main search_tweets function we use only returns results from the last 6-9 days.
# There is also search_30day and search_fullarchive for 30-day and all time searches,
# but these require special access to the twitter API.

library(rtweet)
library(tidyverse)

# To search tweets, we use the search_tweets function.
chapel_hill = search_tweets("#chapelhill")

# By default this will return 100 tweets. We can set n= higher to get more

chapel_hill = search_tweets("#chapelhill", n=300)

# If you set n higher than 18,000 (for a very popular topic), you can set retryonratelimit=T
# and rtweet will batch your requests to avoid rate limits.
# Don't run this now as it will block your account for a while until your rate limits reset

#python = search_tweets("#python", n=25000, retryonratelimit = T)

