# Searching tweets
# We might not want to only get tweets from specific users. For some projects, we will
# want to retrieve tweets about particular topics. For instance, let's find tweets
# using the #chapelhill hashtag.
# The main search_tweets function we use only returns results from the last 6-9 days,
# and the Twitter API documentation states:
#  Before digging in, it’s important to know that the standard search API is focused on relevance and not
#  completeness. This means that some Tweets and users may be missing from search results. If you want to
#  match for completeness you should consider the premium or enterprise search APIs.

# There is also search_30day and search_fullarchive for 30-day and all time searches,
# but these require premium access to the twitter API.

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

# Search operators
# You don't have to just search for hashtags. You can search for combinations of words,
# complete phrases, or sets of words.

# For example, this will search for tweets containing "chapel" and "hill" but not necessarily
# next to each other
chapel_hill = search_tweets("chapel hill")
View(chapel_hill)

# We can use the boolean OR operator to search for chapel OR hill in the same tweet
chapel_or_hill = search_tweets("chapel OR hill")
select(chapel_or_hill, text)

# We can use double quotes within our search to find an exact phrase. To use double quotes
# in the search, we need to enclose the full string in single quotes, or use \" in place of "
# in the string.
chapel_hill_phrase = search_tweets('"chapel hill"')
View(chapel_hill_phrase)

# There are number of filters available
# for instance, exclude retweets
chapel_hill_no_retweet = search_tweets("chapel hill -filter:retweets")
select(chapel_hill_no_retweet, is_retweet)

# similarly quotes or replies
# note that unlike retweets and replies, quote is singular
chapel_hill_no_quote = search_tweets("chapel hill -filter:quote")
select(chapel_hill_no_quote, is_quote)

chapel_hill_no_reply = search_tweets("chapel hill -filter:replies")
select(chapel_hill_no_reply, reply_to_status_id)

# You can remove the - to get only retweets, replies, etc.
chapel_hill_retweet = search_tweets("chapel hill filter:retweets")
select(chapel_hill_retweet, is_retweet)

# You can put - before any word to exclude
not_duke = search_tweets("chapel hill -duke")
select(not_duke, text)

# More documentation is available here: https://developer.twitter.com/en/docs/twitter-api/v1/rules-and-filtering/search-operators
