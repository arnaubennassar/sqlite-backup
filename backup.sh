#!/bin/sh

# CHECK IF ENV BACKUP_LIST IS PROVIDED
if [ "$BACKUP_LIST" == "ERROR" ]
then
  echo "BACKUP_LIST MUST BE PROVIDED"
  exit 1
fi
# SPLIT ITEMS OF THE LIST
ITEMS=$(echo $BACKUP_LIST | tr "," "\n")
# ITERATE OVER ITEMS
for ITEM in $ITEMS 
do
  # SPLIT FROM / TO
  DB_FILE="$(echo $ITEM | cut -d':' -f1)"
  BACKUP_FILE="$(echo $ITEM | cut -d':' -f2)"
  echo "BACKING UP: $DB_FILE ===> $BACKUP_FILE"
  # ORIGINAL CODE
  if [ ! -d $(dirname "$BACKUP_FILE") ]
  then
    mkdir -p $(dirname "$BACKUP_FILE")
  fi

  if [ $TIMESTAMP = true ]
  then
    FINAL_BACKUP_FILE="$(echo "$BACKUP_FILE")_$(date "+%F-%H%M%S")"
  else
    FINAL_BACKUP_FILE=$BACKUP_FILE
  fi

  /usr/bin/sqlite3 $DB_FILE ".backup $FINAL_BACKUP_FILE"
  if [ $? -eq 0 ] 
  then 
    echo "$(date "+%F %T") - Backup successfull"
  else
    echo "$(date "+%F %T") - Backup unsuccessfull"
  fi

  if [ ! -z $DELETE_AFTER ] && [ $DELETE_AFTER -gt 0 ]
  then
    find $(dirname "$BACKUP_FILE") -name "$(basename "$BACKUP_FILE")*" -type f -mtime +$DELETE_AFTER -exec rm -f {} \; -exec echo "Deleted {} after $DELETE_AFTER days" \;
  fi
done