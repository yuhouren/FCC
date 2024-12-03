#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#echo $($PSQL "TRUNCATE appointments, customers")

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n" 

MAIN_MENU() {

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  # if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    MAIN_MENU
  else
    # display available services
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done

    # ask for service to appointment
    # echo -e "\nWhich service would you like to appointment?"
    read SERVICE_ID_SELECTED

    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      # send to main menu
      MAIN_MENU
    else
      # get service availability
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      # if not available
      if [[ -z $SERVICE_NAME ]]
      then
        # send to main menu
        echo -e "\nI could not find that service.What would you like today?"
        MAIN_MENU 
      else
        # get customer info
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE

        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        # if customer doesn't exist
        if [[ -z $CUSTOMER_NAME ]]
        then
          # get new customer name
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME

          # insert new customer
          INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi

        # get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        # get time of appointment
        echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME

        # insert bike appointments
        INSERT_RENTAL_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
        # echo "I have put you down for a$SERVICE_NAME at $appointment_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      fi
    fi
  fi
}

MAIN_MENU