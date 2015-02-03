# -*- Python -*-
# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# this file describes the primary url router for feynman

# django imports
from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.conf.urls.static import static
from django.conf import settings

# import the feynman applications
from . import base

# define the primary url patterns
urlpatterns = patterns('',
    url(r'^admin/', include(admin.site.urls)),
    url(r'', include(base.urls)),
    # add the static urls
) + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)

# end of file
