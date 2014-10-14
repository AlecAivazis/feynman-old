#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# michael a.g. aïvázis
# orhtologue
# (c) 1998-2014 all rights reserved
#


"""
Build the {authorized_keys} file that grants write access to the repository
"""


# externals
import os
# framework access
import pyre


# the app declaration
class Grant(pyre.application):
    """
    Build the {authorized_keys} file that grants write access to the repository
    """
    

    # public state
    repository = pyre.properties.str()
    raw = pyre.properties.list(schema=pyre.properties.str())
    readers = pyre.properties.list(schema=pyre.properties.str())
    writers = pyre.properties.list(schema=pyre.properties.str())
    

    @pyre.export
    def main(self, *args, **kwds):
        """
        Build the {authorized_keys} file
        """
        # the command template
        command = (
            'command="bzr serve --inet --directory={}{{}}"'.format(self.repository) +
            ',no-port-forwarding,no-X11-forwarding,no-agent-forwarding {}'
            )

        # create the output file
        authorized = open('authorized_keys', 'w')

        # first the users with raw access
        for user in self.raw:
            # build the line and add write privileges
            authorized.writelines(self.readKeys(user))

        # now the writers
        for user in self.writers:
            # build the line and add write privileges
            authorized.writelines(
                command.format(' --allow-writes',key) for key in self.readKeys(user))

        # now the readers
        for user in self.readers:
            # build the line without write privileges
            authorized.writelines(
                command.format('', key) for key in self.readKeys(user))
                    
        # all done
        return 0


    # implementation details
    def readKeys(self, user):
        """
        Open all the public key file for the given {user} and return all the keys it contains
        """
        # assemble the path to the key file
        keyfile = user + '.pub'
        # read the contents
        for key in open(keyfile, 'r'):
            # show me the key
            yield key
        # all done
        return


# main
if __name__ == "__main__":
    # create one
    grant = Grant(name='grant')
    # do
    grant.run()


# end of file 