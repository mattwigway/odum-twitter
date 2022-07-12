# In this exercise, we will learn basic tools to retrieve tweets from Twitter and
# analyze them in a tabular format.

# First, we need to load libraries. rtweet is the library we use for accessing Twitter,
# and tidyverse is a common library for manipulating tabular data. Lubridate is for
# manupulating dates, and bit64 for manipulating very large numbers.

library(rtweet)
library(tidyverse)
library(lubridate)
library(bit64)

# Once we've run the authentication step once on our computer, we don't need to run it again,
# and rtweet functions will "just work"

## Retrieving tweets from a single user, or a specified group of users
tweets = get_timeline("Odum_Institute")

## We now have a table containing the most recent 100 tweets from @Odum_Institute. There are a lot
## of columns, some of which will be more useful than others.
names(tweets)

## The text of the tweet is available in the text column
tweets$text

## We also have a lot of information about the tweet in the other columns. For instance,
## whether the tweet is a retweet or quote tweet
mean(tweets$is_retweet) # what proportion were retweets?
mean(tweets$is_quote) # what proportion were quote tweets

## For quote tweets, the text column contains the text of the new tweet. The
## quoted_text column contains the text of the original tweet
filter(tweets, is_quote) %>% select(status_url, text, quoted_text)

## Twitter allows replies to tweets. The reply_to_screen_name will list the user
## a tweet was a reply to (if it was a reply)
filter(tweets, !is.na(reply_to_screen_name)) %>% select(reply_to_screen_name, reply_to_status_id)

## For threads (tweets that reply to the same user), we should have the original tweet in our table also
## The tweet ID is stored as a character (string), so we need to enclose it in quotes if we are searching
## for a specific tweet
filter(tweets, reply_to_screen_name=="Odum_Institute") %>% select(reply_to_status_id, text)
filter(tweets, status_id=="1518971588955226112") %>% select(text)

## If the tweet came from a different user, though, we'll need to retrieve it separately
status_ids = filter(tweets, !is.na(reply_to_screen_name) & reply_to_screen_name != "Odum_Institute") %>%
  select(reply_to_status_id)

## We don't need quotes here, as the status IDs are already stored as strings
reply_to = lookup_tweets(status_ids$reply_to_status_id)
reply_to$text

## We can find out how many likes and retweets a status has using these columns:
summary(tweets$favorite_count)
summary(tweets$retweet_count)

## Reply count and quote count are only available in the "premium" API
summary(tweets$reply_count)
summary(tweets$quote_count)

## Hashtags and mentioned users
## Hashtags and @mentioned users are automatically parsed by rtweet.
tweets$hashtags

## They are stored as a "list column", because each tweet may have multiple
## hashtags. Lists can be searched using the %in% operator. However, we cannot just
## filter("Hashtag" %in% hashtags) because that will search the entire hashtags column,
## instead of each tweet's list of hashtags. Instead, we use rowwise() to apply the filter
## to each row individually.
rowwise(tweets) %>% filter("DataMatters" %in% hashtags) %>% ungroup()

## The hashtags may sometimes be empty even when there are hashtags. We'll see another way
## to access hashtags in a later exercise.

## For many projects, you'll only want original tweets, not retweets. We can easily
## filter these.
original_tweets = filter(tweets, !is_retweet)

## You might also want to filter out replies
no_replies = filter(tweets, !is_retweet & is.na(reply_to_status_id))

## Working with dates
## The created_at column contains the date and time when the tweet was created
# get only tweets since July 1, 2022
july_tweets = filter(tweets, created_at >= ymd("2022-07-01"))
july_tweets

## Retrieving more tweets
## You can set the n= parameter to get_timeline to retrieve up to approximately 
## 3200 tweets. Unfortunately, more tweets than that are not available through the base Twitter API.
tweets = get_timeline("Odum_Institute", n=3200)

# Sometimes, you can get a few more tweets by trying again, setting the max_id to the ID of the earliest
# tweet retrieved minus 1. R cannot handle numbers as big as tweet IDs out of the box,
# so rtweet stores them as strings. In order to subtract 1, we need to convert them
# to 64-bit numbers, using the bit64 package
min_id = min(as.integer64(tweets$status_id))

# we can then pass this as a string to the max_id parameter of another search. This might or might not get
# us a few more tweets.
max_id = as.character(min_id - 1)
tweets2 = get_timeline("Odum_Institute", max_id=max_id)

# We can combine these with the bind_rows function
tweets = bind_rows(tweets, tweets2)

## Updating previously fetched tweets
## Perhaps we've previously fetched tweets for a user. We can retrieve more recent tweets
## by specifying a since_id parameter. This will make get_timeline return up to n tweets
## tweeted more recently* than the tweet specified by since_id.
## (* tweet IDs are not perfectly sorted, but are sorted within a second or so. i.e. if two
## tweets were made within a few seconds of each other, it's possible that they would have IDs
## in the wrong order. since_id retrieves tweets with higher IDs).
## We'll filter out a few rows and update with newer tweets
older_results = slice_tail(tweets, n=nrow(tweets) - 100)

## Now we can update the tweets
newer_results = get_timeline("Odum_Institute", since_id=as.character(max(as.integer64(older_results$status_id))))
updated_results = bind_rows(older_results, newer_results)

## Saving tweets
## If you save tweets to a CSV file and then re-read to update them, you have to specify the column type for the
## tweet ID, or it will not be read correctly.
write_csv(updated_results, "test.csv")

saved = read_csv("test.csv")

## What is the type of status_id
highest_status = first(saved$status_id)
highest_status

## Floating point numbers this large don't have enough resolution to represent integer tweet IDs.
highest_status + 1 == highest_status

## Instead, we need to read the status ID as a string column. rtweet also represents the user ID
## as a string, so it's a good idea to read that as a string as well, although they aren't (yet)
## large enough to cause issues.
saved = read_csv("test.csv", col_types=cols(
  status_id=col_character(),
  user_id=col_character(),
  reply_to_status_id=col_character(),
  reply_to_user_id=col_character(),
  quoted_status_id=col_character(),
  quoted_user_id=col_character(),
  retweet_status_id=col_character(),
  retweet_user_id=col_character()
))

## If you're not using tidyverse, look up how to specify column types in your library.

## Multiple users
## get_timeline can also retrieve tweets for multiple users. In this case, the n= parameter will apply per user.
tweets = get_timeline(c("Odum_Institute", "UNCLibrary"), n=100)
View(tweets)

## Updating tweets from multiple users
## get_timeline with multiple users makes multiple requests to the twitter API,
## which can take some time, especially if you hit the rate limits. If one of the
## first users you specified tweeted in the meantime, you might miss some tweets if
## you just set since_id to the highest ID for any tweet in your dataset.
## Instead, it's better to compute per-user since_ids and use those when updating data.

# first, we'll remove the last few days of tweets - drop the most recent 25%
tweets_to_update = filter(tweets, created_at < quantile(created_at, 0.75))

per_user_since_id = group_by(tweets_to_update, user_id) %>% summarize(since_id=as.character(max(as.integer64((status_id)))))
per_user_since_id

## now we can run get_timeline for each user separately
## We split the per_user_since_id dataframe into one dataframe per user, and then use map_dfr to download
## each user's tweets
new_tweets = split(per_user_since_id, 1:nrow(per_user_since_id)) %>%
  map_dfr(function (row) {
    return(get_timeline(row$user_id, since_id=row$since_id, n=3200))
  })

updated_tweets = bind_rows(tweets_to_update, new_tweets)

## We can confirm we updated all the tweets
stopifnot(all(sort(updated_tweets$status_id) == sort(tweets$status_id)))
