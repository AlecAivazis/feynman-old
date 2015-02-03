# -*- Makefile -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#

# project settings
include feynman.def
# the package
PACKAGE=web/www
# the package
EXPORT_WEB = \
    resources \
    templates

# standard targets
all: export

export:: export-web

live: live-web

# end of file
