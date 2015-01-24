# -*- Makefile -*-
#
# michael a.g. aïvázis
# orthologue
# (c) 1998-2015 all rights reserved
#


# project defaults
include feynman.def
# the name of this package
PACKAGE = access
# add this to the clean pile
PROJ_CLEAN += authorized_keys
#
SCP = scp
SERVER = orthologue.com
MANAGER = root
DESTINATION = /home/projects/feynman/.ssh
PUBLIC_KEYS = $(wildcard *.pub)

# standard build targets
all: tidy

# the local product
authorized_keys: $(PUBLIC_KEYS) grant.py grant.cfg Make.mm
	./grant.py

# convenience
deploy: authorized_keys
	$(SCP) $< $(MANAGER)@$(SERVER):$(DESTINATION)

keys: authorized_keys


# end of file 
