# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#


# access the project defaults
include feynman.def

# my folders
RECURSE_DIRS = \
    feynman \
    web \
    bin \
    apache \
    doc \
    access \
    var \

# standard targets
all:
	BLD_ACTION="all" $(MM) recurse

tidy::
	BLD_ACTION="tidy" $(MM) recurse

clean::
	BLD_ACTION="clean" $(MM) recurse

distclean::
	BLD_ACTION="distclean" $(MM) recurse

# convenience
build: feynman lib extension defaults

test: build tests


#  shortcuts for building specific subdirectories
.PHONY: $(RECURSE_DIRS)

$(RECURSE_DIRS):
	(cd $@; $(MM))


# end of file
