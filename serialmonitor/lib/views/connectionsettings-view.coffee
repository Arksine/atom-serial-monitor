{View} = require 'atom-space-pen-views'

module.exports =
class ConnectionSettingsView extends View
  @content: ->
   @div class: 'connectionsettings', =>
     @div class: 'horizontal-control inline-block', =>
       @button id: 'btnConnect', class: 'btn icon icon-zap', click: 'connect', 'Connect'



  initialize: ->

  connect: (event, element) ->
