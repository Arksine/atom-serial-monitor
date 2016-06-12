io = require('socket.io-client')
PythonShell = require 'python-shell'
path = require 'path'


scriptPath = path.join(__dirname, 'python')
script = path.join(scriptPath, 'pyserialserver.py')


module.exports =
class SerialPort
  pySerialServer: undefined
  socket: undefined
  socketIoConnected: false
  serialPortConnected: false

  constructor: (parent) ->
    that = this

    options = {
      mode: 'text',
      pythonOptions: ['-u'],
      scriptPath: path.join(__dirname, 'python')
    }

    @pySerialServer = new PythonShell('pyserialserver.py', options)
    @pySerialServer.on('message', (message) ->
      console.log(message))

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
      parent.onPortListReceived(data))
    @socket.on('port_connected', (connection_success) ->
      console.log("Serial Port Connected.")
      if connection_success is 'true'
        that.serialPortConnected = true
        parent.onPortConnected()
      else
        that.serialPortConnected = false
        #TODO: show an error dialog that the connection failed
    )
    @socket.on('port_disconnected' , () ->
      console.log("Serial Port Disconnected")
      that.serialPortConnected = false
      parent.onPortDisconnected()
    )
    @socket.on('serial_recieved', (data)->
      parent.onSerialReceived(data))

  destroy: ->
    @pySerialServer.end((err) ->
      #error is thrown by python script when exiting, do nothing
      console.log('Finished'))
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
