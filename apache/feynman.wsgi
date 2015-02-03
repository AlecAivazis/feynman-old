# -*- Python -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

"""
WSGI config for feynman

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/1.7/howto/deployment/wsgi/
"""

# adjust the python path
import sys
sys.path = ['/home/staff/alec.aivazis/live/packages'] + sys.path

# set the environment variable django uses to hunt down application settings
import os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "feynman.settings.live")

# build the application hook
import django.core.wsgi
application = django.core.wsgi.get_wsgi_application()

# end of file
