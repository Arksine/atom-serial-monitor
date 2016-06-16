io = require('socket.io-client')
PythonShell = require 'python-shell'
path = require 'path'


scriptPath = path.join(__dirname, 'python')
script = path.join(scriptPath, 'pyserialserver.py')

#TODO:  Need to handle ungraceful disconnections from both the python shell and
#       socket io
module.exports =
class SerialPort
  pySerialServer: undefined
  socket: undefined
  socketIoConnected: false
  serialPortConnected: false

  constructor: (serialview) ->
    that = this

    @setupServer(serialview)

    @socket = io.connect('http://localhost:8000', {reconnect: true,
    transports: ['websocket']} )

    # Socket.io built in event listneres
    @socket.on('connect', () ->
      console.log("Socket IO connected.")
      that.socketIoConnected = true
      that.getPortList())

    @socket.on('disconnect', () ->
      console.log("Socket IO disconnected.")
      @socketIoConnected = false)
    @socket.on('error', (error) ->
      console.log("Error connecting to server: ", error))
    @socket.on('reconnect_attempt' , () ->
      console.log('Attempting to reconnect...'))

    # custom socket.io events
    @socket.on('port_list' , (data) ->
      console.log("Port List Received.")
      serialview.onPortListReceived(data))
    @socket.on('port_connected', (connection_success) ->
      if connection_success is 'true'
        console.log("Serial Port Connected.")
        that.serialPortConnected = true
      else
        console.log("Error connecting")
        that.serialPortConnected = false
      serialview.onPortConnected(that.serialPortConnected)
    )
    @socket.on('port_disconnected' , () ->
      console.log("Serial Port Disconnected")
      that.serialPortConnected = false
      serialview.onPortDisconnected()
    )
    @socket.on('serial_received', (data) ->
      serialview.onSerialReceived(data)
    )

  setupServer: (serialview) ->
    that = this

    options = {
      mode: 'text',
      pythonOptions: ['-u'],
      scriptPath: path.join(__dirname, 'python')
    }

    if @pySerialServer != undefined
      delete @pySerialServer

    @pySerialServer = new PythonShell('pyserialserver.py', options)
    @pySerialServer.on('message', (message) ->
      console.log("pyserialserver.py - stdout:", message))
    @pySerialServer.end((err) ->
      console.log('pyserialserver.py finished')

      # If we didn't receive a disconnect event from socketio, we know
      # the python script crashed.  We will attempt to restart it
      if @socketIoConnected == true
        console.log(err)
        console.log("Ungraceful Disconnection, restarting pyserialserver")
        @socketIoConnected = false
        @serialPortConnected = false
        serialview.onServerError()
        that.setupServer(serialview)
      )

  destroy: ->
    @socket.disconnect()

  getPortList: ->
    if @socketIoConnected is true
      @socket.emit('list_serial_ports')

  connectPort: (options) ->
    if @socketIoConnected is true
      @socket.emit('connect_serial', options)

  disconnectPort: ->
    if @socketIoConnected is true
      @socket.emit('disconnect_serial')

  write: (data) ->
    if @serialPortConnected is true
      @socket.emit('write_to_serial', data)

  updateSetting: (setting) ->
    if @socketIoConnected is true
      @socket.emit('update_serial_setting', setting)
