Dialog = require './dialog'
{$} = require 'atom-space-pen-views'

portsettings =
{
  port: '0'
  baud: 9600
  databits: 8
  stopbits: 1
  parity: 'none'
  xonxoff: false
  rtscts: false
  dsrdtr: false
  dtr: true
  rts: true
}
#TODO: Add button to refresh com ports
module.exports =
class PortSettingsDialog extends Dialog
  connected: false
  enabled: true
  initialsettings: undefined

  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon icon-x clickable', click: 'cancel'
        @strong 'Serial Port Settings'
      @div class: 'body', =>
        @div class: 'dialog-control conn-locked', =>
          @label class: 'setting-title', 'Serial Port:'
          @div =>
            @button id: 'refreshbtn', class: 'btn',
            click: 'requestPortList', 'Refresh'
            @span =>
              @select id: 'ports', class: 'form-control',
              outlet: 'oPort', =>
                @option value: '0', 'No Ports Detected'
        @div class: "column", =>
          @div class: 'dialog-control', =>
            @label class: 'setting-title', 'Baud:'
            @select id: 'baud', class: 'form-control', outlet: 'oBaud',
            change: 'onSettingChanged', =>
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
        @div class: "column", =>
          @div class: 'dialog-control conn-locked', =>
            @label class: 'setting-title', 'Data Bits:'
            @select id: 'databits', class: 'form-control',
            outlet: 'oDatabits', =>
              @option value: '8', '8'
              @option value: '7', '7'
              @option value: '6', '6'
              @option value: '5', '5'
        @div class: "column", =>
          @div class: 'dialog-control conn-locked', =>
            @label class: 'setting-title', 'Stop Bits:'
            @select id: 'stopbits', class: 'form-control',
            outlet: 'oStopbits', =>
              @option value: '1', '1'
              @option value: '1.5', '1.5'
              @option value: '2', '2'
        @div class: "column", =>
          @div class: 'dialog-control conn-locked', =>
            @label class: 'setting-title', 'Parity:'
            @select id: 'parity', class: 'form-control', outlet: 'oParity', =>
              @option value: 'none', 'None'
              @option value: 'even', 'Even'
              @option value: 'odd', 'Odd'
              @option value: 'mark', 'Mark'
              @option value: 'space', 'Space'
        @div class: 'column last', =>
          @div class: 'dialog-control conn-locked', =>
            @label class: 'setting-title', 'Flow Control:'
            @select id: 'parity', class: 'form-control', outlet: 'oFlow', =>
              @option value: 'none', 'None'
              @option value: 'xonxoff', 'Xon/Xoff'
              @option value: 'rtscts', 'RTS/CTS'
              @option value: 'dsrdtr', 'DSR/DTR'
        @div class: 'block', =>
          @label class: 'setting-title', 'Port Flags:'
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
      @div class: 'buttons', =>
        @button class: 'bottom-button', click: 'apply', =>
          @i class: 'icon icon-check'
          @span 'Apply'
        @button class: 'bottom-button', click: 'cancel',
        outlet: 'oCancelBtn', =>
          @i class: 'icon icon-x'
          @span 'Cancel'

  activate: ->
    if @initialsettings is undefined
      @initialsettings = Object.assign({} , portsettings)
    else
      Object.assign(@initialsettings, portsettings)
    return super()

  requestPortList: ->
    @parentView.requestPortList()

  refreshPortList: (portlist) ->
    @oPort.empty()
    if portlist == 'none'
      @oPort.append($('<option>', {
        value: 0,
        text: 'No ports detected'
        } ))
    else
      for item in portlist
        @oPort.append($('<option>', {
          value: item.port,
          text: item.description
          } ))
    if @initialsettings != undefined
      @initialsettings.port = @oPort.val()
    else
      portsettings.port = @oPort.val()
    return

  apply: ->
    portsettings.port = @oPort.val()
    portsettings.baud = parseInt(@oBaud.val())
    portsettings.databits = parseInt(@oDatabits.val())
    portsettings.stopbits = @oStopbits.val()
    portsettings.parity = @oParity.val()
    portsettings.flowcontrol = @oFlow.val()
    portsettings.dtr = @oDtr.is(":checked")
    portsettings.rts = @oRts.is(":checked")

    switch @oFlow.val()
      when 'none'
        portsettings.xonxoff = false
        portsettings.rtscts = false
        portsettings.dsrdtr = false
      when 'xonxoff'
        portsettings.xonxoff = true
        portsettings.rtscts = false
        portsettings.dsrdtr = false
      when 'rtscts'
        portsettings.xonxoff = false
        portsettings.rtscts = true
        portsettings.dsrdtr = false
      when 'dsrdtr'
        portsettings.xonxoff = false
        portsettings.rtscts = false
        portsettings.dsrdtr = true
    @parentView.onPortSettingsApplied(portsettings)
    @deactivate()
    return

  cancel: ->
    # return the options to initial settings and do not update
    Object.assign(portsettings, @initialsettings)
    @oPort.val(portsettings.port)
    @oBaud.val(portsettings.baud.toString())
    @oDatabits.val(portsettings.databits.toString())
    @oStopbits.val(portsettings.stopbits)
    @oParity.val(portsettings.parity)
    @oFlow.val(portsettings.flowcontrol)
    @oDtr.prop("checked", portsettings.dtr)
    @oRts.prop("checked", portsettings.rts)

    if portsettings.xonxoff == true
      @oFlow.val('xonxoff')
    else if portsettings.rtscts == true
      @oFlow.val('rtscts')
    else if portsettings.dsrdtr == true
      @oFlow.val('dsrdtr')
    else
      @oFlow.val('none')
    @deactivate()
    return

  #TODO:  need to change this on apply, not here
  onSettingChanged: (event, element) ->
    id = element.attr('id')
    console.log("#{id} changed to:")
    if @connected is true
      set = {setting: undefined, value: undefined}
      set.setting = id
      if id is 'baud'
        set.value = parseInt(element.val())
      else
        set.value = element.is(":checked")
      console.log(set.value)
      @parentView.onPortSettingUpdated(set)
    return


  toggleConnected: (isConnected) ->
    @connected = isConnected
    if @connected
      @find('.conn-locked').addClass('text-disabled')
      @find('.conn-locked input').attr('disabled', '')
      @find('.conn-locked select').attr('disabled', '')
      oCancelBtn.hide()
    else
      @find('.conn-locked').removeClass('text-disabled')
      @find('.conn-locked :disabled').removeAttr('disabled')
      oCancelBtn.show()
