# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# project defaults
include feynman.def
# the package name
PACKAGE = var
# the stuff in this directory goes to {var/feynman}
EXPORT_ETCDIR = $(EXPORT_ROOT)/$(PACKAGE)/$(PROJECT)

# the standard build targets
all: export

export:: export-etcdir

live: live-vardir

# end of file
