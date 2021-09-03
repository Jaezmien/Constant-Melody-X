import argparse
parser = argparse.ArgumentParser( description='Settings' )
parser.add_argument("--unknown", "-U", dest="unknown", action="store_true", help="scans all processes instead of only relying on the filename")
args = parser.parse_args()

import os.path
import configparser

config = configparser.ConfigParser()
if os.path.isfile('config.ini'):
    config.read('config.ini')
else:
    config['Blacklisted'] = {}
    config['Blacklisted']['Folders'] = ''
    config['Blacklisted']['Files'] = ''
    with open('config.ini','w+') as f:
        config.write(f)

blacklisted = {}
blacklisted['Folders'] = config['Blacklisted']['Folders'].split(',')
blacklisted['Files'] = config['Blacklisted']['Files'].split(',')

from pypresence import Presence
import datetime

epoch = datetime.datetime.utcfromtimestamp(0)
def unix_time_millis(dt):
	return (dt - epoch).total_seconds() * 1000.0

RPC = Presence( '445101504546734080' )
rpc_nitg_version = 'v4'
print('🚀  Connecting RPC...')
RPC.connect()
print('🚀  Connected!')

# Program ID
APP_ID = 1

# A connection to NotITG is made
def on_connect():
	global rpc_nitg_version
	write_to_notitg([0, 1])
	rpc_nitg_version = 'notitg-{0}'.format( 'v3' if (NotITG.GetDetails()[ 'Version' ] in ['V3','V3.1']) else 'v4' )
	RPC.update(large_image=rpc_nitg_version,large_text='NotITG {0}'.format(NotITG.GetDetails()[ 'Version' ]),details='Just connected')

# NotITG disconnects/exits
def on_disconnect(): pass
# Receiving a (partial) buffer
def on_read(buffer, setType): pass
# Receiving full buffers
def on_buffer_read(buffer): pass

# On successful buffer write
def on_write(buffer, setType):
	if buffer[0] == 0 and buffer[1] == 2:
		RPC.clear()
		RPC.close()
		exit( 0 )

rpc_song_name = None
rpc_folder_name = None
rpc_length = None
rpc_screen = None
def on_buffer_read(buffer):
	version = NotITG.GetDetails()[ 'Version' ]
	state = buffer.pop(0)

	if state == 1: # Which screen
		if buffer[0]==1:
			RPC.update(large_image=rpc_nitg_version,large_text='NotITG {0}'.format(version),state='In the title screen',start=unix_time_millis( datetime.datetime.utcnow() ))
		elif buffer[0]==2:
			RPC.update(large_image=rpc_nitg_version,large_text='NotITG {0}'.format(version),state='Selecting a song...',start=unix_time_millis( datetime.datetime.utcnow() ))
		elif buffer[0]==3:
			pass # Gameplay
		elif buffer[0]==4:
			RPC.update(large_image=rpc_nitg_version,large_text='NotITG {0}'.format(version),details='Finished a song')
		elif buffer[0]==5:
			RPC.update(large_image=rpc_nitg_version,large_text='NotITG {0}'.format(version),details='Taking a break...',start=unix_time_millis( datetime.datetime.utcnow() ))
		elif buffer[0]==6:
			RPC.update(large_image=rpc_nitg_version,large_text='NotITG {0}'.format(version),details='Editing a song...',start=unix_time_millis( datetime.datetime.utcnow() ))

	elif state == 2: # Gameplay info
		global rpc_song_name
		global rpc_folder_name
		global rpc_length

		ind = buffer.pop(0)
		if ind==1:
			rpc_song_name = ( decode_buffer(buffer) ) # Song Name
		elif ind==2:
			rpc_folder_name = ( decode_buffer(buffer) ) # Folder Name
		elif ind==3:
			rpc_length = buffer[0] # Song Length (Seconds)
		elif ind==4:
			rpc_start = datetime.datetime.utcnow()
			rpc_end = rpc_start + datetime.timedelta(seconds = rpc_length)
			RPC.update(
				large_image=rpc_nitg_version,
				large_text='NotITG {0}'.format(version),
				details='Playing a song',
				state=(None) if (rpc_song_name in blacklisted['Files']) or (rpc_folder_name in blacklisted['Folders']) else rpc_song_name,
				start=unix_time_millis(rpc_start),
				end=unix_time_millis(rpc_end)
			)
			rpc_song_name = None
			rpc_folder_name = None
			rpc_length = None

# Program is exiting
def on_exit(sig, frame):
	global _external_initialized
	if _external_initialized:
		write_to_notitg([0, 2])
		return
	RPC.clear()
	RPC.close()
	exit( 0 )


"""
------------------------------------------------------------------------
--------------------------DON'T TOUCH IT KIDDO--------------------------
------------------------------------------------------------------------
"""


#region Helpers
_ENCODE_GUIDE = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 \n'\"~!@#$%^&*()<>/-=_+[]:;.,`{}"
def encode_string(str):
	return list(map( lambda x: _ENCODE_GUIDE.find(x)+1, [x for x in str] ))
def decode_buffer(buff):
	return "".join( list(map( lambda x: _ENCODE_GUIDE[x-1], buff )) )

def chunks(lst, n):
	for i in range(0, len(lst), n): yield lst[i:i + n]
def write_to_notitg(buffer):
	global _notitg_write_buffer

	if len( buffer ) <= 26:
		_notitg_write_buffer.append({ "buffer": buffer, "set": 0, })
	else:
		buffer_chunks = list( chunks(buffer, 26) )
		for i in range(len(buffer_chunks)):
			_notitg_write_buffer.append({ "buffer": buffer_chunks[i], "set": 2 if len(buffer_chunks) == (i+1) else 1 })
#endregion

#region NotITG Handling
import notitg
import time
import signal
NotITG = notitg.NotITG()

_notitg_read_buffer = []
_notitg_write_buffer = []

_heartbeat_status = 0
_external_initialized = False
_initialize_warning = False
def tick_notitg():
	global _initialize_warning
	global _external_initialized

	if not NotITG.Heartbeat():
		global _heartbeat_status

		if NotITG.Scan( args.unknown ):
			if NotITG.GetDetails()[ "Version" ] in ["V1", "V2"]:
				print("⚠ Unsupported NotITG version! Expected V3 or higher, got " + NotITG.GetDetails()[ "Version" ])
				NotITG.Disconnect()
				return
			_heartbeat_status = 2
			_details = NotITG.GetDetails()
			print("> -------------------------------")
			print("✔️  Found NotITG!")
			print(">> Version: " + _details[ "Version" ] )
			print(">> Build Date: " + str(_details[ "BuildDate" ]) )
			print("> -------------------------------")
		elif _heartbeat_status == 0:
			_heartbeat_status = 1
			print("❌ Could not find a version of NotITG!")
		elif _heartbeat_status == 2:
			_heartbeat_status = 0
			_external_initialized = False
			_initialize_warning = False
			print("❓ NotITG has exited")
			on_disconnect()

	else:
		if NotITG.GetExternal(60) == 0:
			if not _initialize_warning:
				_initialize_warning = True
				print( "⏳ NotITG is initializing..." )
			return
		elif not _external_initialized:
			print( "🏁 NotITG has initialized!" )
			on_connect()
			_external_initialized = True

		global _notitg_write_buffer
		global _notitg_read_buffer

		if NotITG.GetExternal(57) == 1 and NotITG.GetExternal( 59 ) == APP_ID:
			read_buffer = []

			for index in range( 28, 28 + NotITG.GetExternal(54) ):
				read_buffer.append( NotITG.GetExternal(index) )
				NotITG.SetExternal( index, 0 )

			SET_STATUS = NotITG.GetExternal(55)
			on_read( read_buffer, SET_STATUS )
			if SET_STATUS == 0: on_buffer_read( read_buffer )
			else:
				_notitg_read_buffer.extend( read_buffer )
				if SET_STATUS == 2:
					on_buffer_read( _notitg_read_buffer )
					_notitg_read_buffer.clear()

			NotITG.SetExternal( 54, 0 )
			NotITG.SetExternal( 55, 0 )
			NotITG.SetExternal( 59, 0 )
			NotITG.SetExternal( 57, 0 )

		if len( _notitg_write_buffer ) > 0 and NotITG.GetExternal( 56 ) == 0:
			NotITG.SetExternal( 56, 1 )
			write_buffer = _notitg_write_buffer.pop( 0 )

			for index, value in enumerate( write_buffer["buffer"] ): NotITG.SetExternal( index, value )
			NotITG.SetExternal( 26, len(write_buffer["buffer"]) )
			NotITG.SetExternal( 27, write_buffer["set"] )
			NotITG.SetExternal( 56, 2 )
			NotITG.SetExternal( 58, APP_ID )
			on_write( write_buffer["buffer"], write_buffer["set"] )

signal.signal(signal.SIGINT, on_exit)

while True:
	tick_notitg()
	time.sleep( 0.1 )
#endregion