; Settings
  GWidth = 1280
  GHeight = 720
  R = 255  
  G = 255 
  B = 255 
; Code  

format PE GUI 4.0  
entry start  

; include 'win32w.inc'
include 'win32ax.inc'

section '.text' code readable executable  

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

        invoke  CreateWindowEx,0,_class,_title,WS_VISIBLE+WS_DLGFRAME+WS_SYSMENU,0,0,GWidth,GHeight,NULL,NULL,[wc.hInstance],NULL
        mov     [hwnd],eax  
        invoke GetDC,[hwnd]  
        mov [hDC],eax  
        mov [bmi.biSize],sizeof.BITMAPINFOHEADER  
        mov [bmi.biWidth],GWidth  
        mov [bmi.biHeight],-GHeight
        mov [bmi.biPlanes],1 
        mov [bmi.biBitCount],32
        mov [bmi.biCompression],BI_RGB


		; push HWND_DESKTOP
        ; push txtTitle
        ; push txtMessage
        ; push 0
        ; call [MessageBox]
		; mov [mymsg], "123"
		; invoke MessageBox, HWND_DESKTOP, mymsg, txtTitle, 0


  msg_loop:
        mov [bitsfb], $0

		; mov [mymsg], "123"
		; invoke MessageBox, HWND_DESKTOP, mymsg, txtTitle, 0 

		; invoke SetPixel, 
		
		call [SetPixel]

		inc ecx

        invoke SetDIBitsToDevice,[hDC],0,0,GWidth,GHeight,0,0,0,GHeight,bitsfb,bmi,0
        invoke  GetMessage,msg,NULL,0,0 
        cmp     eax,1  
        jb      end_loop  
        jne     msg_loop  
        invoke  TranslateMessage, msg  
        invoke  DispatchMessage, msg 
        jmp     msg_loop

  error:  
        invoke  MessageBox,NULL,_error,NULL,MB_ICONERROR+MB_OK  

  end_loop:  
        invoke  ExitProcess,[msg.wParam]  

proc WindowProc uses ebx esi edi, hwnd,wmsg,wparam,lparam  
        cmp     [wmsg],WM_DESTROY  
        je      .wmdestroy 
  .defwndproc: 
        invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]  
        jmp     .finish  
  .wmdestroy:  
        invoke  PostQuitMessage,0  
        xor     eax,eax 
  .finish: 
        ret  
endp


section '.data' data readable writeable  

	txtTitle db 'Titlebar',0
	txtMessage db 'Hello World2', 0
	mymsg dd 0, 0

	_class TCHAR 'FASMWIN32',0  
	_title TCHAR 'GDI32 Test',0  
	_error TCHAR 'Startup failed.',0  

	wc WNDCLASS 0,WindowProc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,NULL,_class  

	msg MSG  
	hDC dd 0  
	hwnd dd 0  
	bmi BITMAPINFOHEADER  
	bitsfb  dd GWidth*GHeight dup($ff00)


section '.idata' import data readable writeable  

	library kernel32,'KERNEL32.DLL',\  
			gdi32, 'GDI32.DLL',\  
			user32,'USER32.DLL'  

	include 'api\kernel32.inc'  
	include 'api\gdi32.inc'  
	include 'api\user32.inc'
    