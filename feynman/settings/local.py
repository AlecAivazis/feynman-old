# -*- Python -*-
# -*- coding: utf-8 -*-
#
# alec aivazis
#
# this file contains the settings necessary for local deployment of feynman

from .base import *

# enable debugging support
DEBUG = True

# change the django compressor settings to point to a more friendly place
COMPRESS_ROOT = RESOURCES

# change the location we upload to in local dev
MEDIA_ROOT = os.path.join(RESOURCES, 'uploads')

# add django_toolbar to the installed apps
INSTALLED_APPS += ("debug_toolbar", )

# Database
# https://docs.djangoproject.com/en/1.7/ref/settings/#databases
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE, 'db', 'feynman.sqlite3'),
    }
}

# end of file
