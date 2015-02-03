# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# access the project defaults
include feynman.def
# the package name
PACKAGE = feynman
# clean up
PROJ_CLEAN += $(EXPORT_MODULEDIR)
# my subdirectories
RECURSE_DIRS = \
    base \
    settings \

# the python modules
EXPORT_PYTHON_MODULES = \
    urls.py \
    __init__.py

# grab the revision number
REVISION = ${strip ${shell bzr revno}}
# if not there
ifeq ($(REVISION),)
REVISION = 0
endif

# the standard build targets
all: export

tidy::
	BLD_ACTION="tidy" $(MM) recurse

clean::
	BLD_ACTION="clean" $(MM) recurse

distclean::
	BLD_ACTION="distclean" $(MM) recurse

export:: __init__.py export-python-modules
	BLD_ACTION="export" $(MM) recurse
	@$(RM) __init__.py

live: live-python-modules
	BLD_ACTION="live" $(MM) recurse

# construct my {__init__.py}
__init__.py: __init__py
	@sed -e "s:REVISION:$(REVISION):g" __init__py > __init__.py

# end of file
