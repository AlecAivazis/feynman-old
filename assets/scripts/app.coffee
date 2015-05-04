# this script provides the necessary behavior to start the feynman diagram application
#
# author: alec aivazis

# create a list of the patterns for the select template in a context obj
patterns = [
  title: 'blank'
  pattern: 'blank'
  image: 'blank.png'
,
  title: 'Drell-Yan'
  pattern: 'dy'
  image: 'dy.png'
]


# when the document is loaded
$(document).ready ->
  # create a blank feynman canvas
  new FeynmanCanvas("#canvas", 'blank')

  # create a canvas out of the appropriate DOM element
  cookieVal =  $.cookie('feynmanCanvas_showStartingPatterns')
  # if the cookie has yet to be set or is true
  if cookieVal in [undefined, "true"]
    # show the patterns
    showPatterns()
  # cookie says not to show patterns
  else
    # close the overlay
    closeOverlay()

  # check the checkbox according to the cookie value
  $('#patternsOnStartup').prop 'checked', cookieVal in ["true", undefined]


toggleShowStartingPatterns = ->
  # grab the current value for the cookie
  showStartingPatterns = $.cookie('feynmanCanvas_showStartingPatterns') in ["true", undefined]
  # set its value to the correct boolean rep
  $.cookie 'feynmanCanvas_showStartingPatterns', !showStartingPatterns
  # toggle the checkbox elements property
  $('#patternsOnStartup').prop('checked', !showStartingPatterns)


# render the canvas with the designated pattern and create the appropriate undo element
renderPattern = (pattern="pap") ->
  # tell the current canvas to draw the right pattern
  $(document).attr('canvas').drawPattern(pattern)
  # close the overlay
  closeOverlay()


# display the patterns in an overlay
showPatterns = ->
  # render the template for the pattern select view
  template = Handlebars.compile $('#patternSelect_template').html()
  # display the result in an overlay
  overlay template(patterns: patterns)


# register a helper with handlebars for the pattern select
Handlebars.registerHelper 'pattern', ->
  # turn my attributes into handlebar safe versions
  title = Handlebars.escapeExpression @title
  pattern = Handlebars.escapeExpression @pattern
  image = Handlebars.escapeExpression @image

  # define the html for the pattern
  element = """
    <div class="pattern" onclick="renderPattern('#{pattern}')">
      <div class="title">#{title}</div>
      <img src="/static/images/patterns/#{image}">
    </div>
  """
  # return the string in a handlebar safe manner
  return new Handlebars.SafeString(element)


# end of file
