import websocket
from websocket import _exceptions
from datetime import datetime
from threading import Thread
import time
import traceback


def do_ws_recv(ws, name):
    while True:
        try:
            opcode, data = ws.recv_data()
            if opcode == websocket.ABNF.OPCODE_PING:
                print 'recv ping'
                ws.pong()
            elif opcode == websocket.ABNF.OPCODE_PONG:
                print 'recv pong'
                pass
            elif opcode == websocket.ABNF.OPCODE_CLOSE:
                print 'recv close'
                ws.close()
                break
            elif opcode == websocket.ABNF.OPCODE_TEXT:
                print "%s:%s" % (name, data)
            elif opcode == websocket.ABNF.OPCODE_BINARY:
                print 'recv binary:'
                print data
        except _exceptions.WebSocketTimeoutException as e:
            print "%s:recv timeout" % (name)
            ws.ping()
        except Exception as e:
            print traceback.print_exc()
            ws.close()
            break


def run(name, index):
    threadname = "%s-%d" % (name, index)
    print "start %s" % threadname
    ws = websocket.create_connection("ws://127.0.0.1:8080/ws")
    if ws is None:
        print "create connection error" % ws
    else:
        ws.settimeout(60)
        do_ws_recv(ws, threadname)


try:
    for i in range(10):
        Thread(target=run, args=("thread", i)).start()
except Exception as e:
    traceback.print_exc()

time.sleep(30)
