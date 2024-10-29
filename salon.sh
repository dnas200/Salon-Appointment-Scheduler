#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\n~~~~~ MY SALON ~~~~~'

  echo -e "\nWelcome to My Salon, how can I help you?"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # list services
  LIST_SERVICES=$($PSQL "SELECT * from services")

  # if service not available
  if [[ -z $LIST_SERVICES ]]
  then
    echo "I could not find that service. What would you like today?"
    else
    echo -e "$LIST_SERVICES" | while read SERVICE_ID BAR NAME
    do
    echo "$SERVICE_ID) $NAME"
    done
    # get service_id
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-9]+$ ]]
    then 
      MAIN_MENU "Sorry, that is not a valid option. Please enter a valid option."
      else 
      SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $SERVICES ]]
      then 
        MAIN_MENU "I could not find that service. What would you like today?"
      else
        echo -e "What's your phone number?"
        # get phone number
        read CUSTOMER_PHONE
        # find phone number if exist
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        # if phone number not available
        if [[ -z $CUSTOMER_NAME ]]
        then 
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          INSERTED_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          
          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
          echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/ *//g'), $CUSTOMER_NAME."
          read SERVICE_TIME
          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
          INSERTED_SERVICE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo $INSERTED_SERVICE_APPOINTMENT
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/ *//g') at $SERVICE_TIME, $CUSTOMER_NAME."
        fi

      fi
    fi
  fi
}

MAIN_MENU
