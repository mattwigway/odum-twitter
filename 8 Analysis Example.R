# In this script, we will perform some basic analysis of tweets. For more in-depth
# techniques, I would recommend a natural language processing class.

library(rtweet)
library(tidyverse)

# pull in some tweets to analyze
tweets = search_tweets("#rstats", n=500)
tweets = mutate(tweets, plain_text=str_to_lower(plain_tweets(text)))

select(tweets, plain_text)

# First, let's look at what hashtags are most common in these tweets
# we can use the same code from Exercise 6 to extract all hashtags
tweets = mutate(tweets, regex_hashtags=str_extract_all(text, "(?<=#)[[:alnum:]_]+"))

# note that there are some tweets where rtweet-provided hashtags is NA, but the regular
# expression correctly finds the hashtags
View(select(tweets, text, hashtags, regex_hashtags))

hashtags = do.call(c, tweets$regex_hashtags)
sort(table(str_to_lower(hashtags)), decreasing=T)

# How many hashtags are included in each tweet? This uses R apply syntax to apply
# the length() function to each tweet's hashtags.
hist(vapply(tweets$regex_hashtags, length, 1))

# Are they from accounts with a lot of followers?
hist(tweets$followers_count)

# We could also do some analysis of the other tweets of the users who have tweeted about
# rstats lately
# This gets the last 10 tweets for a random sample of 25 users who have used #rstats. If you
# wanted to do more users, you would need to either apply for academic research access to the
# Twitter API, or make requests in batches spread out over time.
user_tweets = get_timeline(sample(unique(tweets$user_id), 25), n=10)
user_tweets = mutate(user_tweets, regex_hashtags=str_extract_all(text, "(?<=#)[[:alnum:]_]+"))

# What are the common hashtags among these users?
user_hashtags = do.call(c, user_tweets$regex_hashtags)
sort(table(str_to_lower(user_hashtags)), decreasing=T)
