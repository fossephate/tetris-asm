; Settings
  Width = 800  
  Height = 600  
  R = 255  
  G = 255 
  B = 255 
; Code  

format PE GUI 4.0  
entry start  

include 'win32w.inc'  

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

        invoke  CreateWindowEx,0,_class,_title,WS_VISIBLE+WS_DLGFRAME+WS_SYSMENU,0,0,800,600,NULL,NULL,[wc.hInstance],NULL
        mov     [hwnd],eax  
        invoke GetDC,[hwnd]  
        mov [hDC],eax  
        mov [bmi.biSize],sizeof.BITMAPINFOHEADER  
        mov [bmi.biWidth],Width  
        mov [bmi.biHeight],-Height
        mov [bmi.biPlanes],1 
        mov [bmi.biBitCount],32
        mov [bmi.biCompression],BI_RGB 

  msg_loop:
        mov [bitsfb], $0

        invoke SetDIBitsToDevice,[hDC],0,0,Width,Height,0,0,0,Height,bitsfb,bmi,0
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

  _class TCHAR 'FASMWIN32',0  
  _title TCHAR 'GDI32 Test',0  
  _error TCHAR 'Startup failed.',0  

  wc WNDCLASS 0,WindowProc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,NULL,_class  

  msg MSG  
  hDC dd 0  
  hwnd dd 0  
  bmi BITMAPINFOHEADER  
  bitsfb  dd Width*Height dup($ff00)


section '.idata' import data readable writeable  

  library kernel32,'KERNEL32.DLL',\  
          gdi32, 'GDI32.DLL',\  
          user32,'USER32.DLL'  

  include 'api\kernel32.inc'  
  include 'api\gdi32.inc'  
  include 'api\user32.inc'
    