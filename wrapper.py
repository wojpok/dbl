#!/usr/bin/env python3
import sys
import termios
import tty
import subprocess
import signal

original_attrs = termios.tcgetattr(sys.stdin)

def set_raw_mode():
    #tty.setraw(sys.stdin.fileno(), when=termios.TCSANOW)
    # termios.tcsetattr(sys.stdin, termios.TCSANOW, )
    attrs = termios.tcgetattr(sys.stdin.fileno())
    attrs[3] = attrs[3] & ~(termios.ICANON | termios.ECHO)  # lflag
    termios.tcsetattr(sys.stdin.fileno(), termios.TCSADRAIN, attrs)

def restore_terminal():
    termios.tcsetattr(sys.stdin, termios.TCSADRAIN, original_attrs)

def handle_exit(signum=None, frame=None):
    restore_terminal()
    sys.exit(1)

signal.signal(signal.SIGINT, handle_exit)
signal.signal(signal.SIGTERM, handle_exit)

try:
    set_raw_mode()
    subprocess.run(["dbl"] + sys.argv[1:])
finally:
    restore_terminal()
