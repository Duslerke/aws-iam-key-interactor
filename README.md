# aws-iam-key-interactor

Bash script that allows us to perform operations with the IAM access keys for AWS accounts.

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
 ## Windows Setup
1. Clone the repository
2. Setup your aws credentials (need aws cli)
  ```
  aws configure
  ```
3. Download and install `git for Windows` - you'll need the `bash terminal` that comes with it.
   ```
   [Download 'git for Windows'](https://gitforwindows.org/)
   ```
4. Install `Chocolatey` for your Command Prompt (need this to be able to use jq dependency)
  ```
  All you need to do is just to copy one command line into CMD. [Chocolatey Install](https://chocolatey.org/install)
  ```
5. Install `jq` dependency.
  ```
  chocolatey install jq
  ```
  [Their website](https://stedolan.github.io/jq/download/)
6. Reopen your CMD and navigate to the 'aws-iam-key-interactor' repository, then run the script:
  ```
  script.sh
  ```
  This should automatically open up bash terminal and run script in it.
 ## Usage
 ```
 # Checks all user keys
 ./script.sh
 
 # Checks all user keys and prompts for deleting them
 ./script.sh allow-deletion
 ```
