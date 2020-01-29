; Template for program using standard Win32 headers

format PE GUI 4.0
entry start

include 'win32ax.inc'
struct GdiplusStartupInput
  GdiplusVersion dd ?
  DebugEventCallback dd ?
  SuppressBackgroundThread dd ?
  SuppressExternalCodecs dd ?
ends

section '.data' data readable writeable

  _class TCHAR 'FASMWIN32',0
  _title TCHAR 'Tetris',0
  _error TCHAR 'Startup failed.',0

  wc WNDCLASS 0,WindowProc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,NULL,_class

  msg MSG
  input GdiplusStartupInput 1 ; GdiplusVersion = 1
  token dd ?

section '.code' code readable executable

  start:

        invoke  GetModuleHandle,0
        mov     [wc.hInstance],eax
        invoke  LoadIcon,0,IDI_APPLICATION
        mov     [wc.hIcon],eax
        invoke  LoadCursor,0,IDC_ARROW
        mov     [wc.hCursor],eax
        invoke  RegisterClass,wc
        test    eax,eax
        jz      error

        invoke  GdiplusStartup, token, input, NULL
        test    eax, eax
        jnz     error

        invoke  CreateWindowEx,0,_class,_title,WS_VISIBLE+WS_DLGFRAME+WS_SYSMENU,128,128,256*3,192*3,NULL,NULL,[wc.hInstance],NULL
        test    eax,eax
        jz      error

  msg_loop:
        invoke  GetMessage,msg,NULL,0,0
        cmp     eax,1
        jb      end_loop
        jne     msg_loop
        invoke  TranslateMessage,msg
        invoke  DispatchMessage,msg
        jmp     msg_loop

  error:
        invoke  MessageBox,NULL,_error,NULL,MB_ICONERROR+MB_OK

  end_loop:
        invoke  GdiplusShutdown, [token]
        invoke  ExitProcess,[msg.wParam]

proc WindowProc hwnd, wmsg, wparam, lparam
local ps:PAINTSTRUCT

        push	ebx
		push	esi
		push	edi

        cmp     [wmsg], WM_DESTROY
        je      .wmdestroy

        cmp     [wmsg], WM_PAINT
        je      .wmpaint

  .defwndproc:
        invoke	DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
        jmp		.finish

  .wmpaint:
        invoke	BeginPaint, [hwnd], addr ps
        stdcall	draw, eax
        invoke	EndPaint, [hwnd], addr ps
        jmp		.finish_ret_0

  .wmdestroy:
        invoke  PostQuitMessage,0

  .finish_ret_0:
        xor		eax, eax

  .finish:
        pop		edi esi ebx
        ret
endp

proc drawNode x, y, node

  ret
endp

;---------------------------------------------------------
;   Proc to show values of data variables.
;---------------------------------------------------------
proc show_me, fmt, prompt, val
    cinvoke printf, [fmt], [prompt], [val]
    cinvoke printf, strfmt, CRLF
    ret
endp



proc drawBox; x y width height

	push	ebp
	mov		ebp, esp

	; mov eax, [ebp + 28]
	; mov ebx, [ebp + 24]

	; mov ecx, [ebp + 16]

; 	; invoke	GdipDrawLineI, [pGraphics], [pPen], x, y, addr x+width, y+height

	; invoke	GdipDrawLineI, eax, ebx, 80, 200, 600, 300


	; effectively do this:
	; push [ebp + 28]
	; push [ebp + 24]
	; push [ebp + 20]
	; push [ebp + 16]
	; push [ebp + 12]
	; push [ebp + 8]



	; push	100
	; push	200
	; push	300
	; push	400
	; mov		eax, [ebp + 24]
	; push	eax
	; mov		eax, [ebp + 28]
	; push	eax
	; call [GdipDrawLineI]

	mov		ebx, 0

	.copyall:

	; copy counter to edx
	mov		edx, ebx
	; put into 32 - i*4 format
	imul	edx, 4
	add		edx, 4

	mov		eax, [ebp + edx]
	push	eax

	; mov ebx, ecx

	; mov [mymsg], ecx
	; mov		edx, ebx
	; invoke wsprintf, buffer, mbtext, edx
	; invoke MessageBox, HWND_DESKTOP, buffer, txtTitle, 0

	; mov		eax, [val1]
	; stdcall show_me, dfmt, intval, [val1]

	inc		ebx
	cmp		ebx, 7
	jne		.copyall

	call [GdipDrawLineI]
	

	pop ebp
	ret
endp

proc draw hdc
local pGraphics:DWORD, pPen:DWORD

	invoke  GdipCreateFromHDC, [hdc], addr pGraphics
	invoke  GdipCreatePen1, $FF000000, 3.0, 0, addr pPen

	push	ebx
	mov		ebx, 10

	invoke	GdipSetSmoothingMode, [pGraphics], 2

	push	[pGraphics]
	push	[pPen]
	push	0
	push	0
	push	400
	push	200
	call	drawBox

	mov		ebx, 10

.loop:




	; invoke	GdipDrawLineI, [pGraphics], [pPen], addr 0+ebx*8, addr 100+ebx*8, addr 500+ebx*8, addr 200+ebx*8

	dec		ebx
	jns		.loop

	pop		ebx

	invoke  GdipDeleteGraphics, [pGraphics]
	invoke  GdipDeletePen, [pPen]
	ret
endp


section '.data' data readable writeable  

	txtTitle db 'Titlebar',0
	txtMessage db 'Hello World2', 0
	mymsg dd 0, 0

	mbtext  db '%lu',0
	buffer rb 256

	CRLF      db '',13,10,0  ; carriage return and linefeed
    dfmt      db '%s = %d',0
    intval    db 'Integer value',0
	strfmt    db  '%s',0

	val1      dd  7


section '.idata' import data readable writeable

	; library gdi, 'gdi.dll',\
	; 	gdiplus, 'gdiplus.dll',\
	; 	kernel32,'kernel32.dll',\
	; 	user32,'user32.dll'
	; 	; msvcrt,  'msvcrt.dll'

	library msvcrt, 'msvcrt.dll',\
		gdi, 'gdi.dll',\
		gdiplus, 'gdiplus.dll',\
		kernel32,'kernel32.dll',\
		user32,'user32.dll'

	include 'api\gdi32.inc'

	import  gdiplus,\
		GdiplusShutdown, 'GdiplusShutdown',\
		GdipCreateFromHDC, 'GdipCreateFromHDC',\
		GdipCreatePen1, 'GdipCreatePen1',\
		GdipDeleteGraphics, 'GdipDeleteGraphics',\
		GdipDeletePen, 'GdipDeletePen',\
		GdipDrawLineI, 'GdipDrawLineI',\
		GdipSetSmoothingMode, 'GdipSetSmoothingMode',\
		GdiplusStartup, 'GdiplusStartup'

	include 'api\kernel32.inc'
	include 'api\user32.inc'
	
	import msvcrt,\
		printf, 'printf',\
		getchar,'getchar'