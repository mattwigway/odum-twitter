# Most research applications of Twitter data will want to analyze the text of the tweets
# While natural language processing is beyond the scope of this course, in this exercise
# we will learn some basic text cleaning and pattern matching skills, as well as
# some Twitter-specific processing techniques.

library(rtweet)
library(tidyverse)

# first, we will load some tweets about UNC
tweets = search_tweets("#unc")

# The plain_tweets function from rtweet may be useful to clean up text, reformat curly
# quotes to straight, etc., but may also remove some useful information (e.g. URLs)
# I leave it up to you to decide whether to use this function in your own projects.
tweets = mutate(tweets, plain_text=plain_tweets(text))
View(select(tweets, text, plain_text))

# Finding tweets that contain terms
# we can use regular expressions and the str_detect function to find tweets matching a
# regular expression. For instance, let's find tweets that talk about Duke.
filter(tweets, str_detect(plain_text, "Duke")) %>% select(plain_text)

# Generally you will want to convert tweets to all lowercase when searching so that
# you find correct results regardless of capitalization. The str_to_lower() function
# can be used for this.
filter(tweets, str_detect(str_to_lower(plain_text), "duke")) %>% select(plain_text)

# Regular expressions generally match the entire string/pattern specified. For instance,
# North Carolina would match the exact phrase North Carolina, but not "North of the Carolina campus"
# There are some special characters that can be used in regular expressions. | indicates an or
filter(tweets, str_detect(str_to_lower(plain_text), "nc state|ncsu|north carolina state|duke")) %>% select(plain_text)

# Detecting hashtags
# There is already a hashtags array in the data frame, but it may drop hashtags that are near the end of the tweet
# in the current version of the Twitter API. We can use regular expressions to extract hashtags on our own
# This finds 1 or more alphanumeric characters or underscores preceded by a # sign
tweets = mutate(tweets, regex_hashtags=str_extract_all(text, "(?<=#)[[:alnum:]_]+"))
tweets$regex_hashtags
