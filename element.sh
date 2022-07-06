#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

# build function to query based on what type of input was given in the argument
QUERY_DATABASE() {
  # select statement to make the function select all relevant items based on the input given
  QUERY_RESULT=$($PSQL "SELECT properties.atomic_number, name, symbol, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties JOIN elements ON properties.atomic_number=elements.atomic_number JOIN types ON properties.type_id=types.type_id WHERE elements.$2='$1'")
  if [[ -z $QUERY_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    # format the message with input from query
    echo "$QUERY_RESULT" | while IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING_POINT BOILING_POINT
    do
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    done
  fi
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  # find out which variable to query (atomic_number, symbol, name)
  re='^[0-9]+$'
  query=$1
  if [[ $1 =~ $re ]] # check if input is a number
  then
    # query based on atomic number
    QUERY_DATABASE $1 'atomic_number'
  elif [[ ${#query} -lt 3 ]] # check if length of input is one or two characters long (indicates symbol)
  then
    # query based on symbol
    QUERY_DATABASE $1 'symbol'
  else
    # query based on name
    QUERY_DATABASE $1 'name'
  fi
fi

