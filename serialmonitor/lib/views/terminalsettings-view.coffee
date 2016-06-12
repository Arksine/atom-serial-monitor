{View} = require 'atom-space-pen-views'

module.exports =
class TerminalSettingsView extends View
  @content: ->
    @div class: 'terminalsettings', =>
      @div class: 'horizontal-control inline-block', =>
        @button id: 'ascii', class: 'btn tab-button selected',
        click: 'toggleByteType', 'Ascii'
        @button id: 'hex', class: 'btn tab-button',
        click: 'toggleByteType', 'Hex'


  initialize: ->

  toggleByteType: (event, element) ->
    if ( ! element.hasClass('selected'))
      element.siblings().removeClass('selected')
      element.addClass('selected')
