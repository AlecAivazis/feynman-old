# -*- Python -*-
# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# this file defines the url paths for the base of the feynman application

# python imports
from django.conf.urls import url, patterns

# import the views from the base application
from .views import *

# base urls
urlpatterns = patterns('',
    url(r'(?i)^$', Home.as_view()),
    url(r'(?i)^latex/$', RenderLatex.as_view()),
)

# end of file
