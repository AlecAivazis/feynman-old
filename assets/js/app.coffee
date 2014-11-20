# this script provides the necessary behavior to start the feynman diagram application
#
# author: alec aivazis

# create a list of the patterns for the select template in a context obj
patterns = 
  patterns: [
    title: 'blank'
    pattern: 'blank'
    image: 'blank.png'
  ,
    title: 'Drell-Yan'
    pattern: 'dy'
    image: 'dy.png'
 ]


# start up the app with the designated pattern
startCanvasWithPattern = (pattern="pap") ->
  # create a new canvas with the designated pattern
  new FeynmanCanvas("#canvas", pattern)
  # close the overlay
  closeOverlay()


# register a helper with handlebars for the pattern select
Handlebars.registerHelper 'pattern', ->
  # turn my attributes into handlebar safe versions
  title = Handlebars.escapeExpression @title
  pattern = Handlebars.escapeExpression @pattern
  image = Handlebars.escapeExpression @image

  # define the html for the pattern
  pattern = """
    <div class="pattern" onclick="startCanvasWithPattern('#{pattern}')">
      <div class="title">#{title}</div>
      <img src="/images/patterns/#{image}">
    </div>
  """
  # return the string in a handlebar safe manner
  return new Handlebars.SafeString(pattern)


toggleShowStartingPatterns = ->
  # grab the current value for the cookie
  showStartingPatterns = $.cookie('feynmanCanvas_showStartingPatterns') in ["true", undefined]
  # set its value to the correct boolean rep
  $.cookie 'feynmanCanvas_showStartingPatterns', !showStartingPatterns
  # toggle the checkbox elements property
  $('#patternsOnStartup').prop 'checked', !showStartingPatterns


# when the document is loaded
$(document).ready ->
  # create a canvas out of the appropriate DOM element
  cookieVal =  $.cookie('feynmanCanvas_showStartingPatterns')
  if cookieVal in [undefined, "true"]
    # render the template for the pattern select view
    template = Handlebars.compile $('#patternSelect_template').html()
    # display the result in an overlay
    overlay template(patterns)
  else
    # create a blank canvas based on #canvas
    new FeynmanCanvas("#canvas", 'blank')

  # set the value of the checkbox elements to the correct value
  $('#patternsOnStartup').prop 'checked', cookieVal in ["true", undefined]
