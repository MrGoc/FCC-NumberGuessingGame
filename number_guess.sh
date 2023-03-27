#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read userName

# random number betweem 1 and 1000
randomNumber=$(($RANDOM % 1000 + 1))
numberOfTries=0
guessNumber=0
gamesPlayed=0

userID=$($PSQL "SELECT user_id FROM users where user_name = '$userName'")
# if no user available
if [[ -z $userID ]]
then
  echo "Welcome, $userName! It looks like this is your first time here."
  insert_username_result=$($PSQL "INSERT INTO users(user_name, games_played) VALUES('$userName', $gamesPlayed)")
  userID=$($PSQL "SELECT user_id FROM users where user_name = '$userName'")
else
  gamesPlayed=$($PSQL "SELECT games_played FROM users where user_id = $userID")
  guessesNumber=$($PSQL "SELECT MIN(guesses_number) FROM games where user_id = $userID")
  echo "Welcome back, $userName! You have played $gamesPlayed games, and your best game took $guessesNumber guesses."
fi

(( gamesPlayed++ ))

echo "Guess the secret number between 1 and 1000:"
until [ $randomNumber == $guessNumber ]
do 
  read guessNumber
  if [[ ! $guessNumber =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    (( numberOfTries++ ))
    if [[ $guessNumber -lt $randomNumber ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $guessNumber -gt $randomNumber ]]
    then
      echo "It's lower than that, guess again:"
    fi
  fi
done

update_username_result=$($PSQL "UPDATE users set games_played = $gamesPlayed where user_id = $userID")
insert_games_result=$($PSQL "INSERT INTO games(guesses_number, user_id) VALUES($numberOfTries, $userID)")
echo "You guessed it in $numberOfTries tries. The secret number was $randomNumber. Nice job!"
