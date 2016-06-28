{View} = require 'atom-space-pen-views'

module.exports =
class ConnectionSettingsView extends View
  @content: ->
    @div class: 'connectionsettings', =>
      @div class: 'flex-box', =>
        @div class: "icon-button", id: "connect", click: 'toggleConnected', =>
          @div class: "icon large icon-zap"
          @div 'Connect'
        @div class: 'flex-column', =>
          @div class: 'flex-box', =>
            @label class: 'setting-title conn-locked', 'Port'
            @select id: 'ports', class: 'form-control conn-locked',
            outlet: 'oPort', =>
              @option value: '0', 'No Ports Detected'
            @label class: 'setting-title', 'Baud'
            @select id: 'baud', class: 'form-control',
            outlet: 'oBaud', =>
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
              @option value: '230400', '230400'
              @option value: '460800', '460800'
              @option value: '500000', '500000'
              @option value: '576000', '576000'
              @option value: '921600', '921600'
            @label class: 'setting-title conn-locked', 'Data Bits'
            @select id: 'databits', class: 'form-control conn-locked',
            outlet: 'oDatabits', =>
              @option value: '8', '8'
              @option value: '7', '7'
              @option value: '6', '6'
              @option value: '5', '5'
            @label class: 'setting-title conn-locked', 'Stop Bits'
            @select id: 'stopbits', class: 'form-control conn-locked',
            outlet: 'oStopbits', =>
              @option value: '1', '1'
              @option value: '1.5', '1.5'
              @option value: '2', '2'
            @label class: 'setting-title conn-locked', 'Parity'
            @select id: 'parity', class: 'form-control conn-locked',
            outlet: 'oParity', =>
              @option value: 'none', 'None'
              @option value: 'even', 'Even'
              @option value: 'odd', 'Odd'
              @option value: 'mark', 'Mark'
              @option value: 'space', 'Space'
          @div class: 'flex-box', =>
            @label class: 'setting-title conn-locked', 'Flow Control'
            @select id: 'flow', class: 'form-control conn-locked',
            outlet: 'oFlow', =>
              @option value: 'none', 'None'
              @option value: 'xonxoff', 'Xon/Xoff'
              @option value: 'rtscts', 'RTS/CTS'
              @option value: 'dsrdtr', 'DSR/DTR'
            @div class: "checkbox", =>
              @label for: 'rts', =>
                @input id: 'rts', type: 'checkbox', checked: 'checked',
                change: 'onSettingChanged', outlet: 'oRts'
                @div class: 'setting-title', "RTS Line"
            @div class: "checkbox", =>
              @label for: 'dtr', =>
                @input id: 'dtr', type: 'checkbox', checked: 'checked',
                change: 'onSettingChanged', outlet: 'oDtr'
                @div class: 'setting-title', "DTR Line"
            #@div class: 'btn-group', =>
              #@button id: 'rts', class: 'btn selected', outlet: 'oRts', 'RTS'
              #@button id: 'dtr', class: 'btn selected', outlet: 'oDtr', 'DTR'

  toggleConnected: (event, element) ->

  connect: (event, element) ->
    return

  disconnect: (event, element) ->
