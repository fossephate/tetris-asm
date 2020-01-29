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



proc drawLine; [pGraphics], [pPen] x1 y1 x2 y2

	push	ebp
	mov		ebp, esp
	
	push	eax
	push	ebx
	push	ecx
	push	edx

	; effectively do this:
	; push [ebp + 8]
	; push [ebp + 12]
	; push [ebp + 16]
	; push [ebp + 20]
	; push [ebp + 24]
	; push [ebp + 28]
	; call [GdipDrawLineI]

	mov		ebx, 0

	.copyall:

	; copy counter to edx
	mov		edx, ebx

	imul	edx, 4
	add		edx, 4

	mov		eax, [ebp + edx]
	push	eax

	inc		ebx
	cmp		ebx, 7
	jne		.copyall

	call	[GdipDrawLineI]
	pop		eax; cleanup

	; mov [mymsg], "123"
	; invoke MessageBox, HWND_DESKTOP, mymsg, txtTitle, 0	

	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret
endp

proc drawBox; [pGraphics], [pPen] x y width height

	push	ebp
	mov		ebp, esp

	push	eax
	push	ebx
	push	ecx
	push	edx


	; for [pGraphics], [pPen]
	mov		eax, [ebp + 28]
	push	eax
	mov		eax, [ebp + 24]
	push	eax

	mov		eax, [ebp + 20]
	mov		ebx, [ebp + 16]
	mov		ecx, [ebp + 12]
	mov		edx, [ebp + 8]

	add		ecx, eax
	add		edx, ebx

	; invoke wsprintf, buffer, mbtext, eax
	; invoke MessageBox, HWND_DESKTOP, buffer, txtTitle, 0

	; 0, 0 -> 1, 0
	push	eax
	push	ebx
	push	ecx
	push	ebx
	call	drawLine
	add		esp, 16; (pop * 4)

	; 0, 0 -> 0, 1
	push	eax
	push	ebx
	push	eax
	push	edx
	call	drawLine
	add		esp, 16; (pop * 4)

	; 1, 1 -> 0, 1
	push	ecx
	push	edx
	push	eax
	push	edx
	call	drawLine
	add		esp, 16; (pop * 4)

	; 1, 1 -> 1, 0
	push	ecx
	push	edx
	push	ecx
	push	ebx
	call	drawLine
	add		esp, 16; (pop * 4)

	; pop eax * 2 for [pGraphics], [pPen]
	add		esp, 8; (pop * 2)


	; mov		ebx, 18
	; .freeStack:
	; sub		esp, 4
	; pop		eax
	; dec		ebx
	; jns		.freeStack


	pop		edx
	pop		ecx
	pop		ebx
	pop		eax

	pop		ebp
	ret
endp

proc draw hdc
local pGraphics:DWORD, pPen:DWORD

	invoke  GdipCreateFromHDC, [hdc], addr pGraphics
	invoke  GdipCreatePen1, $FF000000, 3.0, 0, addr pPen
	invoke	GdipSetSmoothingMode, [pGraphics], 2

	; push	[pGraphics]
	; push	[pPen]
	; push	100
	; push	100
	; push	10
	; push	10
	; call	drawBox

	push	[pGraphics]
	push	[pPen]


	push	200
	push	200
	push	10
	push	10
	call	drawBox
	add		esp, 16; (pop * 4)

	push	100
	push	200
	push	10
	push	10
	call	drawBox
	add		esp, 16; (pop * 4)

	push	200
	push	400
	push	20
	push	20
	call	drawBox
	add		esp, 16; (pop * 4)


	push	ebx
	mov		ebx, 300

.loop:

	push	[pGraphics]
	push	[pPen]
	push	ebx
	push	ebx
	push	ebx
	push	ebx
	call	drawBox
	add		esp, 24; (pop * 6)


	; mov		ecx, 6
	; .freeStack2:
	; sub		esp, 4
	; pop		eax
	; dec		ecx
	; jns		.freeStack2
	

	invoke Sleep, 10

	dec		ebx
	; jns		.loop
	cmp		ebx, 50
	jg		.loop
	mov		ebx, 600
	jmp		.loop


	add		esp, 8; (pop * 2)

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

	x1		dd  0
	x2		dd  0
	y1		dd  0
	y2		dd  0

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

  import kernel,\
	 AllocConsole,'AllocConsole',\
	 FreeConsole,'FreeConsole',\
	 GetStdHandle,'GetStdHandle',\
	 WriteConsole,'WriteConsoleA',\
	 ReadConsole,'ReadConsoleA',\
	 ReadConsoleInput,'ReadConsoleInputA',\
	 FlushConsoleInputBuffer,'FlushConsoleInputBuffer',\
	 SetConsoleMode,'SetConsoleMode',\
	 SetConsoleTitle,'SetConsoleTitleA',\
	 SetConsoleTextAttribute,'SetConsoleTextAttribute',\
	 SetConsoleCursorPosition,'SetConsoleCursorPosition',\
	 FillConsoleOutputCharacter,'FillConsoleOutputCharacterA',\
	 GetConsoleScreenBufferInfo,'GetConsoleScreenBufferInfo',\
	 FillConsoleOutputAttribute,'FillConsoleOutputAttribute',\
	 GetEnvironmentVariable,'GetEnvironmentVariableA',\
	 SetEnvironmentVariable,'SetEnvironmentVariableA',\
	 SleepX,'Sleep',\
	 StrCat,'lstrcat',\
	 ExitProcess,'ExitProcess',\
	 lstrlen,'lstrlen'