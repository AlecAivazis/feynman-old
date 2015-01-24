# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#

# project defaults
include feynman.def
# the package name
PACKAGE = bin
# the list of files
EXPORT_BINS = \
    feynman

# the standard build targets
all: export

export:: export-binaries

# end of file
