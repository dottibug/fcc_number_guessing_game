#!/bin/bash

# access database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# ask for username
echo -e "\nEnter your username:"
read USERNAME

# check for username
FIND_USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

# username doesn't exist
if [[ -z $FIND_USERNAME ]]
  then
  # insert new user
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
  # get username and user_id
  if [[ $NEW_USER == "INSERT 0 1" ]]
    then
    USERNAME=$USERNAME
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    # welcome message
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  fi
  else
  # username exists
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guess_counter) FROM games WHERE user_id=$USER_ID")
  # welcome message
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
fi

# begin game: generate random number
SECRET_NUMBER=$(( RANDOM % 1001 ))
INSERT_SECRET_NUMBER=$($PSQL "INSERT INTO games(secret_number) VALUES($SECRET_NUMBER)")
GAME_ID=$($PSQL "SELECT game_id FROM games WHERE secret_number=$SECRET_NUMBER")
# echo Secret number is $SECRET_NUMBER

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS
GUESS_COUNT=1

# guess loop
while [[ $GUESS != $SECRET_NUMBER ]]
  do
    # guess lower than secret number
    if [[ $GUESS =~ ^[0-9]+$ && $GUESS -gt $SECRET_NUMBER ]]
      then
      echo "It's lower than that, guess again:"
      read GUESS
      GUESS_COUNT=$(($GUESS_COUNT + 1))

    # guess higher than secret number
    elif [[ $GUESS =~ ^[0-9]+$ && $GUESS -lt $SECRET_NUMBER ]]
      then
      echo "It's higher than that, guess again:"
      read GUESS
      GUESS_COUNT=$(($GUESS_COUNT + 1))

    # guess isn't an integer
    else 
      echo "That is not an integer, guess again:"
      read GUESS
    fi
  done

  # correct guess
  INSERT_GUESS_COUNT=$($PSQL "UPDATE games SET guess_counter=$GUESS_COUNT WHERE game_id=$GAME_ID")
  INSERT_USER_ID=$($PSQL "UPDATE games SET user_id=$USER_ID WHERE game_id=$GAME_ID")
  echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
  