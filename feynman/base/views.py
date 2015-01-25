# -*- Python -*-
# -*- coding: utf-8 -*-
#
# Alec Aivazis <alec@aivazis.com>
# 
# (c) 2009-2015 all rights reserved
#

# this file describes the base views for feynman

# django imports
from django.shortcuts import render_to_response

from django.views.generic import TemplateView
from django.http import HttpResponse
from django.template import Context
from django.template.loader import get_template

# index view
def home(request):
    # return the rendered template
    return render_to_response('index.jade')

# Create your views here.
class RenderLatex(TemplateView):
    """
    render the string in the requests GET as an image using latex and return the result
    """
    # the templates for the latex document
    string_template = "latex/string.tex"
    error_template = "latex/error.tex"

    def get(self, request, **response_kwargs):
        """ 
        render the desired string to the response or an error if it fails
        """
        # default paramter values
        color ='black'
        fontsize = 5
        isMath = True
        string = ' '

        # save a reference to the request's GET parameteters
        get = request.GET
        # the context to render the template with
        context = Context({
            'string': get['equation'] if 'equation' in get else string ,
            'color': get['color'] if 'color' in get else color ,
            'fontsize': get['fontsize'] if 'fontsize' in get else fontsize ,
            'baseline': int(get['fontisize']) * 1.2 if 'fontisize' in get else fontsize * 1.2 ,
            'isMath': get['isMath'].lower() != str(not isMath).lower() if 'isMath' in get else isMath,
        })
        # grab the string template
        template = get_template(self.string_template)
        # render the template with the specfied context
        latex = template.render(context).encode('utf-8')

        # open a temporary directory where we can put the rendered latex
        with tempfile.TemporaryDirectory() as tempdir:
            # run pdflatex with the output directory pointing to the temporary loc
            process = Popen(
                ['pdflatex', '-output-directory', tempdir, '-jobname', 'tex'],
                # supress output with PIPEs
                stdin = PIPE,
                stdout = PIPE,
            )
            # send pdflatex the latex string to be rendered
            process.communicate(latex)

            # save references to the location of the pdf and png outputs
            pdf = os.path.join(tempdir, 'tex.pdf')
            raster = os.path.join(tempdir, 'tex.png')
            # use the convert command from image magick to convert the pdf to a png
            call(['convert', '-density', '300', pdf, '-quality', '90', raster])

            # after we have finished generating the latex file, open the result
            with open(raster, 'rb') as file:
                # save the contents to memory
                image = file.read()
                # create an http response with a pdf content type
                response = HttpResponse(content_type="image/png")
                # write the contents of the pdf to the response
                response.write(image)
                # return with the response
                return response


# end of file
