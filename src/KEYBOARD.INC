
KEY_ESC = 1
KEY_SPACE = 39h

keyboard_IRQ:
        IRQ_enter
        push    eax ds
        mov     ax,main_data
        mov     ds,ax
      .read:
        in      al,60h                  ; read scan code
        movzx   eax,al
        cmp     al,0E0h
        jae     .done
        test    al,80h
        jz      .pressed
        and     al,7Fh
        mov     [keyboard+eax],0
        jmp     .done
      .pressed:
        cmp     [keyboard+eax],0
        jne     .done
        mov     [keyboard+eax],1
      .done:
        in      al,64h
        test    al,1
        jnz     .read
        in      al,61h                  ; give finishing information
        out     61h,al                  ; to keyboard...
        mov     al,20h
        out     20h,al                  ; ...and interrupt controller
        pop     ds eax
        IRQ_leave

init_keyboard:
        mov     edi,keyboard
        xor     al,al
        mov     ecx,80h
        rep     stos byte [edi]
        mov     bl,1
        mov     dx,keyboard_IRQ
        call    set_IRQ
        cli
        xor     bl,bl
        call    set_keyboard_LEDs
        sti
        ret

reset_keyboard:
        push    ds
        xor     ax,ax
        mov     ds,ax
        cli
        mov     bl,[417h]
        shr     bl,4
        call    set_keyboard_LEDs
        mov     bl,1
        call    reset_IRQ
        sti
        pop     ds
        ret

set_keyboard_LEDs:
; bl = keyboard LEDs status
        mov     ah,0ADh
        call    write_8042
        mov     ah,0EDh
        call    write_keyboard
        mov     ah,bl
        and     ah,111b
        call    write_keyboard
        mov     ah,0AEh
        call    write_8042
        ret
      write_8042:
        in      al,64h
        test    al,10b
        jnz     write_8042
        mov     al,ah
        out     64h,al
        ret
      write_keyboard:
        mov     al,ah
        out     60h,al
        in      al,60h
        cmp     al,0FAh
        jne     write_keyboard
        ret
