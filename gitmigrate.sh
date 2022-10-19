#!/bin/bash
#
#############################################################
# This step accepts and validates inputs for required       #
# USS directories and files                                 #
# User Input:                                               #
#      1. USS path to clone the newly created empty repo    #
#      2. Path to migrate.sh utility                        #
#      3. Absolute path for migration.txt file              #
#############################################################
#
echo "*******************************************************************"
echo "*  Enter USS path to clone the newly created application Git repo *"
echo "*******************************************************************"
echo ''
#
read -p "USS Path for Git repository: " ussgitpath
#
echo ''
#
if [ -d $ussgitpath ]; then
    echo "** USS path for clonning new Git repository is present...continuing"
else
    echo "** Error: $ussgitpath not found. Please start again with a valid path to clone"
  exit 1
fi
#
echo ''
echo "*******************************************************************"
echo "*  Enter USS path for migrate.sh utility                          *"
echo "*******************************************************************"
echo ''
read -p "USS Path for migration utility: " ussmigrutl
#
if [ -f $ussmigrutl ]; then
    echo "** Migration utility is present...continuing"
else
    echo "** Error: $ussmigrutl not found. Please start again with a valid path for migration utility"
  exit 1
fi
#
echo ''
echo "*******************************************************************"
echo "*  Enter absolute path for migrate mapping file                   *"
echo "*******************************************************************"
echo ''
read -p "USS Path for mapping file: " ussmapfil
#
if [ -f $ussmapfil ]; then
    echo "** Mapping file is present...continuing"
else
    echo "**Error: $ussmapfil not found. Please start again with a valid path for mapping file for migration"
  exit 1
fi
#
#############################################################
# This step accepts below input from the user and creates a #
# new GItHUb repository for application migration from      #
# Mainframe.                                                #
# User Input:                                               #
#      1. New GitHub repository name (Reponame)             #
#      2. Github User Name (Github User)                    #
#      3. Github Personal Access Token (Github Token)       #
#############################################################
#
echo ''
echo "*******************************************************************"
echo "*  Enter details to create new Git repository                     *"
echo "*******************************************************************"
echo ''
read -p "Reponame: " reponame
echo ''
read -sp "Github User: " user
echo ''
read -sp "Github Token: " token
echo ''
#
echo ''
echo "** Validating new git repository name"
echo ''
#
FullRepoUrl="https://github.com/${user}/${reponame}"
#
GitResponce=$(curl -s -o /dev/null -I -w "%{http_code}" $FullRepoUrl)
#
if [ $GitResponce == '200' ]; then
    echo "** Git repository ${FullRepoUrl}.git already exists....Choose a new name or delete manually and run the script again"
	exit 1
else
    echo "** Git repo name is available to create as a new one"
	echo ''
fi
#
#NewRepoUrl=$(curl -X POST -u $user:$token https://api.github.com/user/repos -d \
#		'{"name": "'$reponame'","description":"Creating new repository '$reponame'","auto_init":"true","public":"true"}' \
#		| grep -m 1 clone | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*")
NewRepoUrl1=$(curl --insecure -X POST -u $user:$token https://api.github.com/user/repos -d \
		'{"name": "'$reponame'","description":"Creating new repository '$reponame'","auto_init":"true","public":"true"}')
#
if [ -z "$NewRepoUrl1" ]; then
	echo ''
	echo "** Git repository is not created...verify the logs and rectify the issue"
	echo ''	
	exit 1
else
    NewRepoUrl=$NewRepoUrl1
	echo ''
	echo "** New Git repository ${NewRepoUrl} created successfully"
	echo ''
fi	
#
#############################################################
# Below step clones the newly created GitHub repo to local  #
# USS path based on user input.                             #
# User Input:                                               #
#      1. USS path to clone the newly created empty repo    #
#############################################################
#
cd $ussgitpath
pwd
#
if [ -d $reponame ]; then
	echo ''
    echo "** Local directory already present...deleting it before clonning a newone"
	echo ''
	rm -rf $reponame
fi
#
echo "** Clonning new git repository to USS"
echo ''
#
git clone -q "$NewRepoUrl" "$ussgitpath"
#
#############################################################
# This step triggers migration process for the application. #
#############################################################
#
#cd "${ussmigrutl}"
#echo ''
#sh migrate.sh
echo ''
echo "** Migration completed....please verify"
echo ''
exit