# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#

# access the project defaults
include feynman.def
# the package name
PACKAGE = base

# the list of directories to visit
RECURSE_DIRS = \
    migrations \
    templatetags 

# the list of python modules
EXPORT_PYTHON_MODULES = \
    admin.py \
    models.py \
    tests.py \
    urls.py \
    views.py \
    __init__.py

# the standard build targets
all: export

tidy::
	BLD_ACTION="tidy" $(MM) recurse

clean::
	BLD_ACTION="clean" $(MM) recurse

distclean::
	BLD_ACTION="distclean" $(MM) recurse

export:: export-package-python-modules
	BLD_ACTION="export" $(MM) recurse


# end of file
