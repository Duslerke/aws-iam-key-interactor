# aws-iam-key-interactor

Bash script that allows us to perform operations with the IAM access keys for AWS accounts.
It currently only allows to delete access keys.

## Dependencies
- aws CLI
- jq

## Setup
1. Clone the repository
2. Setup aws with your credentials
  ```
  aws configure
  ```
3. Set execution permissions to the script
  ```
  chmod +x script.sh
  ```
  
 ## Usage
 ```
 # Checks all user keys
 ./script.sh
 
 # Checks all user keys and prompts for deleting them
 ./script.sh allow-deletion
 ```
