# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#


def developer(builder):
    """
    Decorate the builder with developer specific choices
    """
    # here is how you get the developer name
    name = builder.user.name
    # return the builder
    return builder


# end of file
