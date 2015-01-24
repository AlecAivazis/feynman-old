# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#


def requirements(package):
    """
    Build a dictionary with the external dependencies of the {feynman} project
    """
    # build the package instances
    packages = [
        package(name='python', optional=False),
        ]
    # build a dictionary and return it
    return { package.name: package for package in packages }


# end of file
