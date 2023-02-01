#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Welcome to the salon ~~~\n"

MAIN_MENU () {
  SERVICES=$($PSQL "SELECT service_id, name FROM services;");
  echo -e "Please select a service:\n"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo -e "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  # get list of service_id's
  SERVICE_IDS=$($PSQL "SELECT service_id FROM services;")
  # if input matches an id call
  if [[ "$SERVICE_IDS[*]" =~ "$SERVICE_ID_SELECTED" ]]
  then
    SCHEDULE_SERVICE $SERVICE_ID_SELECTED
  else
    MAIN_MENU
  fi
}

SCHEDULE_SERVICE () {
  if [[ ! $1 ]]
  then
    MAIN_MENU
  else
    # get phone
    echo -e "Please enter your phone number:"
    read CUSTOMER_PHONE
    # look up customer by phone
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    # if not customer
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get name
      echo -e "Please enter you name:"
      read CUSTOMER_NAME
      # add as customer
      ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    fi
    # get service time
    echo -e "Please enter the desired service time:"
    read SERVICE_TIME

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    # insert into appointments
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$1', '$SERVICE_TIME');")

    # get service_name using service_id
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $1;")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/$ *//')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/$ *//')
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi
}


MAIN_MENU