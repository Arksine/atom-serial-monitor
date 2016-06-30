/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
var calculateSize = require('calculate-size')

import TerminalSettingsComponent from './terminal-settings-component'

class HeadMarker {
  constructor(properties) {
    this.itemstyle = properties.itemstyle
    this.lineWidth = properties.lineWidth
    this.winWidth = properties.winWidth

    this.calcBlockSizes();
    etch.initialize(this)
  }

  calcBlockSizes() {
    //TODO: get the fontsize from configuration
    let options = {
      font: 'Consolas',
      fontSize: '14px'
    }

    this.blockSize = {asc: 0, hex: 0, dec: 0, bin: 0}
    this.blockSize.asc = calculateSize('0', options).width
    this.blockSize.hex = calculateSize('0000', options).width
    this.blockSize.dec = calculateSize('00000', options).width
    this.blockSize.bin = calculateSize('0000000000', options).width
  }


  render() {
    var markerlist = []
    var blocks = 0
    var blockcount = 0

    switch (this.itemstyle) {
      case 'asc-spacing':
        blocks = this.winWidth / this.blockSize.asc + 1
        blockcount = (this.lineWidth < blocks) ? blocks : (this.lineWidth + 1)
        var marker = ''
        for (var i = 1; i <= blockcount; i += 8) {
          marker += (i.toString() + "       ").slice(0, 8)
        }
        markerlist.push(<pre className={this.itemstyle}>{marker}</pre>)

        return (
          <div className='head-marker'>
            {markerlist}
          </div>
        )
      case 'hex-spacing':
        blocks = this.winWidth / this.blockSize.hex + 1
        break
      case 'dec-spacing':
        blocks = this.winWidth / this.blockSize.dec + 1
        break
      case 'bin-spacing':
        blocks = this.winWidth / this.blockSize.bin + 1
        break
      default:
        console.log('Error, unknown item style')
    }
    blockcount = (this.lineWidth < blocks) ? blocks : this.lineWidth
    for (var i = 1; i <= blockcount; i++) {
      markerlist.push(<span className={this.itemstyle}>{i}</span>)
    }

    //apend an empty block to make sure the elements line up when scrolling the
    //x-axis
    markerlist.push(<span className={this.itemstyle}>&nbsp;</span>)

    return (
      <div className='head-marker'>
        {markerlist}
      </div>
    )
  }

  update(properties) {
    this.itemstyle = properties.itemstyle
    this.lineWidth = properties.lineWidth
    this.winWidth = properties.winWidth
    return etch.update(this)
  }

  async destroy() {
    await etch.destroy(this)
  }
}

export default class SerialReceivedComponent {

  constructor(properties) {
    this.props = properties

    if (this.props.config.binEnabled) {
      this.itemstyle = 'bin-spacing'
    } else if (this.props.config.decEnabled) {
      this.itemstyle = 'dec-spacing'
    } else if (this.props.config.hexEnabled) {
      this.itemstyle = 'hex-spacing'
    } else {
      this.itemstyle = 'asc-spacing'
    }

    // before rendering this is the best estimation I can get.  After rendering
    // I can use element.clientWidth
    this.winWidth = window.innerWidth;
    this.lineWidth = 0;
    this.lastline = undefined
    this.lineindex = 0

    this.lines = []
    let newline = {chars: []}
    this.lines.push(newline)

    etch.initialize(this)

    // SerialWin Events
    this.refs.serialWin.addEventListener('scroll', () => {
      this.refs.headmarker.element.scrollLeft = this.refs.serialWin.scrollLeft
    })

    window.addEventListener('resize', () => {
      var that = this
      if ( !that.resizeTimeout ) {
        that.resizeTimeout = setTimeout( function() {
          that.resizeTimeout = null;
          //TODO: change to offsetwidth?
          that.winWidth = that.element.clientWidth
          that.refs.headmarker.update({
            itemstyle: that.itemstyle,
            winWidth: that.winWidth,
            lineWidth:that.lineWidth
          })
         // The actualResizeHandler will execute at a rate of 10fps
       }, 100);
      }
    })

    // Terminal Settings Events
    this.refs.termSettings.refs.btnAscii.addEventListener('click', () => {
      this.refs.termSettings.toggleAsciiButton()
      this.update(this.props)
    })

    this.refs.termSettings.refs.btnHex.addEventListener('click', () => {
      this.refs.termSettings.toggleHexButton()
      this.update(this.props)
    })

    this.refs.termSettings.refs.btnDec.addEventListener('click', () => {
      this.refs.termSettings.toggleDecButton()
      this.update(this.props)
    })

    this.refs.termSettings.refs.btnBin.addEventListener('click', () => {
      this.refs.termSettings.toggleBinButton()
      this.update(this.props)
    })

    this.refs.termSettings.refs.btnClear.addEventListener('click', () => {
      this.clearData()
    })

    this.refs.termSettings.refs.cbxAutoScroll.addEventListener('change',
    (event) => {
      this.props.config.autoScroll = event.target.checked
    })

  }

  render() {
    return (
      <div className='content-area'>
        <TerminalSettingsComponent ref='termSettings'
        config={this.props.config}/>
        <HeadMarker ref='headmarker' itemstyle={this.itemstyle}
        winWidth={this.winWidth} lineWidth={this.lineWidth}/>
        <div ref='serialWin' className='serialreceived '>
          {this.renderLines()}
        </div>
      </div>
    )
  }

  renderLines() {
    return(
      this.lines.map( (line, index) =>
        <div>
          {this.renderBinLine(line.chars)}
          {this.renderDecLine(line.chars)}
          {this.renderHexLine(line.chars)}
          {this.renderAsciiLine(line.chars)}
        </div>
      )
    )
  }


  renderHexLine(linein) {
    if (this.props.config.hexEnabled) {
      return (
        <div className={'flex-line '  + this.itemstyle}>
          {this.renderHexBlocks(linein)}
        </div>
      )
    }
  }

  renderHexBlocks(linein) {
    return (
      linein.map( (item) =>
        <span className='hex'>{this.bytetoHex(item)}</span>
      )
    )
  }

  renderDecLine(linein) {
    if (this.props.config.decEnabled) {
      return (
        <div className={'flex-line '  + this.itemstyle}>
          {this.renderDecBlocks(linein)}
        </div>
      )
    }
  }

  renderDecBlocks(linein) {
    return (
      linein.map( (item) =>
        <span className='dec'>{this.bytetoDec(item)}</span>
      )
    )
  }

  renderBinLine(linein) {
    if (this.props.config.binEnabled) {
      return (
        <div className={'flex-line '  + this.itemstyle}>
          {this.renderBinBlocks(linein)}
        </div>
      )
    }
  }

  renderBinBlocks(linein) {
    return (
      linein.map( (item) =>
        <span className='bin'>{this.bytetoBin(item)}</span>
      )
    )
  }

  renderAsciiLine(linein) {
    if (this.props.config.asciiEnabled) {
      var line = linein.join('')
      line = line.replace(/\r/g, '\u1E5F')
      line = line.replace(/\n/g, '\u1E49')
      line = line.replace(/\t/g, '\u1E6F')

      // separate the lastchar from the rest of the string so the line-spacing
      // css property doesn't extend the element
      var first = line.slice(0, -1)
      var lastchar = line.slice(-1)

      return(
        <div className={'ascii ' + this.itemstyle}>
          <span>{first}</span>{lastchar}
        </div>
      )
    }
  }

  update(properties) {
    this.props = properties
    this.winWidth = this.element.clientWidth
    if (this.props.config.binEnabled) {
      this.itemstyle = 'bin-spacing'
    } else if (this.props.config.decEnabled) {
      this.itemstyle = 'dec-spacing'
    } else if (this.props.config.hexEnabled) {
      this.itemstyle = 'hex-spacing'
    } else {
      this.itemstyle = 'asc-spacing'
    }

    return etch.update(this)
  }

  // Tear down any state and detach
  async destroy() {
    this.clearData()
    await etch.destroy(this)
  }

  clearData() {
    delete this.lines
    this.lines = []
    let newline = {chars: []}
    this.lines.push(newline)
    this.lineindex = 0
    this.lineWidth = 0

    etch.update(this)
  }

  /**
   * Parses data and adds it to the text editor
   * @param {[string]} data [data received over serial]
   */
  add(data) {
    for (var index in data) {

      this.lines[this.lineindex].chars.push(data[index])

      if (this.lines[this.lineindex].chars.length > this.lineWidth) {
        this.lineWidth++
      }

      if (data[index] === '\r') {
        //TODO: Placeholder in case we want an option to create a newline here
      } else if (data[index] === '\n') {

        //TODO: may want more options than just a newline on \n
        let newline = {chars: []}
        this.lines.push(newline)
        this.lineindex++
      }

    }

    etch.update(this)
  }

  bytetoHex(byte) {
    let hexstr = '0' + (byte.charCodeAt(0) & 0xFF).toString(16)
    return hexstr.slice( - 2)
  }

  bytetoDec(byte) {
    return (byte.charCodeAt(0) & 0xFF
    )
  }

  bytetoBin(byte) {
    var decimal = this.bytetoDec(byte)
    var binStr = ''
    for (var i = 0; i < 8; i++) {
      binStr = ((decimal & (1 << i)) ? '1' :  '0') + binStr
    }
    return binStr
  }

  getCopyTextArea() {
    var text = "";
    if (window.getSelection) {
        text = window.getSelection().toString();
    } else if (document.selection && document.selection.type != "Control") {
        text = document.selection.createRange().text;
    }
    return text;
  }

  writeAfterUpdate() {
    if (this.props.config.autoScroll) {
      this.refs.serialWin.scrollTop = this.refs.serialWin.scrollHeight
    }
  }

  /*readAfterUpdate() {

    // Autoscroll to the right (doesn't work well)
    // get the last element
    if (this.props.config.hexEnabled) {
      this.lastline = this.element.querySelector(".lastline .hex")
    } else if (this.props.config.asciiEnabled){
      this.lastline = this.element.querySelector(".lastline .ascii")
    } else {
      this.lastline = undefined
    }
  }*/
}
