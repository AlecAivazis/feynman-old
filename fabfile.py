#!/usr/bin/env python
#
# this file describes the various tasks necessary to manage and build homepage
# author: alec aivazis

from fabric.api import *

# the server hosting the project
env.hosts = ['104.236.200.165']
# the user to connect to the server as
env.user = "feynman"


@task
def server():
    """ run the local server """
    local('./manage.py runserver')


@task
def update_dependencies():
    """ update the project dependencies """
    # go into the folder with the dependency files
    with lcd('docs'):
        # install python dependencies
        local('pip install -r pip.txt')
        # install bower dependencies
        local('bower install')
	# install node dependecies
	local('npm install -g')


@task
def init():
    """ perform the necessary tasks to initialize the project locally """
    # update the local dependencies
    update_dependencies()
    # create the local database
    local('./manage.py syncdb')


@task
def deploy():
    """ deploy the application """
    # push any changes to the local repository
    local('git push')
    # inside of the remote repository directory
    with cd('repository'):
        # update the repository
        run('git pull origin master')
        # update the local dependencies
        # run('fab update_dependencies')
        # update the database
        run('./manage.py migrate')
        # update the static files
        run('./manage.py collectstatic')
        # restart the application server
        run('sudo service gunicorn restart')


# end of file
