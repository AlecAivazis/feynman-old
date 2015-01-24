# -*- Python -*-
# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#

# this file defines the url paths for the base of the feynman application

# python imports
from django.conf.urls import url, patterns
from django.views.generic import TemplateView

# import the views from the base application
from .views import *

# base urls
urlpatterns = patterns('',
    url(r'(?i)^$', home),
)

# end of file
