/** @babel */
import ConnectedStatusComponent from './status-bar/connected-status-component'
import PortOptionsComponent from './status-bar/port-options-component'
import RxTxComponent from './status-bar/rx-tx-component'
import {pcfg} from './persistent-config'

export default class StatusBarManager {
  constructor() {
    this.connected = false
    this.connectedStatusComponent = new ConnectedStatusComponent({
    connected: this.connected,
    port: pcfg.portsettings.port
    })

    this.portOptionsComponent = new PortOptionsComponent({
      baud: pcfg.portsettings.baud,
      databits: pcfg.portsettings.databits,
      parity: pcfg.portsettings.parity,
      stopbits: pcfg.portsettings.stopbits,
      xonxoff: pcfg.portsettings.xonxoff,
      rtscts: pcfg.portsettings.rtscts,
      dsrdtr: pcfg.portsettings.dsrdtr
    })

    this.rxComponent = new RxTxComponent('Rx')
    this.txComponent = new RxTxComponent('Tx')

    this.callbacks = {
      onResetRxCount: undefined,
      onResetTxCount: undefined
    }

    this.rxComponent.element.addEventListener('click', () => {
      this.callbacks.onResetRxCount()
    })

    this.txComponent.element.addEventListener('click', () => {
      this.callbacks.onResetTxCount()
    })
  }

  createTiles(statusBar) {
    this.connectedTile = statusBar.addRightTile(
      {item: this.connectedStatusComponent,
      priority: 80})

    this.optionsTile = statusBar.addRightTile(
      {item: this.portOptionsComponent,
      priority: 70})

    this.rxTile = statusBar.addRightTile(
      {item: this.rxComponent,
      priority: 60})

    this.txTile = statusBar.addRightTile(
      {item: this.txComponent,
      priority: 50})
  }

  destroy() {
    this.connectedStatusComponent.destroy()
    this.portOptionsComponent.destroy()
    this.rxComponent.destroy()
    this.txComponent.destroy()

    if (this.connectedTile) {
      this.connectedTile.destroy()
    }

    if (this.optionsTile) {
      this.optionsTile.destroy()
    }

    if (this.rxTile) {
      this.rxTile.destroy()
    }

    if (this.txTile) {
      this.txTile.destroy()
    }
  }

  updateConnected(connected) {
    this.connected = connected
    this.connectedStatusComponent.update({
      connected: this.connected,
      port: pcfg.portsettings.port
      })
  }

  updateOptions() {
    this.connectedStatusComponent.update({
      connected: this.connected,
      port: pcfg.portsettings.port
      })

    this.portOptionsComponent.update({
      baud: pcfg.portsettings.baud,
      databits: pcfg.portsettings.databits,
      parity: pcfg.portsettings.parity,
      stopbits: pcfg.portsettings.stopbits,
      xonxoff: pcfg.portsettings.xonxoff,
      rtscts: pcfg.portsettings.rtscts,
      dsrdtr: pcfg.portsettings.dsrdtr
    })
  }

  updateRx(count) {
    this.rxComponent.update(count)
  }

  updateTx(count) {
    this.txComponent.update(count)
  }

  show() {
    this.connectedStatusComponent.show()
    this.portOptionsComponent.show()
    this.rxComponent.show()
    this.txComponent.show()
  }

  hide() {
    this.connectedStatusComponent.hide()
    this.portOptionsComponent.hide()
    this.rxComponent.hide()
    this.txComponent.hide()
  }

 }
