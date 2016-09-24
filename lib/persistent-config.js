/** @babel */
var db = require('diskdb')
var path = require('path')

class Configuration {
  constructor() {
    this.title = 'config'
    this.sioport = 8000
    this.portsettings = {
      port: '0',
      baud: 9600,
      databits: 8,
      stopbits: 1,
      parity: 'none',
      xonxoff: false,
      rtscts: false,
      dsrdtr: false,
      dtr: true,
      rts: true }
    this.termsettings = {
      asciiEnabled: true,
      decEnabled: false,
      binEnabled: false,
      autoScroll: false,
      showInvisibles: false}
    this.sendsettings = {
      sendType: 'ascii',
      endLine: 'None'}

    this.readConfig()
  }

  readConfig() {
    let configpath = path.join(__dirname, '../resources')
    db.connect(configpath, ['serialmonitorconfig'])
    var initcfg = db.serialmonitorconfig.findOne()
    if (initcfg === undefined) {
      initcfg = db.serialmonitorconfig.save(this)
    } else {
      Object.assign(this, initcfg)
    }
  }

  writeConfig() {
    let updatecfg = db.serialmonitorconfig.findOne()
    db.serialmonitorconfig.update(updatecfg, this)
  }
}

export var pcfg = new Configuration()
