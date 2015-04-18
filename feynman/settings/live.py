# -*- Python -*-
# -*- coding: utf-8 -*-
#
# alec aivazis
#
# this file contains the settings necessary for local deployment of feynman

from .base import *

# disable debugging support
DEBUG = False

# Database
# https://docs.djangoproject.com/en/1.7/ref/settings/#databases
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2', 
        'NAME': '',
        'USER': '',
        'PASSWORD': '',
        'HOST': 'localhost',
        'PORT': '',
    }
}

# end of file
