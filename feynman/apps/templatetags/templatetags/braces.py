# this file registers the necessary template tags to render latex
# author: alec aivazis

# django imports
from django import template
from django.template.defaultfilters import stringfilter

# grab the template library
register = template.Library()

# register the filter
@register.filter
# make sure the value is a string
@stringfilter
def add_braces(value):
    """ 
    encase the value in add_braces
    """
    return "{"+value+"}"

# end of file