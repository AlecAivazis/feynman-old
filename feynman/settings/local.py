# -*- Python -*-
# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# this file contains the settings necessary for local deployment of feynman

from .feynman import *

# enable debugging support
DEBUG = True
TEMPLATE_DEBUG = True
COMPRESS_DEBUG_TOGGLE = False

# add django_toolbar to the installed apps
#INSTALLED_APPS += ("debug_toolbar", )

# Database
# https://docs.djangoproject.com/en/1.7/ref/settings/#databases
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE, 'var', 'feynman', 'feynman.sqlite3'),
    }
}

# end of file
