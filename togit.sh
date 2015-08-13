#!/bin/bash

#*************************************************************************
#						To GIT Script
#	Takes the content of a local directory, and move it to git.
#   Used to migrate a NEW project to GIT. The source could be TFS/Dimension/CVS/SVN
#   Note that your local directory will be migrated *as is*
#	Assumes that git config is executed. Example is
# 		git config --global user.name "Raman, Vivek"
# 		git config --global user.email "Vivek.Raman@nordstrom.com"
#   Version 0.1
#*************************************************************************


#Print the Usage
usage(){
  echo "Usage:  togit.sh <StashProject Name> [fileList] "
  echo " Ex: ./togit.sh sf-cap "
  echo " this migrates all the folders and subfolders to https://git.nordstrom.net/projects/sf-cap/ "
  echo " Assumptions"
  echo "    1. git config is completed"
  echo "    2. As of version 0.1 the git repositorys exists *and* are empty"
  echo "    3. Repository name is the same as local directory names"
  echo "    4. Migration is AS-IS"
  echo " Reports bugs and suggestions to Vivek Raman (x3it) "
}

# Migrate to Git!

migrate(){
# Setting up the BASE GIT Repository
echo Migrating . "$DIRS"
for DIR in $DIRS
do
lower=`echo "$DIR" | tr '[:upper:]' '[:lower:]'`
echo $lower ....
git ls-remote $BASE_STASH/${lower}.git &>-
if [ "$?" -eq 0 ]
then
	echo "$BASE_STASH/${lower}.git EXISTS..assuming empty and proceding with GIT upload..."
	cd ./$DIR
	git init
	git add --all
	git commit -m "Initial Addition using Script"
	git remote add origin $BASE_STASH/${lower}.git
	git push origin master >> togit.status
	cd ../
else
	echo "$BASE_STASH/${lower}.git repository does NOT EXIST..skipping!!"
fi
done
}


echo $#
#Argument Check
BASE_STASH=https://$USER@git.nordstrom.net/scm/$1
case $# in
1)
    usage
    echo "Proceed with migrating to STASH repo $1 "
    echo "The content of the current directory to separate git projects? (Y/n)"
    read response
    if [ "$response" = "Y" ];
    then
            #DIRS="`ls -l | grep '^d' | awk '{print $10}'`"
            `ls -d */ | cut -f1 -d'/' > sfList`
	    DIRS=`cat sfList`
            migrate
	    `rm sfList`
	    
    else
    	    echo "Exiting..."
    fi

    exit
;;
2)
    usage
    echo "Proceeding mgrate to STASH Repo $1 based on list of directories in $2 to separate git projects? (Y/n)"
    read response
    if [ "$response" = "Y" ];
    then
	echo "migrating now..."
        DIRS=`cat $2`
        migrate
    else
        echo "Exiting..."
    fi

    exit
;;
*)
  echo "$0 called with incorrect arguments"
  usage
exit
esac



