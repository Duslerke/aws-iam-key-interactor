#!/bin/bash

trap closeFile INT

closeFile() {
  if [ $recreatedKeys -ne 0 ]; then
    echo "]}" >> $file
    echo "Re-created keys exported to $file"
  fi
  exit 0
}

getJsonElement() {
  echo $2 | jq '.'[$1] | jq -r $3
}

accountInteractor() {
  while true; do
    echo "-- Select an action to perform for key --"
    printf "    (s) Skip" 
    printf "    (d) Delete"
    read -p "    (r) Recreate"$'\n' choice
  
    case $choice in
        [Dd]* ) echo "deleting key..."
          deleteKey "$1" "$2"; break;; 
        [Rr]* ) echo "recreating key..." 
          recreateKey "$1" "$2"; break;;
        [Ss]* ) echo skipped; break;;
        * ) echo "Invalid action"; break;;
    esac
  done
}

deleteKey() {
  aws iam delete-access-key --access-key-id "$1" --user-name "$2"
}

recreateKey() {
  if [ $recreatedKeys -eq 0 ]; then
    createFile
  fi
  
  deleteKey "$1" "$2"
  newKey=$(aws iam create-access-key --user-name $2 | jq '.AccessKey')  
  appendToFile "$newKey"
  ((recreatedKeys++))
}

createFile() {
  touch $file
  echo '{ "AccessKeys": [ ' >> $file 
}

appendToFile() {
  if [ $recreatedKeys -ne 0 ]; then
    echo -n "," >> $file
  fi
  echo $1 >> $file
}

checkIfUserHasKeys() {
  keys=$(aws iam list-access-keys --user-name "$user" | jq '.AccessKeyMetadata')
  if [ "$keys" = "[]" ]; then
    return 1
  else
    return 0
  fi
}

showKeys() {
  keysLen=$(echo "$1" | jq length) 
  for (( j=0; j<$keysLen; j++ ))
  do 
    keyId=$(getJsonElement $j "$1" ".AccessKeyId")
    #created=$(date -jf '%Y-%m-%dT%H:%M:%SZ' $(getJsonElement $j "$1" ".CreateDate"))
    created=$(date -d $(getJsonElement $j "$1" ".CreateDate") '+%d %b %Y')
    echo "    Key Id: $keyId ($(getJsonElement $j "$1" ".Status"))"
    echo "    Created on $created"
    
    if [ "$allowDeletion" = "allow-deletion" ]; then 
      accountInteractor "$keyId" "$user" 
    fi
    if (( $keysLen - $j > 1  )); then echo; fi  
  done
}

allowDeletion=$1
recreatedKeys=0
file="recreated_keys$(date +%H%m%S).json"

users=$(aws iam list-users | jq '.Users')
usersLen=$(echo "$users" | jq length)

for (( i=0; i<$usersLen; i++ ))
do
  user=$(getJsonElement $i "$users" ".UserName") 
  echo "[$(($i + 1))/$usersLen] IAM user: $user"
  
  checkIfUserHasKeys
  if [ $? -eq 0 ]; then
    showKeys "$keys"
  else
    echo "    User has no generated keys"
  fi

  echo
  echo
done

closeFile
