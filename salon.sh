#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi
  
  SERVICES=$($PSQL "select service_id, name from services")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME

  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # if there is no such a service
    SERVICE_ID=$($PSQL "select service_id from services where service_id = '$SERVICE_ID_SELECTED'")
    if [[ -z $SERVICE_ID ]]
    then
      # send to main menu
      MAIN_MENU "I could not find that service. What would you like today?"
    fi
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")

    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get new customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    # get customer_id
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")

    # get service name
    SERVICE_NAME=$($PSQL "select name from services where service_id = '$SERVICE_ID_SELECTED'")

    # get appointment time
    echo -e "\n"
    echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    
    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # exit program
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    exit
  fi
}

MAIN_MENU
