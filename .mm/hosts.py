# -*- coding: utf-8 -*-
#
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2014-2015 all rights reserved
#


# the builder decorator
def host(builder):
    """
    Decorate the builder with host specific options
    """
    # here is how you get host information
    host = builder.host
    # return the builder
    return builder


# end of file
