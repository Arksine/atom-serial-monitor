/** @babel */
/** @jsx etch.dom */

import etch from 'etch'

export default class PortSettingsComponent {

  constructor(properties) {
    this.initialize(properties)
    etch.initialize(this)
  }

  initialize(properties) {
    this.props = properties

    if (this.props.active) {
      this.active = 'active'
    } else {
      this.active = ''
    }

    if (this.props.connected) {
      this.textDisabled = 'text-disabled'
      this.controlDisabled = true;
    } else {
      this.textDisabled = ''
      this.controlDisabled = false;
    }

  }

  render() {
    return (
      <div className={'portsettings ' + this.active}>
        <div className='heading'>
          <i ref='iconCancel' className='icon icon-x clickable'/>
          <strong>Serial Port Settings</strong>
        </div>
        <div className='body'>
          <div className='flex-ports'>
            <div className='dialog-control'>
              <label className={'setting-title ' + this.textDisabled}>
                Serial Port:
              </label>
              <select ref='selPorts' className='form-control'
              disabled={this.controlDisabled}>
                {this.renderPortList()}
              </select>
            </div>
            <button ref='btnRefreshPorts'className='btn'
            disabled={this.controlDisabled}>
              Refresh
            </button>
          </div>
          <div className='flex-row'>
            <div className='dialog-control'>
              <label className='setting-title'>
                Baud:
              </label>
              <select ref='selBaud' className='form-control'>
                {this.renderBaudList()}
              </select>
            </div>
            <div className='dialog-control'>
              <label className={'setting-title ' + this.textDisabled}>
                Data Bits:
              </label>
              <select ref='selDataBits' className='form-control'
              disabled={this.controlDisabled}>
                <option value='8'
                selected={this.props.config.databits.toString() === '8'}>
                  8</option>
                <option value='7'
                selected={this.props.config.databits.toString() === '7'}>
                  7</option>
                <option value='6'
                selected={this.props.config.databits.toString() === '6'}>
                  6</option>
                <option value='5'
                selected={this.props.config.databits.toString() === '5'}>
                  5</option>
              </select>
            </div>
            <div className='dialog-control'>
              <label className={'setting-title ' + this.textDisabled}>
                Stop Bits:
              </label>
              <select ref='selStopBits' className='form-control'
              disabled={this.controlDisabled}>
                <option value='1'
                selected={this.props.config.stopbits === '1'}>
                  1</option>
                <option value='1.5'
                selected={this.props.config.stopbits === '1.5'}>
                  1.5</option>
                <option value='2'
                selected={this.props.config.stopbits === '2'}>
                  2</option>
              </select>
            </div>
            <div className='dialog-control'>
              <label className={'setting-title ' + this.textDisabled}>
                Parity:
              </label>
              <select ref='selParity' className='form-control'
              disabled={this.controlDisabled}>
                <option value='none'
                selected={this.props.config.parity === 'none'}>
                  None</option>
                <option value='even'
                selected={this.props.config.parity === 'even'}>
                  Even</option>
                <option value='odd'
                selected={this.props.config.parity === 'odd'}>
                  Odd</option>
                <option value='mark'
                selected={this.props.config.parity === 'mark'}>
                  Mark</option>
                <option value='space'
                selected={this.props.config.parity === 'space'}>
                  Space</option>
              </select>
            </div>
            <div className='dialog-control'>
              <label className={'setting-title ' + this.textDisabled}>
                Flow Control:
              </label>
              <select ref='selFlow' className='form-control'
              disabled={this.controlDisabled}>
                <option value='none'>None</option>
                <option value='xonxoff' selected={this.props.config.xonxoff}>
                  Xon/Xoff</option>
                <option value='rtscts' selected={this.props.config.rtscts}>
                  RTS/CTS</option>
                <option value='dsrdtr' selected={this.props.config.dsrdtr}>
                  DSR/DTR</option>
              </select>
            </div>
          </div>
          <div className='block'>
            <label className='setting-title'>Port Flags:</label>
            <div className='checkbox'>
              <label htmlFor='rts'>
                <input ref='cbxRts' id='rts' type='checkbox'
                checked={this.props.config.rts}/>
                <div className='setting-title'>RTS Line</div>
              </label>
            </div>
            <div className='checkbox'>
              <label htmlFor='dtr'>
                <input ref='cbxDtr' id='dtr' type='checkbox'
                checked={this.props.config.dtr}/>
                <div className='setting-title'>DTR Line</div>
              </label>
            </div>
          </div>
        </div>
        <div className='buttons'>
          <button ref='btnApply' className='bottom-button'>
            <i className='icon icon-check'/>
            <span>Apply</span>
          </button>
          <button ref='btnCancel' className='bottom-button'>
            <i className='icon icon-x'/>
            <span>Cancel</span>
          </button>
        </div>
      </div>
    )
  }

  update(properties) {
    this.initialize(properties)
    return etch.update(this)
  }

  // Tear down any state and detach
  async destroy() {
    await etch.destroy(this)
  }

  renderPortList() {
    if (this.props.portlist.length > 0 ){
      return (
        this.props.portlist.map( (item) =>
        <option value={item.port}
        selected={item.port === this.props.config.port}>
          {item.description}</option>
      ))
    } else {
      return (
        <option value='0'>No Ports Detected</option>
      )
    }
  }

  renderBaudList() {
    var baudrates = ['50', '75', '110', '134', '150', '200', '300', '600',
    '1200', '1800', '2400', '4800', '9600', '19200', '38400', '57600', '115200',
    '230400', '460800', '500000', '576000', '921600']
    return (
      baudrates.map( (item) =>
        <option value={item}
        selected={item === this.props.config.baud.toString()}>
          {item}</option>
      )
    )
  }

  checkPortList() {

    // first make sure we actually have a list of ports to work with
    if (this.props.portlist.length > 0)
    {
      // Check to see if our currently configured port exists in the
      // portlist property
      var exists = false;
      for (var i = 0; i < this.props.portlist.length; i++) {
        if (this.props.portlist[i].port === this.props.config.port) {
          exists = true;
          break;
        }
      }

      return exists;
    } else {
      return false;
    }
  }

  apply () {
    var cfg = this.props.config
    cfg.port = this.refs.selPorts.value
    cfg.baud = parseInt(this.refs.selBaud.value)
    cfg.databits = parseInt(this.refs.selDataBits.value)
    cfg.stopbits = this.refs.selStopBits.value
    cfg.parity = this.refs.selParity.value
    cfg.dtr = this.refs.cbxDtr.checked
    cfg.rts = this.refs.cbxRts.checked

    switch (this.refs.selFlow.value) {
      case 'none':
        cfg.xonxoff = false
        cfg.rtscts = false
        cfg.dsrdtr = false
        break
      case 'xonxoff':
        cfg.xonxoff = true
        cfg.rtscts = false
        cfg.dsrdtr = false
        break
      case 'rtscts':
        cfg.xonxoff = false
        cfg.rtscts = true
        cfg.dsrdtr = false
        break
      case 'dsrdtr':
        cfg.xonxoff = false
        cfg.rtscts = false
        cfg.dsrdtr = true
        break
      default:
        cfg.xonxoff = false
        cfg.rtscts = false
        cfg.dsrdtr = false
    }
    this.deactivate()
  }

  cancel () {
    this.deactivate()
  }

  activate() {
    this.props.active = true
    this.active = 'active'
    return etch.update(this)
  }

  deactivate() {
    this.props.active = false
    this.active = ''
    return etch.update(this)
  }
}
