


# 1. write a function that take a vector as its argument and then calculate the mean of the vector
mean_calculator <- ... (x){
  # calculate the sum of the vector
  sum_x <- sum (x)
  # calculate the length of the vector
  length_x <- length(x)
  # calculate the mean
  mean_x <- ...
  # return the mean
  ...(mean_x)
}

# Now, let's create a vector
a_vector <- c (1,3,5,7, 15,23)
# And, calculate its mean using our function
... (a_vector)
# to make sure that our function is working correctly, compare our result with the result of the mean function in R:
mean(a_vector)



# 2. Edit your previous function so that it returns mean, length, and sum 
statistics_calculator <- ... (x){
  # calculate the sum of the vector
  sum_x <- sum (x)
  # calculate the length of the vector
  length_x <- length(x)
  # calculate the mean
  mean_x <- sum_x / length_x
  # return the mean
  statistics_list <- list(..., ..., mean_x)
  ...(statistics_list)
}

# Now, let's create a vector
a_vector <- c (1,3,5,7, 15,23)
# And, calculate its values using our function
statistics_calculator (a_vector)


# 3. Create a dataframe! It can be any kind of dataframe. Be as creative as possible. As an example, look at the dataframe below.
# It is the Premier leauge table! Now it is your turn. Create your own dataframe.
rank <- c(1:5)
team <- c("liverpool","Tottenham","Man Utd","Man City","Chelsea")
match_played <- c(rep(24, 5))
win <- c(18,17,16,15,14)
draw <- c(2,3,5,6,7)
loss <- match_played - win - draw
pts <- (win * 3) + draw

Premier_league_table <- data.frame(
  rank = rank,
  team= team,
  match_played = match_played,
  win= win, 
  draw= draw,
  loss = loss,
  pts = pts
)

