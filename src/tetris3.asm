; Settings
  GWidth = 1280
  GHeight = 720
  R = 255  
  G = 255 
  B = 255 
; Code  

format PE console 4.0

; include 'win32w.inc'  
include 'win32ax.inc'

section '.data' data readable writeable
    msg  dd 0,0

section '.idata' import data readable writeable  

	library kernel32,'KERNEL32.DLL',\  
			gdi32, 'GDI32.DLL',\  
			user32,'USER32.DLL'  

	include 'api\kernel32.inc'  
	include 'api\gdi32.inc'  
	include 'api\user32.inc'

section '.text' code readable executable  
	main:
		mov [msg], "123"
	invoke MessageBox, 0,  addr msg,  0, 0
	; invoke ExitProcess, 0

