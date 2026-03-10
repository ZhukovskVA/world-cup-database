#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "truncate table games,teams;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #insert winner into teams
  if [[ $WINNER != "winner" ]]
  then
  #get team name
    WINNER_NAME=$($PSQL "select name from teams where name = '$WINNER';")
    #if there's no team name
    #insert into teams
    if [[ -z $WINNER_NAME ]]
    then
      INSERT_WINNER=$($PSQL "insert into teams(name) values('$WINNER');")
    fi
    if [[ $INSERT_WINNER == "INSERT 0 1" ]]
    then
      echo "Team $WINNER was succesfully inserted."
    fi
  fi

  #insert opponent into teams
  if [[ $OPPONENT != "opponent" ]]
  then
  #get team name
    OPPONENT_NAME=$($PSQL "select name from teams where name = '$OPPONENT';")
    #if there's no team name
    #insert into teams
    if [[ -z $OPPONENT_NAME ]]
    then
      INSERT_OPPONENT=$($PSQL "insert into teams(name) values('$OPPONENT');")
    fi
    if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
    then
      echo "Team $OPPONENT was succesfully inserted."
    fi
  fi

  #insert game
  if [[ $YEAR != "year" ]]
  then
    #team_id from teams
    WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER';")
    OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT';")
    #check if game isn't already in the table
    GAME_ID=$($PSQL "select game_id from games where year = $YEAR and round='$ROUND' and winner_id=$WINNER_ID\
     and opponent_id=$OPPONENT_ID and winner_goals=$WINNER_GOALS and opponent_goals=$OPPONENT_GOALS;")
    
    if [[ -z $GAME_ID ]]
    then
      INSERT_GAME_RESULT=$($PSQL "insert into games(year,round,winner_id,opponent_id,winner_goals,opponent_goals)\
       values($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WINNER_GOALS,$OPPONENT_GOALS);")

      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo -e "Game inserted succesfully:\n $YEAR | $ROUND | $WINNER_ID | $OPPONENT_ID | $WINNER_GOALS | $OPPONENT_GOALS"
      fi
    fi
  fi
done
