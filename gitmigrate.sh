#!/bin/bash
#
#############################################################
# This step accepts and validates inputs for required       #
# USS directories and files                                 #
# User Input:                                               #
#      1. USS path to clone the newly created empty repo    #
#      2. Path to migrate.sh utility                        #
#      3. Absolute path for mapping file                    #
#############################################################
#
echo "*******************************************************************"
echo "*  Enter USS path to clone the application Git repository         *"
echo "*******************************************************************"
echo ''
#
read -p "USS Path for cloning Git repository: " ussgitpath
#
echo ''
#
if [ -d $ussgitpath ]; then
    echo "** USS path for clonning new Git repository is present...continuing"
else
    echo "** Error: $ussgitpath not found. Please start again with a valid USS path for cloning"
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
if [ -f "${ussmigrutl}/migrate.sh" ]; then
    echo "** Migration utility is present...continuing"
else
    echo "** Error: ${ussmigrutl}/migrate.sh not found. Please start again with a valid path for migration utility"
    exit 1
fi
#
echo ''
echo "*******************************************************************"
echo "*  Enter absolute path for migration mapping file                 *"
echo "*******************************************************************"
echo ''
read -p "USS Path for mapping file: " ussmapfil
#
if [ -f $ussmapfil ]; then
    echo "** Mapping file is present...continuing"
else
    echo "** Error: $ussmapfil not found. Please start again with a valid path for mapping file for migration"
  exit 1
fi
#
#############################################################
# This step accepts below input from the user and creates a #
# new GitHUb repository for application migration from      #
# Mainframe.                                                #
# User Input:                                               #
#      1. New GitHub repository name (Reponame)             #
#      2. Github User Name (Github User)                    #
#      3. Github Personal Access Token (Github Token)       #
#############################################################
#
echo ''
echo "*******************************************************************"
echo "*  Enter details to create new Git repository for the application *"
echo "*******************************************************************"
echo ''
read -p "Enter Repository Name: " reponame
#
if [ -z "$reponame" ]; then
    echo "** Error: Git repository name cannot be blank.....Please enter a valid name and run the script again"
	echo ''
	exit 1
fi
#
echo ''
read -sp "Github User ID: " user
echo ''
#
if [ -z "$user" ]; then
    echo "** Error: Git user ID cannot be blank.....Please enter a valid User Id and run the script again"
	echo ''
	exit 1
fi
#
read -sp "Github Personal Access Token: " token
echo ''
#
if [ -z "$token" ]; then
    echo "** Error: Git PAT cannot be blank.....Please enter a valid Token and run the script again"
	echo ''
	exit 1
fi
#
echo ''
echo "** Validating new git repository name against remote Github"
echo ''
#
FullRepoUrl="https://github.com/${user}/${reponame}"
#
GitResponce=$(curl -s -o /dev/null -I -w "%{http_code}" $FullRepoUrl)
#
if [ $GitResponce == '200' ]; then
    echo "** Error: Git repository ${FullRepoUrl}.git already exists....Choose a new repo name or delete existing one and run the script again"
	exit 1
else
    echo "** Git repository name is available and can be created as a new one"
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
	echo "** Error: Git repository is not created...verify the logs and rectify the issue"
	echo ''	
	exit 1
else
 	NewRepoUrl="${FullRepoUrl}.git"
	echo ''
    echo "** New Git repository ${NewRepoUrl} created successfully"
	echo ''	
fi
#
GitResponce1=$(curl -s -o /dev/null -I -w "%{http_code}" $FullRepoUrl)
#
#if [ $GitResponce1 == '200' ]; then
#	NewRepoUrl="${FullRepoUrl}.git"
#	echo ''
#    echo "** New Git repository ${NewRepoUrl} created successfully"
#	echo ''
#else
#    echo "** Error: Git repository is not created...verify the logs/check the Git credential and restart the process"
#	exit 1
#fi	
#
#############################################################
# Below step clones the newly created GitHub repo to local  #
# USS path based on user input.                             #
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
git clone -q "$NewRepoUrl" "$ussgitpath/$reponame"
#
#############################################################
# This step triggers migration process for the application. #
#############################################################
#
cd "${ussmigrutl}"
echo ''
echo "** Starting Migration from Mainframe to USS"
echo ''
pwd
#
sh migrate.sh -r "$ussgitpath" "$ussmapfil" 
#
echo "** Migration completed....please verify"
echo ''
exit