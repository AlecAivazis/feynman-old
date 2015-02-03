# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# access the project defaults
include feynman.def
# the package name
PACKAGE = base/templatetags

# the list of python modules
EXPORT_PYTHON_MODULES = \
    braces.py \
    __init__.py

# the standard build targets
all: export

export:: export-package-python-modules

live:: live-package-python-modules

# end of file