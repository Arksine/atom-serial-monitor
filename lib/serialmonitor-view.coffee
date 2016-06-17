{View, $, $$} = require 'atom-space-pen-views'
SerialPort = require "./pyserialclient"

MenuView = require "./views/menu-view"
ConnectionSettingsView = require './views/connectionsettings-view'
TerminalSettingsView = require "./views/terminalsettings-view"
SerialReceivedView = require "./views/serialreceived-view"
SerialSendView = require "./views/serialsend-view"
PortSettingsDialog = require "./dialogs/portsettings-dialog"

module.exports =
class SerialmonitorView extends View

  port: undefined
  config: undefined

  @content: (cfg) ->
    @div class: 'serialmonitor', =>
      @subview 'menuView', new MenuView()
      @subview 'terminalSettings', new TerminalSettingsView (cfg.termsettings)
      @div class: 'terminal', outlet: 'terminalView', =>
        @subview 'serialReceivedView',
        new SerialReceivedView(cfg.termsettings)
        @subview 'portSettingsDialog', new PortSettingsDialog(cfg.portsettings)
      @subview 'serialSendView', new SerialSendView(cfg.sendsettings)

  initialize: (cfg) ->
    console.log 'SerialMonitorView: initialize'
    @config = cfg
    @port = new SerialPort(this)
    @active = true

  update: (cfg) ->
    @initialize(cfg)
    @terminalSettings.update(cfg.termsettings)
    @serialReceivedView.update(cfg.termsettings)
    @serialSendView.update(cfg.sendsettings)
    @portSettingsDialog.update(cfg.portsettings)

    @portSettingsDialog.toggleConnected(false)
    @menuView.toggleMenuItem('connect', on)
    @menuView.toggleMenuItem('disconnect', off)

  destroy: ->
    console.log 'SerialMonitorView: destroy'
    @port.destroy()
    @active = false
    return

  getTitle: ->
    return 'Serial Monitor'

  #Menu Button callbacks

  connectMenuClick: ->
    if @config.portsettings.port != '0'
      @menuView.toggleMenuItem('connect', off)
      @port.connectPort(@config.portsettings)
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
      @config.termsettings.hexEnabled = @serialReceivedView.toggleAscii()
    else if type == 'hex'
      @config.termsettings.asciiEnabled = @serialReceivedView.toggleHex()
    return

  requestPortList: ->
    @port.getPortList()
    return

  writeToSerial: (data) ->
    @port.write(data)

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
