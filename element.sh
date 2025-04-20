#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"


if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi



if [[ $1 =~ ^[0-9]+$ ]]
then
  ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number=$1" | sed 's/ *| */ /g')

elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
then
  ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1'" | sed 's/ *| */ /g')

elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
then
    ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name='$1'" | sed 's/ *| */ /g')

else
  echo "I could not find that element in the database."
  exit 0
fi



if [[ -z $ELEMENT_INFO ]]
then
  echo "I could not find that element in the database."
  exit 0
else
  echo "$ELEMENT_INFO" | while read ATOMIC_NUMBER SYMBOL NAME
  do
    ELEMENT_PROPERTIES=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number=$ATOMIC_NUMBER" | sed 's/ *| */ /g')
    echo "$ELEMENT_PROPERTIES" | while read ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID
    do
      TYPE_NAME=$($PSQL "SELECT type FROM types WHERE type_id=$TYPE_ID")
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE_NAME, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  done
fi
