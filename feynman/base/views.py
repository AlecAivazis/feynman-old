# -*- Python -*-
# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#

# this file describes the base views for feynman

# django imports
from django.shortcuts import render_to_response

# index view
def home(request):
    # return the rendered template
    return render_to_response('index.jade')


# end of file
