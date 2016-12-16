# dashing.js is located in the dashing framework
# It includes jquery & batman for you.
#= require dashing.js

#= require_directory .
#= require_tree ../../widgets

footerLinks = '''
  <a href="https://github.com/mozilla-services/services-quality-dashboard">Github</a>
  |
  <a href="https://firefox-test-engineering.readthedocs.io/en/latest/">Readthedocs</a>
  |
  <a href="https://wiki.mozilla.org/TestEngineering">Team Wiki</a>
  |
  <a href="https://mozilla.github.io/fxtest-dashboard/">Issues Dashboard</a>
  |
  <a href="servicebook.dev.mozaws.net">Servicebook</a>
'''

console.log("Yeah! The dashboard has started!")

Dashing.on 'ready', ->

  Dashing.widget_margins ||= [5, 5]
  Dashing.widget_base_dimensions ||= [300, 360]
  Dashing.numColumns ||= 4

  contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns

  $('.footer-links').html footerLinks

  Batman.setImmediate ->
    $('.gridster').width(contentWidth)
    $('.gridster ul:first').gridster
      widget_margins: Dashing.widget_margins
      widget_base_dimensions: Dashing.widget_base_dimensions
      avoid_overlapped_widgets: !Dashing.customGridsterLayout
      draggable:
        stop: Dashing.showGridsterInstructions
        start: -> Dashing.currentWidgetPositions = Dashing.getWidgetPositions()
