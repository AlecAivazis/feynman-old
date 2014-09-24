# -*- Makefile -*-
#
# michael a.g. aïvázis
# orthologue
# (c) 1998-2014 all rights reserved
#


PROJECT = feynman
PACKAGE = team

PROJ_CLEAN += authorized_keys


all: tidy

authorized_keys:
	./grant.py

SCP = scp
SERVER = orthologue.com
MANAGER = alec.aivazis
DESTINATION = .ssh

deploy: authorized_keys
	$(SCP) $< $(MANAGER)@$(SERVER):$(DESTINATION)


# end of file 
