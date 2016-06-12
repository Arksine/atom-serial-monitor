import os
import socketio
import eventlet
from eventlet import wsgi
import serial
from serial import threaded
from serial.tools import list_ports


class Streamer(threaded.Protocol):
    """
    Stream binary data from the serial port.  As the data is received, it is
    emitted over socket io
    """

    def __init__(self):
        self.transport = None
        self.sid = None

    def connection_made(self, transport):
        """Store transport"""
        self.transport = transport

    def connection_lost(self, exc):
        """Forget transport"""
        self.transport = None
        super(Streamer, self).connection_lost(exc)

    def data_received(self, data):
        sio.emit('serialreceived', data, self.sid)

    def set_sid(self, inSid):
        self.sid = inSid

sio = socketio.Server()
ser = serial.Serial()
serialThread = threaded.ReaderThread(ser, Streamer)


def set_data_bits(dbs):
    if dbs == 5:
        ser.bytesize = serial.FIVEBITS
    elif dbs == 6:
        ser.bytesize = serial.SIXBITS
    elif dbs == 7:
        ser.bytesize = serial.SEVENBITS
    elif dbs == 8:
        ser.bytesize = serial.EIGHTBITS
    return


def set_stop_bits(sbs):
    if sbs == '1':
        ser.stopbits = serial.STOPBITS_ONE
    elif sbs == '1.5':
        ser.stopbits = serial.STOPBITS_ONE_POINT_FIVE
    elif sbs == '2':
        ser.stopbits = serial.STOPBITS_TWO
    return


def set_parity(par):
    if par == 'none':
        ser.parity = serial.PARITY_NONE
    elif par == 'even':
        ser.parity = serial.PARITY_EVEN
    elif par == 'odd':
        ser.parity = serial.PARITY_ODD
    elif par == 'mark':
        ser.parity = serial.PARITY_MARK
    elif par == 'space':
        ser.parity = serial.PARITY_SPACE
    return


@sio.on('connect')
def connect(sid, environ):
    print('connect ', sid)


@sio.on('disconnect')
def disconnect(sid):
    print('disconnect ', sid)
    quit()


@sio.on('list_serial_ports')
def list_serial_ports(sid):
    print('port list requested', sid)
    portList = sorted(list_ports.comports())
    if len(portList) > 0:
        outList = []
        desc = ''
        for port in portList:
            if os.name == 'nt':  # win32
                desc = port.description
            elif os.name == 'posix':
                desc = '(' + port.name + ') ' + port.description
            else:
                desc = '(' + port.name + ')'

            outList.append(
                {'port': port.device, 'description': desc})
        sio.emit('port_list', outList, sid)
    else:
        sio.emit('port_list', 'none', sid)
    return


@sio.on('connect_serial')
def connect_serial(sid, data):
    ser.port = data['port']
    ser.baudrate = data['baud']
    ser.rts = data['rts']
    ser.dtr = data['dtr']
    set_data_bits(data['databits'])
    set_parity(data['parity'])
    set_stop_bits(data['stopbits'])
    ser.xonxoff = data['xonxoff']
    ser.rtscts = data['rtscts']
    ser.dsrdtr = data['dsrdtr']

    try:
        ser.open()
    except serial.SerialException:
        sio.emit('connected', 'false', sid)
        return

    if ser.is_open:
        serialThread.start()
        t, proto = serialThread.connect()
        proto.set_sid(sid)
        sio.emit('connected', 'true', sid)
    else:
        sio.emit('connected', 'false', sid)
    return


@sio.on('disconnect_serial')
def disconnect_serial(sid, data):
    serialThread.close()
    sio.emit('port_disconnected', room=sid)
    return


@sio.on('write_to_serial')
def write_to_serial(sid, data):
    serialThread.write(data)


@sio.on('update_serial_setting')
def update_serial_setting(sid, data):
    if data['setting'] == 'baud':
        ser.baudrate = data['value']
    elif data['setting'] == 'dtr':
        ser.dtr = data['value']
    elif data['setting'] == 'rts':
        ser.baudrate = data['value']
    return

if __name__ == '__main__':
    app = socketio.Middleware(sio)

    # deploy as an gevent WSGI server using websockets
    wsgi.server(eventlet.listen(('127.0.0.1', 8000)), app)