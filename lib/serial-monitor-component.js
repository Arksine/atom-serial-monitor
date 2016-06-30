/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import {pcfg} from './persistent-config'
import {CompositeDisposable} from 'atom'

import MenuComponent from './subcomponents/menu-component'
import SerialReceivedComponent from './subcomponents/serial-received-component'
import PortSettingsComponent from './subcomponents/port-settings-component'
import SerialSendComponent from './subcomponents/serial-send-component'
import SerialPort from './pyserialclient'

export default class SerialMonitorComponent {

  constructor(props) {
    this.statusBar = props.sb

    this.initialize()
    etch.setScheduler(atom.views)
    etch.initialize(this)

    this.addEventListeners()
  }

  initialize() {
    this.active = true
    this.connected = false
    this.portlist = []
    this.portsettingsactive = false
    this.rxByteCount = 0
    this.txByteCount = 0

    let callbacks = {
      onServerConnected: this.onServerConnected,
      onServerError: this.onServerError,
      onPortListReceived: this.onPortListReceived,
      onPortConnected: this.onPortConnected,
      onPortDisconnected: this.onPortDisconnected,
      onSerialReceived: this.onSerialReceived,
      obj: this
    }

    this.port = new SerialPort(callbacks)
    this.subscriptions = new CompositeDisposable()
  }

  addEventListeners() {
    // Menu Events
    this.refs.menu.refs.connect.addEventListener('click', () => {
      console.log('Connect Clicked')

      // make sure port exists
      if (this.refs.portSettings.checkPortList() &&
      pcfg.portsettings.port != '0') {
        this.port.connectPort(pcfg.portsettings)
        this.refs.menu.toggleConnect(false);
      } else {
        atom.notifications.addInfo('Please select a valid serial port')
      }

    })
    this.refs.menu.refs.disconnect.addEventListener('click', () => {
      console.log('Disconnect Clicked')
      this.port.disconnectPort()
      this.refs.menu.toggleDisconnect(false);
    })
    this.refs.menu.refs.portsettings.addEventListener('click', () => {
      console.log('PortSettings Clicked')
      this.refs.portSettings.activate()
    })


    // Port Settings Events
    this.refs.portSettings.refs.iconCancel.addEventListener('click', () => {
      this.refs.portSettings.cancel()
    })

    this.refs.portSettings.refs.btnRefreshPorts.addEventListener('click', ()=> {
      this.port.getPortList()
    })

    this.refs.portSettings.refs.btnCancel.addEventListener('click', () => {
      this.refs.portSettings.cancel()
    })

    this.refs.portSettings.refs.btnApply.addEventListener('click', () => {
      this.refs.portSettings.apply()
      this.statusBar.updateOptions()
    })

    this.refs.portSettings.element.addEventListener('change', (event) => {
      if(this.connected === true) {
        var updatedSetting = {setting: undefined, value: undefined}
        if (event.target == this.refs.portSettings.refs.selBaud) {
          updatedSetting.setting = 'baud'
          updatedSetting.value = parseInt(event.target.value)
        } else if (event.target == this.refs.portSettings.refs.cbxRts) {
          updatedSetting.setting = 'rts'
          updatedSetting.value = event.target.checked
        } else if (event.target == this.refs.portSettings.refs.cbxDtr) {
          updatedSetting.setting = event.target.checked
        }
        this.port.updateSetting(updatedSetting)
        this.statusBar.updateOptions()
      }
    })
    // Serial Send Events
    this.refs.serialSend.refs.btnSend.addEventListener('click', () => {
      let out = this.refs.serialSend.onSendButtonClicked()
      if (out != '' && this.connected) {
        this.txByteCount += out.length
        this.statusBar.updateTx(this.txByteCount)
        this.port.write(out)
      }
    })

    // Status Bar Events
    this.statusBar.callbacks.onResetRxCount = () => {
      this.rxByteCount = 0
      this.statusBar.updateRx(this.rxByteCount)
    }

    this.statusBar.callbacks.onResetTxCount = () => {
      this.txByteCount = 0
      this.statusBar.updateTx(this.txByteCount)
    }
  }

  render() {
    return (
      <div className='serial-monitor'>
        <MenuComponent ref='menu'/>
        <SerialReceivedComponent ref='serialReceived'
        config={pcfg.termsettings}/>
        <SerialSendComponent ref='serialSend' config={pcfg.sendsettings}
        subscriptions={this.subscriptions}/>
        <PortSettingsComponent ref='portSettings'
        config={pcfg.portsettings}
        active={this.portsettingsactive}
        connected={this.connected}
        portlist={this.portlist} />
      </div>
    )
  }

  update() {
    return etch.update(this)
  }

  // Tear down any state and detach
  async destroy() {
    console.log("SerialMonitorComponent destroyed")
    pcfg.writeConfig()
    this.active = false
    this.port.destroy()
    this.subscriptions.dispose()
    await etch.destroy(this)
  }

  getTitle() {
    return "Serial Monitor"
  }

  onServerConnected() {
    // active the connect button
    this.refs.menu.toggleConnect(true)
  }

  onServerError() {
    this.connected = false
    this.refs.menu.toggleConnect(false)
    this.refs.menu.toggleDisconnect(false)
    atom.notifications.addError("Error connecting to SocketIO server")
  }

  onPortListReceived(portlist) {
    delete this.portlist
    if (portlist === 'none') {
      this.portlist = []
    } else {
      this.portlist = portlist
    }

    etch.update(this)
  }

  onPortConnected(connected) {
    this.connected = connected
    if(this.connected) {
      atom.notifications.addSuccess("Successfully connected to " +
      pcfg.portsettings.port)
      this.refs.menu.toggleDisconnect(true)
    } else {
      atom.notifications.addError("Failed to connect to " +
      pcfg.portsettings.port)
      this.refs.menu.toggleConnect(true)
      this.refs.menu.toggleDisconnect(false)
    }
    this.statusBar.updateConnected(this.connected)
  }

  onPortDisconnected() {
    this.connected = false;
    atom.notifications.addInfo("Disconnected from " + pcfg.portsettings.port)
    this.refs.menu.toggleConnect(true);
    this.statusBar.updateConnected(this.connected)
  }

  onSerialReceived(data) {
    this.rxByteCount += data.length
    this.statusBar.updateRx(this.rxByteCount)
    this.refs.serialReceived.add(data)
  }

  copy() {
    let txt = this.refs.serialReceived.getCopyTextArea()
    atom.clipboard.write(txt)
  }

  // Returns an object that can be retrieved when package is activated
  serialize() {}

}
