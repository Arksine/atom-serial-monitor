/** @babel */
/** @jsx etch.dom */

import etch from 'etch'

var hexStringToBin = (data) => {
  var invalidHex = new RegExp(/[^A-Fa-f0-9]/)
  var hexStart = new RegExp('0x', 'g')

  data = data.replace(/\s/g, "")
  data = data.replace(hexStart, "")
  data = data.replace(/\$/g, "")

  if (((data.length % 2) != 0) || invalidHex.test(data)) {
    atom.notifications.addError("Invalid Hex String")
    return ''
  }

  var result = []
  while (data.length >= 2) {
    result.push(parseInt(data.substring(0, 2), 16) & 0xFF)
    data = data.substring(2, data.length)
  }

  return result
}

export default class SerialSendComponent {

  constructor(properties) {
    this.props = properties
    this.editorattrs = {mini: true, 'placeholder-text': 'Enter Ascii text or Hex...'}
    etch.initialize(this)

    // get the atom-text-editor model
    this.txtModel = this.refs.txtSend.getModel()

    // register event listener to store value of changed properties
    this.element.addEventListener('change', (event) => {
      if (event.target === this.refs.selSendType) {
        this.props.config.sendType = event.target.value
      } else if (event.target == this.refs.selEndLine) {
        this.props.config.endLine = event.target.value
      }
    })

    // register event to select text when text editor has focus
    this.refs.txtSend.addEventListener('focus', () => {
      this.txtModel.selectAll()
    })
  }

  render() {
    return (
      <div className='serialsend'>
        <div className='control-row'>
          <button ref='btnSend' id='sendbutton' className='btn'>
            Send
          </button>
          <select ref='selSendType' id='sendtype' className='form-control'>
            <option value='ascii'
            selected={this.props.config.sendType === 'ascii'}>
              Ascii</option>
            <option value='hex'
            selected={this.props.config.sendType === 'hex'}>
              Hex</option>
          </select>
          <atom-text-editor ref='txtSend' attributes={this.editorattrs}/>
          <select ref='selEndLine' id='endline'className='form-control'>
            <option value='None'
            selected={this.props.config.endLine === 'None'}>
              No Line Ending</option>
            <option value='CRLF'
            selected={this.props.config.endLine === 'CRLF'}>
              CRLF</option>
            <option value='LF'
            selected={this.props.config.endLine === 'LF'}>
              LF</option>
            <option value='CR'
            selected={this.props.config.endLine === 'CR'}>
              CR</option>
            <option value='TAB'
            selected={this.props.config.endLine === 'TAB'}>
              TAB</option>
        </select>
        </div>
      </div>
    )
  }

  update(properties) {
    return etch.update(this)
  }

  // Tear down any state and detach
  async destroy() {
    this.clearText()
    await etch.destroy(this)
  }

  onSendButtonClicked() {
    var text = this.txtModel.getText()

    if (this.refs.selSendType.value === 'ascii') {
      switch (this.refs.selEndLine.value) {
        case 'CRLF':
          text += '\r' + '\n'
          break
        case 'LF':
          text += '\n'
          break
        case 'CR':
          text += '\r'
          break
        case 'TAB':
          text += '\t'
          break
      }
      return text;
    } else {    // hex
      var converted = hexStringToBin(text)
      if (converted != '') {
        switch (this.refs.selEndLine.value) {
          case 'CRLF':
            converted.push(0x0d)
            converted.push(0x0a)
            break
          case 'LF':
            converted.push(0x0a)
            break
          case 'CR':
            converted.push(0x0d)
            break
          case 'TAB':
            converted.push(0x09)

        }

        if (converted.length > 0) {
          let buf = new Buffer(converted)
          return buf;
        } else {
          // nothing to send
          return ''
        }

      } else {
        // invalid hex string
        return ''
      }
    }
  }

  clearText() {
    this.txtModel.setText('')
  }
}
