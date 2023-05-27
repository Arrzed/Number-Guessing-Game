#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

MAIN () {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n"

  echo "Enter your username:"
  read USERNAME

  GET_USERNAME=$($PSQL "SELECT username FROM game WHERE username = '$USERNAME'")

  if [[ -z $GET_USERNAME ]]
  then
    INSERT_NEW_USER
  else
    GREET_USER
  fi

  echo -e "\nGuess the secret number between 1 and 1000:"
  NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
  read USER_INPUT
  NUMBER_OF_GUESSES=1
  START_GAME

  UPDATE_DATA
  echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"

}

# ----- functions -----

INSERT_NEW_USER () {
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO game(username,games_played,best_game) VALUES('$USERNAME', 0, 1000)")
}

GREET_USER () {
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM game WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM game WHERE username = '$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
}

START_GAME () {
  while [[ $NUMBER != $USER_INPUT ]]
  do
    if [[ ! $USER_INPUT =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    else
      if [[ $NUMBER -gt $USER_INPUT ]]
      then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
    fi
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))
    read USER_INPUT
  done
}

UPDATE_DATA () {
  GAMES_COUNT=$($PSQL "SELECT games_played FROM game WHERE username = '$USERNAME'")
  # increment by 1 the amount of games played
  INC_COUNT_RESULT=$($PSQL "UPDATE game SET games_played = $((GAMES_COUNT + 1)) WHERE username = '$USERNAME'")

  # check if this game had less tries than the best game
  RECORD=$($PSQL "SELECT best_game FROM game WHERE username = '$USERNAME'")
  if [[ $NUMBER_OF_GUESSES -lt $RECORD ]]
  then
    UPDATE_RECORD=$($PSQL "UPDATE game SET best_game = '$NUMBER_OF_GUESSES' WHERE username = '$USERNAME'")
  fi

}

MAIN