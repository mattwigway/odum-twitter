# Connecting RTweet to Twitter
# If you just start using RTweet without doing this, it will authenticate to your personal account.
# By creating an "app" through the Twitter developer console, you can get higher rate limits
# using your own "app".

# Once you run this code once, the authentication information will be saved to your computer;
# you will not need to run this code again. You should not share this file as it contains
# your personal authentication information.

library(rtweet)

# replace the text below with your app name and keys from the instructions
create_token(
  app="app name",
  consumer_key="api_key",
  consumer_secrete="secret"
)