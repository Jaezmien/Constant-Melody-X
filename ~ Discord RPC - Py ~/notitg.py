# NotITG External Reader & Writer for Python 3

# Imports + Globals
import platform
_IS_WINDOWS = platform.system().lower() == "windows";

import ctypes as ct
if _IS_WINDOWS: import ctypes.wintypes as wt
import psutil as ps
import errno

_NOTITG_VERSIONS = {
	"V1": {
		"BuildAddress": 0x006AED20,
		"Address": 0x00896950,
		"BuildDate": 20161224,
		"Size": 10
	},
	"V2": {
		"BuildAddress": 0x006B7D40,
		"Address": 0x008A0880,
		"BuildDate": 20170405,
		"Size": 10
	},
	"V3": {
		"BuildAddress": 0x006DFD60,
		"Address": 0x008CC9D8,
		"BuildDate": 20180617,
		"Size": 64
	},
	"V3.1": {
		"BuildAddress": 0x006E7D60,
		"Address": 0x008BE0F8,
		"BuildDate": 20180827,
		"Size": 64
	},
	"V4": {
		"BuildAddress": 0x006E0E60,
		"Address": 0x008BA388,
		"BuildDate": 20200112,
		"Size": 64
	},
	"V4.0.1": {
		"BuildAddress": 0x006C5E40,
		"Address": 0x00897D10,
		"BuildDate": 20200126,
		"Size": 64
	},
	"V4.2": {
		"BuildAddress": 0x006FAD40,
		"Address": 0x008BFF38,
		"BuildDate": 20210420,
		"Size": 256
	}
}
_NOTITG_FILENAMES = {
	"V1"    : "NotITG.exe",
	"V2"    : "NotITG-170405.exe",
	"V3"    : "NotITG-V3.exe",
	"V3.1"  : "NotITG-V3.1.exe",
	"V4"    : "NotITG-V4.exe",
	"V4.0.1": "NotITG-V4.0.1.exe",
	"V4.2"  : "NotITG-V4.2.0.exe",
}

class NotITGError(Exception):
	def __init__(self, message): self.message = message

# Exposed class

class NotITG:
	def __init__( self ):
		self._handler = _NotITGWindowsHandler() if _IS_WINDOWS else _NotITGLinuxHandler()

	def IsWindows( self ): return _IS_WINDOWS

	def GetDetails( self ):
		if not self._handler.exists(): return None
		return {
			"Version": self._handler.version,
			"BuildDate": _NOTITG_VERSIONS[ self._handler.version ][ "BuildDate" ],
			"Process": self._handler.process
		}

	def Disconnect( self ):
		if not self._handler.exists(): return
		self._handler.reset()

	def Scan( self, deep : bool = False ): return self._handler.scan( deep )
	def FromProcessId( self, id : int ): return self._handler.fromProcessId( id )

	def GetExternal( self, index : int = 0 ):
		if not self._handler.exists(): return -1
		MAX_INDEX = self._handler.get_flag_max_index()
		if index < 0 or index >= MAX_INDEX: raise NotITGError( 'Index is outside range! [0-{}]'.format(MAX_INDEX-1) )
		return self._handler.read( index )

	def SetExternal( self, index : int = 0, flag : int = 0 ):
		if not self._handler.exists(): return
		MAX_INDEX = self._handler.get_flag_max_index()
		if index < 0 or index >= MAX_INDEX: raise NotITGError( 'Index is outside range! [0-{}]'.format(MAX_INDEX-1) )
		self._handler.write( index, flag )

	def Heartbeat( self ):
		if not self._handler.exists(): return False
		STATE = ps.pid_exists( self._handler.process_id )
		if STATE == False: self._handler.reset()
		return STATE

# Handler
# TODO: Throw an error instead when there's a permission/access error.

class _NotITGHandler:
	def __init__( self ):
		self.process_id = None
		self.version = None
		self.process = None

	def exists( self ): return self.process_id != None
	def reset( self ): self.process_id = None
	def get_version_details( self ): return _NOTITG_VERSIONS[ self.version ]
	def get_flag_max_index( self ): return self.get_version_details()[ 'Size' ]

class _NotITGWindowsHandler( _NotITGHandler ):
	def __init__( self ):
		super().__init__();

		K32 = ct.WinDLL ('kernel32' )
		OpenProcess = K32.OpenProcess
		OpenProcess.argtypes = [wt.DWORD, wt.BOOL, wt.DWORD]
		OpenProcess.restype = wt.HANDLE
		ReadProcessMemory = K32.ReadProcessMemory
		ReadProcessMemory.argtypes = [wt.HANDLE, wt.LPCVOID, wt.LPVOID, ct.c_size_t, ct.POINTER(ct.c_size_t)]
		ReadProcessMemory.restype = wt.BOOL
		WriteProcessMemory = K32.WriteProcessMemory
		WriteProcessMemory.restype = wt.BOOL
		WriteProcessMemory.argtypes = [wt.HANDLE, wt.LPVOID, wt.LPCVOID, ct.c_size_t, ct.POINTER(ct.c_size_t)]
		self.OpenProcess = OpenProcess
		self.ReadProcessMemory = ReadProcessMemory
		self.WriteProcessMemory = WriteProcessMemory

		self.k32 = None

	def scan( self, deep ):
		for proc in ps.process_iter(['pid']):
			try:
				kProcess = self.OpenProcess(0x10 | 0x20 | 0x8, False, proc.pid)
				if deep:
					for ver,addresses in _NOTITG_VERSIONS.items():
						STR_LEN = 8
						DATA = ct.create_string_buffer(STR_LEN)
						self.ReadProcessMemory(kProcess, addresses['BuildAddress'], ct.byref(DATA), STR_LEN, ct.byref(ct.c_size_t()))
						try:
							if DATA.value.decode() == str(addresses['BuildDate']):
								self.k32 = kProcess
								self.process_id = proc.pid
								self.process = proc
								self.version = ver
								return True
						except: pass
				else:
					for ver, file_name in _NOTITG_FILENAMES.items():    
						if proc.name().lower() == file_name.lower():
							self.k32 = kProcess
							self.process_id = proc.pid
							self.process = proc
							self.version = ver
							return True
			except (ps.NoSuchProcess, ps.AccessDenied, ps.ZombieProcess):
				pass

		return False

	def fromProcessId( self, id: int ):
		for proc in ps.process_iter(['pid']):
			if proc.pid == id:
				kProcess = self.OpenProcess(0x10 | 0x20 | 0x8, False, proc.pid)
				for ver,addresses in _NOTITG_VERSIONS.items():
					STR_LEN = 8
					DATA = ct.create_string_buffer(STR_LEN)
					self.ReadProcessMemory(kProcess, addresses['BuildAddress'], ct.byref(DATA), STR_LEN, ct.byref(ct.c_size_t()))
					try:
						if DATA.value.decode() == str(addresses['BuildDate']):
							self.k32 = kProcess
							self.process_id = proc.pid
							self.process = proc
							self.version = ver
							return True
					except: pass

		return False

	def read( self, index ):
		DATA = ct.c_int()
		BYTES_READ = ct.c_size_t()
		self.ReadProcessMemory( self.k32, self.get_version_details()['Address'] + (index*4), ct.byref(DATA), ct.sizeof(DATA), ct.byref(BYTES_READ) );
		return DATA.value

	def write( self, index, flag ):
		DATA = ct.c_int( flag )
		BYTES_WRITTEN = ct.c_size_t()
		self.WriteProcessMemory(  self.k32, self.get_version_details()['Address'] + (index*4), bytes(DATA), ct.sizeof(DATA), ct.byref(BYTES_WRITTEN)) # bytes( data ) took some time to figure out.
	
class _NotITGLinuxHandler( _NotITGHandler ):

	class iovec(ct.Structure): _fields_ = [("iov_base",ct.c_void_p),("iov_len",ct.c_size_t)]

	def _create_iovecs( self, BUFFER, ADDRESS ):
		LOCAL, REMOTE = self.iovec(), self.iovec()
		SIZEOF = ct.sizeof( BUFFER )
		LOCAL.iov_base = ct.cast( ct.byref(BUFFER), ct.c_void_p )
		LOCAL.iov_len = SIZEOF
		REMOTE.iov_base = ct.c_void_p( ADDRESS )
		REMOTE.iov_len = SIZEOF
		return LOCAL, REMOTE

	def __init__( self ):
		super().__init__();
		LIBC = ct.CDLL("libc.so.6", use_errno=True)
		vm_read = LIBC.process_vm_readv
		vm_read.argtypes = [ct.c_int, ct.POINTER(self.iovec), ct.c_ulong, ct.POINTER(self.iovec), ct.c_ulong, ct.c_ulong]
		vm_read.restype = ct.c_ssize_t
		vm_write = LIBC.process_vm_writev
		vm_write.argtypes = [ct.c_int, ct.POINTER(self.iovec), ct.c_ulong, ct.POINTER(self.iovec), ct.c_ulong, ct.c_ulong]
		vm_read.restype = ct.c_ssize_t
		self.vm_read = vm_read
		self.vm_write = vm_write

	# Check if we can access the process
	def _check( self, pid, address ):
		BUFFER = ct.c_int()
		LOCAL, REMOTE = self._create_iovecs( BUFFER, address )
		return self.vm_read( pid, LOCAL, 1, REMOTE, 1, 0 ) >= 0

	def scan( self, deep ):

		for proc in ps.process_iter():
			if deep:
				for ver,addresses in _NOTITG_VERSIONS.items():
					if not self._check(proc.pid, _NOTITG_VERSIONS[ver]['Address']):
						if errno.errorcode[ ct.get_errno() ] == "EPERM": raise NotITGError("Cannot access process! Try running the script again with sudo privileges.")
						else: continue
					BUFFER = ct.create_string_buffer(8)
					LOCAL, REMOTE = self._create_iovecs( BUFFER, _NOTITG_VERSIONS[ver]['BuildAddress'] )
					self.vm_read( proc.pid, LOCAL, 1, REMOTE, 1, 0 )
					try:
						if BUFFER.value.decode() == str(addresses['BuildDate']):
							self.process_id = proc.pid
							self.process = proc
							self.version = ver
							return True
					except: pass
			else:
				for ver, file_name in _NOTITG_FILENAMES.items():
					if not self._check(proc.pid, _NOTITG_VERSIONS[ver]['Address']):
						if errno.errorcode[ ct.get_errno() ] == "EPERM": raise NotITGError("Cannot access process! Try running the script again with sudo privileges.")
						else: continue
					if proc.name().lower() == file_name.lower():
						self.process_id = proc.pid
						self.process = proc
						self.version = ver
						return True

		return False

	def fromProcessId( self, id: int ):
		for proc in ps.process_iter(['pid']):
			if proc.pid == id:
				for ver,addresses in _NOTITG_VERSIONS.items():
					if not self._check(proc.pid, _NOTITG_VERSIONS[ver]['Address']):
						if errno.errorcode[ ct.get_errno() ] == "EPERM": raise NotITGError("Cannot access process! Try running the script again with sudo privileges.")
						else: continue
					BUFFER = ct.create_string_buffer(8)
					LOCAL, REMOTE = self._create_iovecs( BUFFER, _NOTITG_VERSIONS[ver]['BuildAddress'] )
					self.vm_read( proc.pid, LOCAL, 1, REMOTE, 1, 0 )
					try:
						if BUFFER.value.decode() == str(addresses['BuildDate']):
							self.process_id = proc.pid
							self.process = proc
							self.version = ver
							return True
					except: pass

		return False

	def read( self, index ):
		BUFFER = ct.c_int()
		LOCAL, REMOTE = self._create_iovecs( BUFFER, self.get_version_details()['Address'] + (index*4) )
		BYTES_READ = self.vm_read( self.process_id, LOCAL, 1, REMOTE, 1, 0 )
		if BYTES_READ < 0: raise NotITGError( errno.errorcode[ ct.get_errno() ] )
		return BUFFER.value

	def write( self, index, flag ):
		LOCAL, REMOTE = self._create_iovecs( ct.c_int( flag ), self.get_version_details()['Address'] + (index*4) )
		BYTES_WRITTEN = self.vm_write( self.process_id, LOCAL, 1, REMOTE, 1, 0 )
		if BYTES_WRITTEN < 0: raise NotITGError( errno.errorcode[ ct.get_errno() ] )
