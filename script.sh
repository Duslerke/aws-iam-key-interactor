#!/bin/bash

ALLOW_DELETION=$1
RECREATED_KEYS=0
FILE="recreated_keys_$(date +%H%M%S).json"

trap close_file INT

close_file() {
  if [ $RECREATED_KEYS -ne 0 ]; then
    echo "]}" >> $FILE
    echo "Re-created keys have been exported to $FILE"
  fi
  exit 0
}

get_json_element() {
  echo $2 | jq '.'[$1] | jq -r $3
}

account_interactor() {
  while true; do
    echo "-- Select an action to perform for key --"
    printf "    (s) Skip" 
    printf "    (d) Delete"
    read -p "    (r) Re-create"$'\n' choice
  
    case $choice in
        [Dd]* ) echo "deleting key..."
          delete_key "$1" "$2"; break;; 
        [Rr]* ) echo "recreating key..." 
          recreate_key "$1" "$2"; break;;
        [Ss]* ) echo skipped; break;;
        * ) echo "Invalid action"; break;;
    esac
  done
}

delete_key() {
  aws iam delete-access-key --access-key-id "$1" --user-name "$2"
}

recreate_key() {
  if [ $RECREATED_KEYS -eq 0 ]; then
    create_file
  fi
  
  delete_key "$1" "$2"
  new_key=$(aws iam create-access-key --user-name $2 | jq '.AccessKey')  
  append_to_file "$new_key"
  ((RECREATED_KEYS++))
}

create_file() {
  touch $FILE
  echo '{ "AccessKeys": [ ' >> $FILE 
}

append_to_file() {
  if [ $RECREATED_KEYS -ne 0 ]; then
    echo -n "," >> $FILE
  fi
  echo $1 >> $FILE
}

check_if_user_has_keys() {
  keys=$(aws iam list-access-keys --user-name "$user" | jq '.AccessKeyMetadata')
  if [ "$keys" = "[]" ]; then
    return 1
  else
    return 0
  fi
}

show_keys() {
  keys_len=$(echo "$1" | jq length) 
  for (( j=0; j<$keys_len; j++ ))
  do 
    key_id=$(get_json_element $j "$1" ".AccessKeyId")
    #created=$(date -jf '%Y-%m-%dT%H:%M:%SZ' $(get_json_element $j "$1" ".CreateDate"))
    created=$(date -d $(get_json_element $j "$1" ".CreateDate") '+%d %b %Y')
    echo "    Key Id: $key_id ($(get_json_element $j "$1" ".Status"))"
    echo "    Created on $created"
    
    if [ "$ALLOW_DELETION" = "allow-deletion" ]; then 
      account_interactor "$key_id" "$user" 
    fi

    if (( $keys_len - $j > 1  )); then echo; fi  
  done
}

users=$(aws iam list-users | jq '.Users')
users_len=$(echo "$users" | jq length)

for (( i=0; i<$users_len; i++ ))
do
  user=$(get_json_element $i "$users" ".UserName") 
  echo "[$(($i + 1))/$users_len] IAM user: $user"
  
  check_if_user_has_keys
  if [ $? -eq 0 ]; then
    show_keys "$keys"
  else
    echo "    User has no generated keys"
  fi

  echo
  echo
done

close_file
