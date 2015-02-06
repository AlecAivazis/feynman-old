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

# the target folders
EXPORT_RESOURCES = resources
EXPORT_TEMPLATES = templates
# the package
EXPORT_WEB = $(EXPORT_RESOURCES) $(EXPORT_TEMPLATES)
# dependency management
DEP_INSTALL = /usr/local/bin/bower install

# standard targets
all: export

export:: export-web

live: live-web
	$(SSH) $(PROJ_LIVE_USERURL) \
           '$(CD) $(PROJ_LIVE_PCKGDIR)/$(PROJECT)/$(EXPORT_RESOURCES); $(DEP_INSTALL)'


# end of file
