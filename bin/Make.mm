# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# project defaults
include feynman.def
# the package name
PACKAGE = bin
# the list of files
EXPORT_BINS = \
    feynman

# add these to the clean pile
PROJ_CLEAN = ${addprefix $(EXPORT_BINDIR)/, $(EXPORT_BINS)}

# the standard build targets
all: export

export:: export-binaries

live: live-bin

# end of file
