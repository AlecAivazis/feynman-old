# -*- Python -*-
# -*- coding: utf-8 -*-
#
# alec aivazis
#
"""
Django settings for feynman

For more information on this file, see
https://docs.djangoproject.com/en/1.7/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.7/ref/settings/
"""

# python imports
import os
import feynman

# folder definitions
BASE = os.path.abspath(os.path.join(feynman.home, os.pardir))
# important folder definitions
TEMPLATES = os.path.join(BASE, 'templates')
RESOURCES = os.path.join(BASE, 'assets')
STATIC_DIR = os.path.join(BASE, 'static')
UPLOADS = os.path.join(STATIC_DIR, 'uploads')

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'c_j=+(4w66f+w0z22j$oapix_974gnq8@9+r4)hjf0gea%qd1j'

ALLOWED_HOSTS = ['test.feynman.com', 'feynman.aivazis.com']

# Internationalization
# https://docs.djangoproject.com/en/1.7/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True

# Application definition

django_apps = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
)

third_party_apps = (
    'compressor',
 )

feynman_apps = (
    'feynman.apps.templatetags',
)

INSTALLED_APPS = feynman_apps + third_party_apps + django_apps

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'feynman.urls'

APPEND_SLASH = True

# Static files (CSS, JavaScript, Images)

STATIC_URL = '/static/'
STATIC_ROOT = STATIC_DIR
MEDIA_ROOT = UPLOADS

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
    'compressor.finders.CompressorFinder',
)

# where the static files live
STATICFILES_DIRS = (
    RESOURCES,
)

# Template definitions

TEMPLATE_LOADERS = (
    ('pyjade.ext.django.Loader',(
        'django.template.loaders.filesystem.Loader',
        'django.template.loaders.app_directories.Loader',
    )),
)

TEMPLATE_DIRS = (
    TEMPLATES,
)

# django compressor settings

COMPRESS_ROOT = STATIC_DIR
COMPRESS_OUTPUT_DIR = "cache"

stylus_conf = ('-u jeet -u axis -u rupture -I ' +
               os.path.join(RESOURCES,'styles') +' < {infile} > {outfile}')

COMPRESS_PRECOMPILERS = (
    ('text/stylus', 'stylus '+ stylus_conf),
    ('text/coffeescript', 'coffee --compile --stdio -b'),
    ('text/cjsx', 'cjsx-transform {infile} | coffee --compile --stdio -b'),
    ('text/es6', 'babel {infile} -o {outfile}'),
)

# end of file
