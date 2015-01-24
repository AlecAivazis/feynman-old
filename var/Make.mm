# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#

# project defaults
include feynman.def
# the package name
PACKAGE = var
# the stuff in this directory goes to {etc/feynman/apache}
EXPORT_ETCDIR = $(EXPORT_ROOT)/$(PACKAGE)/$(PROJECT)

# the standard build targets
all: export

# make sure we scope the files correctly
export:: export-etcdir

# end of file
