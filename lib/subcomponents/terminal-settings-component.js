/** @babel */
/** @jsx etch.dom */

import etch from 'etch'

export default class TerminalSettingsComponent {

  constructor(properties) {
    this.props = properties
    this.asciiStatus = this.props.config.asciiEnabled ? 'selected' : ''
    this.hexStatus = this.props.config.hexEnabled ? 'selected' : ''
    this.decStatus = this.props.config.decEnabled ? 'selected' : ''
    this.binStatus = this.props.config.binEnabled ? 'selected' : ''

    etch.initialize(this)
  }

  render() {
    return (
      <div className='terminalsettings'>
        <div className='btn-group'>
          <button ref='btnAscii' id='asc' className={'btn ' + this.asciiStatus}>
            Asc
          </button>
          <button ref='btnHex' id='hex' className={'btn '+  this.hexStatus}>
            Hex
          </button>
          <button ref='btnDec' id='dec' className={'btn '+  this.decStatus}>
            Dec
          </button>
          <button ref='btnBin' id='bin' className={'btn '+  this.binStatus}>
            Bin
          </button>
        </div>
        <button ref='btnClear' className='btn clear'>
          Clear
        </button>
        <div className='checkbox'>
          <input ref='cbxAutoScroll' id='autoscroll' type='checkbox'
          checked={this.props.config.autoScroll}/>
          <div className='setting-title'>Auto-scroll</div>
        </div>
      </div>
    )
  }

  update(properties) {
    this.props  = properties
    this.asciiStatus = this.props.config.asciiEnabled ? 'selected' : ''
    this.hexStatus = this.props.config.hexEnabled ? 'selected' : ''
    this.decStatus = this.props.config.decEnabled ? 'selected' : ''
    this.binStatus = this.props.config.binEnabled ? 'selected' : ''
    return etch.update(this)
  }

  toggleAsciiButton() {
    this.props.config.asciiEnabled = !this.props.config.asciiEnabled
    this.asciiStatus = this.props.config.asciiEnabled ? 'selected' : ''
    return etch.update(this)
  }

  toggleHexButton() {
    this.props.config.hexEnabled = !this.props.config.hexEnabled
    this.hexStatus = this.props.config.hexEnabled ? 'selected' : ''
    return etch.update(this)
  }

  toggleDecButton() {
    this.props.config.decEnabled = !this.props.config.decEnabled
    this.decStatus = this.props.config.decEnabled ? 'selected' : ''
    return etch.update(this)
  }

  toggleBinButton() {
    this.props.config.binEnabled = !this.props.config.binEnabled
    this.binStatus = this.props.config.binEnabled ? 'selected' : ''
    return etch.update(this)
  }

  // Tear down any state and detach
  async destroy() {

    await etch.destroy(this)
  }
}
