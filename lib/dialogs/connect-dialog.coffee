Dialog = require './dialog'

portsettings =
{
  autoOpen: false
  baudRate: 9600
  dataBits: 8
  stopBits: 1
  parity: 'none'
  rtscts: false
  xon: false
  xoff: false
  xany: false
  bufferSize: 65536
  parser: 'none' #TODO: add a serialport parser here
}

module.exports =
class ConnectDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon icon-x clickable', click: 'cancel'
        @strong 'Connection Settings'
      @div class: 'body', =>
        @div class: 'horizontal-control', =>
          @label class: 'setting-title', 'Serial Port:'
          @select id: 'ports', class: 'form-control', outlet: 'oPort', =>
            @option value: '0', 'No Ports Detected'
        @div class: "column", =>
          @div class: 'horizontal-control', =>
            @label class: 'setting-title', 'Baud:'
            @select id: 'ports', class: 'form-control', outlet: 'oBaud', =>
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
          @div class: 'horizontal-control', =>
            @label class: 'setting-title', 'Data Bits:'
            @select id: 'databits', class: 'form-control',
            outlet: 'oDatabits', =>
              @option value: '8', '8'
              @option value: '7', '7'
              @option value: '6', '6'
              @option value: '5', '5'
          @div class: 'horizontal-control', =>
            @label class: 'setting-title', 'Stop Bits:'
            @select id: 'stopbits', class: 'form-control',
            outlet: 'oStopbits', =>
              @option value: '1', '1'
              @option value: '2', '2'
          @div class: 'horizontal-control', =>
            @label class: 'setting-title', 'Parity:'
            @select id: 'parity', class: 'form-control', outlet: 'oParity', =>
              @option value: 'none', 'None'
              @option value: 'even', 'Even'
              @option value: 'odd', 'Odd'
              @option value: 'mark', 'Mark'
              @option value: 'space', 'Space'
        @div class: 'column', =>
          @label class: 'setting-title', 'Flow Control:'
          @div class: "checkbox", =>
            @label for: 'rtscts', =>
              @input id: 'rtscts', type: 'checkbox', outlet: 'oRtsCts'
              @div class: 'setting-title', "RTS/CTS"
          @div class: "checkbox", =>
            @label for: 'xon', =>
              @input id: 'xon', type: 'checkbox', outlet: 'oXon'
              @div class: 'setting-title', "Xon"
          @div class: "checkbox", =>
            @label for: 'xoff', =>
              @input id: 'xoff', type: 'checkbox', outlet: 'oXoff'
              @div class: 'setting-title', "Xoff"
          @div class: "checkbox", =>
            @label for: 'xany', =>
              @input id: 'xany', type: 'checkbox', outlet: 'oXany'
              @div class: 'setting-title', "Xany"
      @div class: 'buttons', =>
        @button class: 'active', click: 'connect', =>
          @i class: 'icon icon-check'
          @span 'Connect'
        @button click: 'cancel', =>
          @i class: 'icon icon-x'
          @span 'Cancel'

  activate: ->
    #TODO: get serial ports here
    #@oPort.append("<option></option>")
    return super()

  connect: ->
    comPort = @oPort.val()
    portsettings.baudRate = parseInt(@oBaud.val())
    portsettings.dataBits = parseInt(@oDatabits.val())
    portsettings.stopBits = parseInt(@oStopbits.val())
    portsettings.parity = @oParity.val()
    portsettings.rtscts = @oRtsCts.is(":checked")
    portsettings.xon = @oXon.is(":checked")
    portsettings.xoff = @oXoff.is(":checked")
    portsettings.xany = @oXany.is(":checked")

    #TODO: call parent function to set port and settings, then connect to device
    @deactivate()
    return
