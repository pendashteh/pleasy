# Pleasy

[![Build Status](https://travis-ci.com/rjzaar/pleasy.svg?branch=master)](https://travis-ci.com/rjzaar/pleasy)

This is a Devops framework for drupal sites, particularly based on varbase.
The framework is run through the pl (short for please), plcd and plvi commands.
The pl command has been added to bash commands so can be accessed anywhere. It is followed by the script name and usually which instance to be worked on, eg "pl backup stg" will backup the stage instance.
There is a yaml file which contains the framework setup. An example yaml file is provided and is ready to be used, with some tweaking required.
You set it up with the following commands

```
git clone git@github.com:rjzaar/pleasy.git 
bash ./pleasy/bin/pl  init
source ~/.bashrc
pl update
```
Now edit pl.yml with your settings or just use the defaults

You will now have a functioning pleasy.

You should now be able to install your first site:
```
pl install d8
```
OR if you want to install the varbase distribution
```
pl install var
```
You can then move around between sites using plcd
```angular2html
plcd loc #Takes you to the root of the site
plcd loc d #Takes you to the webroot fo the site
```

Drush also works. Each sitename becomes the alias. This can be accessed from anywhere.
```angular2html
drush @loc status #runs the status command on the loc site.
drush @prod_loc status #runs the status commend on the production version of the loc site.
drush @test_loc status #runs the status commend on the test version of the loc site which is on the production server.
```
Drupal console aliases are also setup.

# Config: pl.yml

The main configuration is in a single file called pl.yml. This is created from the example.pl.yml file. pl.yml needs
to be edited to suit the current user, eg setting github credentials. But it has enough information to be useable 
out of the box. The following site information is ready to go

d8: Drupal 8 install

d8c: Drupal 8 composer install

varg: varbase-project install using git

vard: dev varbase-project install using composer

varc: varbase-project install using composer 

# VARBASE

It provides various scripts for development processes which incorporate composer, cmi and backup. It includes three 
stages, dev (called loc for local), stg and prod. Communication with the production server is via drush and git or scp.
This project is also based on the varbase two repository structure, varbase and varbase-project.
This is a good way to go since most updates to varbase don't need to be updated on a varbase based project.
Those that do are included in varbase-project.
There are also a lot less files to track in varbase-project than varbase itself.
It provides an intelligent separation.

A particular site based project needs to include site specific files which should be stored on a private 
repository for backup. When moving from dev to prod the git repositories will be swapped.

# WORKFLOW

Git is the fastest and easiest way to move files. There are three repositories

Opencourse (ocrepo): A repo for just the code for opencourse (dev environment)

Production site repo (prodrepo): A repo of all of the site files (prod environment) Master branch stores prod. Dev
branch stores the new prod to be pushed up.

Production database repo (prod.sql): A private secure repo for the live database (ocback).

The suggest best way to run workflow is explained in this presentation: 
https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al
  at 29:36
  
This has been implemented with the following commands
Merge dev into master (or other branch)
```
pl gcom #will export config and commit to git
git pull # Check the pull works.
git merge master
pl runup #will run any updates. Check all is good.
git checkout master 
git merge dev #check for errors.
git push
git checkout dev # back to work
```
Process to push to production
```
pl proddown stg #copy prod to stg
pl gcom loc
pl dev2stg loc #will use git to move dev files to stg. stg has prodrepo.
pl runup stg #run updates on stage and check site.
```
You can repeat these steps to set up the live test site on the production server

```
pl updateprod stg -td
```
And/or you can run them on the live production server.
```
pl updateprod # This repeats the steps on Prod. Check all is well.
```
If there is a problem on production.

```
pl restoreprod  #This restores Prod to the old site. Only if needed.
```
 
# PLEASY RATIONALE

What makes pleasy different? Pleasy is trying to use the simplest tools (bash scripting) to leverage drupal and varbase tools 
to provide the simplest and yet powerful devops environment. This way it is easy for beginners to adopt and even improve, yet
powerful enough to use for production. It tries to take the suggested best practice from Drupal documentation and turn it into
scripts. It hopes to grow into a complete devops solution incorporating the best tools and practices available. 

# ROADMAP

1) The varbase use of Phing to install the site needs to be integrated into pleasy.

2) The varbase script varbase-update.sh needs to be integrated into pleasy.

3) A server version needs to be developed.

4) All the remaining scripts (ie with status todo) need to be updated and integrated.

5) All scripts tested with travis

6) This will become a 1.0 release

7) Lando or docker integrated into pleasy using https://github.com/pendashteh/landrop. This will be a 2.0 release

8) New functions to set up site testing using varbase behat code.

9) Automatical travis testing of any commits.

10) These new functions to set up travis tests that respond to drupal core security updates automatically and if passing auto push to production.

11) New update functions to set up travis tests that respond to varbase project updates, test automatically and create stage site which is tested automatically. One line code push to production.

Other improvements: nginx as an option. Varnish as an option. Incorporate https://github.com/drevops/drevops



Status codes

pass: Working and passing Travis CI :white_check_mark:

works: Working but not yet integrated to Travis CI :heavy_check_mark:

todo: Has not been looked at yet :question:


# FUNCTION LIST

(Click on the arrow to expand the function help.)


