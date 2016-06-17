{View} = require 'atom-space-pen-views'

module.exports =
class TerminalSettingsView extends View
  @content: (cfg) ->
    @div class: 'terminalsettings', =>
      @div class: 'horizontal-control inline-block', =>
        @button id: 'ascii', class: 'btn tab-button',
        click: 'toggleByteType', 'Ascii'
        @button id: 'hex', class: 'btn tab-button',
        click: 'toggleByteType', 'Hex'

  initialize: (cfg) ->
    element = @find('#ascii')
    if (element.hasClass('selected'))
      if cfg.asciiEnabled == off
        element.removeClass('selected')
    else
      if cfg.asciiEnabled == on
        element.addClass('selected')

    element = @find('#hex')
    if (element.hasClass('selected'))
      if cfg.hexEnabled == off
        element.removeClass('selected')
    else
      if cfg.hexEnabled == on
        element.addClass('selected')

  update: (cfg) ->
    @initialize(cfg)

  toggleByteType: (event, element) ->
    if (element.hasClass('selected'))
      element.removeClass('selected')
    else
      element.addClass('selected')
    type = element.attr('id')
    @parentView.toggleTermByteType(type)
