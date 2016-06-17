{View} = require 'atom-space-pen-views'

module.exports =
class ConnectionSettingsView extends View
  @content: ->
    @div class: 'connectionsettings', =>
      @div class: 'horizontal-control inline-block', =>
        @label class: 'inline-block setting-title', 'Baud:'
        @select id: 'baud', class: 'form-control inline-block',
        outlet: 'appendEnd', =>
          @option value: '50', '50'
          @option value: '75', '75'
          @option value: '110', '110'
          @option value: '134', '134'
          @option value: '150', '150'
          @option value: '200', '200'
          @option value: '300', '300'
          @option value: '600', '600'
          @option value: '1200', '1200'
          @option value: '1800', '1800'
          @option value: '2400', '2400'
          @option value: '4800', '4800'
          @option value: '9600', '9600', selected: 'selected'
          @option value: '19200', '19200'
          @option value: '38400', '38400'
          @option value: '57600', '57600'
          @option value: '115200', '115200'
     @div class: 'horizontal-control inline-block', =>
       @label class: 'inline-block setting-title', 'Port Flags:'
       @div class: 'inline-block btn-group', =>
         @button id: 'rts', class: 'btn selected', click: 'toggleFlag', 'RTS'
         @button id: 'dtr', class: 'btn selected', click: 'toggleFlag', 'DTR'
         @button id: 'dsr', class: 'btn', click: 'toggleFlag', 'DSR'
         @button id: 'cts', class: 'btn', click: 'toggleFlag', 'CTS'
         @button id: 'brk', class: 'btn', click: 'toggleFlag', 'BRK'

  toggleFlag: (event, element) ->
    if ( ! element.hasClass('selected'))
      element.addClass('selected')
    else
      element.removeClass('selected')
    #TODO: update serial port
