# this script provides the necessary behavior to start the feynman diagram application
#
# author: alec aivazis

# create a list of the patterns for the select template in a context obj
context = 
  patterns: [
    title: 'blank'
    pattern: 'blank'
    image: ''
  ,
    title: 'blank'
    pattern: 'blank'
    image: ''
  ,
    title: 'blank'
    pattern: 'blank'
    image: ''
  ,
    title: 'paritcle anti-particle anhil'
    pattern: 'pap'
    image: ''
  ]

# register a helper with handlebars for the pattern select
Handlebars.registerHelper 'pattern', ->
  # turn my attributes into handlebar safe versions
  title = Handlebars.escapeExpression @title
  pattern = Handlebars.escapeExpression @pattern
  image = Handlebars.escapeExpression @image

  # define the html for the pattern
  pattern = """
    <div class="pattern">
      <div>#{title}</div>
      <div> #{pattern}</div>
    </div>
  """
  # return the string in a handlebar safe manner
  return new Handlebars.SafeString(pattern)

# when the document is loaded
$(document).ready ->
  console.log context
  # create a canvas out of the appropriate DOM element
  new FeynmanCanvas("#canvas") 
  # render the template for the pattern select view
  template = Handlebars.compile $('#patternSelect').html()
  # display the result in an overlay
  #overlay template(context)
