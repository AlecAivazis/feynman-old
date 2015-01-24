# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#

# project settings
include feynman.def

EXPORT_WEB = \
    resources \
    templates

# standard targets
all: export

export:: export-web

# end of file
