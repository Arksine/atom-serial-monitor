/** @babel */

var io = require('socket.io-client')
var PythonShell = require('python-shell')
var path = require('path')

export default class SerialPort {
  constructor(callbacks) {
    this.pySerialServer = undefined
    this.socket = undefined
    this.socketIoConnected = false
    this.serialPortConnected = false

    this.setupServer(callbacks)
    this.setupSocketIO(callbacks)
  }

  setupServer(callbacks) {
    let options = {
      mode: 'text',
      pythonOptions: ['-u'],
      scriptPath: path.join(__dirname, 'python')
    }

    if (this.pySerialServer) {
      delete this.pySerialServer
    }

    this.pySerialServer = new PythonShell('pyserialserver.py', options)

    this.pySerialServer.on('message', (message) => {
      console.log("pyserialserver.py - stdout:", message)
    })

    this.pySerialServer.end( (err) => {
      console.log('pyserialserver.py finished')
      console.log(err)
      // If we didn't receive a disconnect event from socketio, we know
      // the python script crashed.  We will attempt to restart it
      if (this.socketIoConnected === true) {
        console.log(err)
        console.log("Ungraceful Disconnection, restarting pyserialserver")
        this.socketIoConnected = false
        this.serialPortConnected = false
        callbacks.onServerError.call(callbacks.obj)
        this.setupServer(callbacks)
      }
    })
  }

  setupSocketIO(callbacks) {
    this.socket = io.connect('http://localhost:8000', {reconnect: true,
    transports: ['websocket']} )

    // Socket.io built in event listneres
    this.socket.on('connect', () => {
      console.log("Socket IO connected.")
      this.socketIoConnected = true
      callbacks.onServerConnected.call(callbacks.obj)
      this.getPortList()
    })

    this.socket.on('disconnect', () => {
      console.log("Socket IO disconnected.")
      this.socketIoConnected = false
    })
    this.socket.on('error', (error) => {
      console.log("Error connecting to server: ", error)
    })
    this.socket.on('reconnect_attempt' , () => {
      console.log('Attempting to reconnect...')
    })

    // custom socket.io events
    this.socket.on('port_list' , (data) => {
      console.log("Port List Received.")
      callbacks.onPortListReceived.call(callbacks.obj,data)
    })
    this.socket.on('port_connected', (connection_success) => {
      if (connection_success === 'true') {
        console.log("Serial Port Connected.")
        this.serialPortConnected = true
      }
      else {
        console.log("Error connecting")
        this.serialPortConnected = false
      }
      callbacks.onPortConnected.call(callbacks.obj, this.serialPortConnected)
    })
    this.socket.on('port_disconnected' , () => {
      console.log("Serial Port Disconnected")
      this.serialPortConnected = false
      callbacks.onPortDisconnected.call(callbacks.obj)
    })
    this.socket.on('serial_received', (data) => {
      callbacks.onSerialReceived.call(callbacks.obj, data)
    })
  }

  destroy() {
    this.socket.disconnect()
  }

  getPortList() {
    if (this.socketIoConnected === true) {
      this.socket.emit('list_serial_ports')
    }
  }

  connectPort(options) {
    if (this.socketIoConnected === true) {
      this.socket.emit('connect_serial', options)
    }
  }

  disconnectPort() {
    if (this.socketIoConnected === true) {
      this.socket.emit('disconnect_serial')
    }
  }

  write(data) {
    if (this.serialPortConnected === true) {
      this.socket.emit('write_to_serial', data)
    }
  }

  updateSetting(setting) {
    if (this.socketIoConnected === true) {
      this.socket.emit('update_serial_setting', setting)
    }
  }
}
