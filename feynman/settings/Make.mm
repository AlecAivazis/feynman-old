# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# access the project defaults
include feynman.def
# the package name
PACKAGE = settings
# the python modules
EXPORT_PYTHON_MODULES = \
    base.py \
    local.py \
    live.py \
    feynman.py \
    __init__.py

# the standard build targets
all: export

export:: export-package-python-modules

live: live-package-python-modules

# end of file
