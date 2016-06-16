{View, $, $$} = require 'atom-space-pen-views'
SerialPort = require "./pyserialclient"

MenuView = require "./views/menu-view"
QuickPortSettingsView = require './views/quickportsettings-view'
TerminalSettingsView = require "./views/terminalsettings-view"
SerialReceivedView = require "./views/serialreceived-view"
SerialOutputView = require "./views/serialoutput-view"

PortSettingsDialog = require "./dialogs/portsettings-dialog"



module.exports =
class SerialmonitorView extends View

  port: undefined
  portsettings: undefined

  @content: (@data) ->
    unless @data
      @data = config

    @div class: 'serialmonitor', =>
      @subview 'menuView', new MenuView()
      @subview 'terminalSettings', new TerminalSettingsView()
      @div class: 'terminal', outlet: 'terminalView', =>
        @subview 'serialReceivedView',
        new SerialReceivedView({hex: @data.termHex, ascii: @data.termAscii} )
        @subview 'portSettingsDialog', new PortSettingsDialog()
      @subview 'serialOutputView', new SerialOutputView()

  initialize: ->
    @port = new SerialPort(this)
    @active = true

  destroy: ->
    @port.destroy()
    @active = false
    return

  getTitle: ->
    return 'Serial Monitor'

  #Menu Button callbacks

  connectMenuClick: ->
    if @portsettings != undefined && @portsettings.port != '0'
      @menuView.toggleMenuItem('connect', off)
      @port.connectPort(@portsettings)
      #TODO: Show connecting indicator
    else
      alert('Please select a valid serial port.')
    return

  disconnectMenuClick: ->
    @menuView.toggleMenuItem('disconnect', off)
    @port.disconnectPort()
    return

  portsettingsMenuClick: ->
    @portSettingsDialog.activate()
    return

  #Terminal Setting Callbacks
  toggleTermByteType: (type) ->
    if type == 'ascii'
      @data.termAscii = @serialReceivedView.toggleAscii()
    else if type == 'hex'
      @data.termHex = @serialReceivedView.toggleHex()
    return

  requestPortList: ->
    @port.getPortList()
    return

  writeToSerial: (data) ->
    @port.write(data)

  # port dialog callbacks
  onPortSettingsApplied: (portsettings) ->
    @portsettings = portsettings
    return

  onPortSettingUpdated: (setting) ->
    @port.updateSetting(setting)
    return

  # SocketIO callbacks
  onSerialReceived: (data) ->
    for i in data
      @serialReceivedView.addByte(i)
    return

  onPortConnected: (connected) ->
    if connected
      @portSettingsDialog.toggleConnected(true)
      @menuView.toggleMenuItem('disconnect', on)
      #TODO: show "connected" in status bar
    else
      @menuView.toggleMenuItem('connect', on)
      alert("Error connecting to Serial Port")
    return

  onPortDisconnected: ->
    @portSettingsDialog.toggleConnected(false)
    @menuView.toggleMenuItem('connect', on)
    #TODO: show "disconnected" in status bar
    return

  onPortListReceived: (portlist) ->
    @portSettingsDialog.refreshPortList(portlist)
    return

  onServerError: ->
    @portSettingsDialog.toggleConnected(false)
    @menuView.toggleMenuItem('connect', on)
    @menuView.toggleMenuItem('disconnect', off)
