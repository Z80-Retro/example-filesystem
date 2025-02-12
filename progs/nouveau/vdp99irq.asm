;****************************************************************************
;
;    VDP test app
;
;    Copyright (C) 2025 John Winans
;
;    This library is free software; you can redistribute it and/or
;    modify it under the terms of the GNU Lesser General Public
;    License as published by the Free Software Foundation; either
;    version 2.1 of the License, or (at your option) any later version.
;
;    This library is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;    Lesser General Public License for more details.
;
;    You should have received a copy of the GNU Lesser General Public
;    License along with this library; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
;    USA
;
;****************************************************************************

; Draw a vertical bar pattern.

; This is only when used with certain debug versions of the 2067-Z8S180/fpga/vdp99 modules
; circa the 20250209.1 tagged releases.

.il_reg:        equ     0x33    ; Interrupt Vector Low Register
.itc_reg:       equ     0x34    ; INT/TRAP Control Register

.vdp_vram:	equ	0x80	; VDP port for accessing the VRAM
.vdp_reg:	equ	0x81	; VDP port for accessing the registers

BDOS:           equ     5       ; CP/M entry
CONOUT:         equ     0x02    ; print character in E
CONRDY:         equ     0x0b    ; a = 0 if no char ready, else 0xff
PSTRING:        equ     0x09    ; print string string from DE will $ found

	org	0x100
        ld      sp,.stack_top

        ; It is assumed that the IRQs are disabled and in the reset default state.
        di
        im      2               ; run in IRQ mode 2 (vector table)
        ld      a,.vectab>>8
        ld      i,a
        ld      a,0
        ;out0    (.il_reg),a
        db      0xed,0x39,.il_reg       ; set IL (assumed internal vectors start at 0)
        ld      a,0x04
        db      0xed,0x39,.itc_reg      ; enable INT2 only


        in      a,(.vdp_reg)    ; toss any pre-existing VDP IRQ status
        ei

        ld      e,0             ; modulo counter for pattern starting point
.loop:
        call    .wait_vsync

        ld      c,e             ; starting color code
        ld      b,8             ; number of regs
        ld      d,0x80          ; reg number
.color_loop:
        ld      a,c
        out     (.vdp_reg),a    ; write the pattern value
        ld      a,d
        out     (.vdp_reg),a    ; write the register number
        inc     c               ; ignore overflow out of 3 lsbs
        inc     d
        djnz    .color_loop

        call    .dly
        inc     e               ; change starting color for repaint

        ; if a key has been pressed, exit
        push    de
        ld      c,CONRDY
        call    BDOS
        pop     de
        or      a
        jp      z,.loop


        di                      ; disable IRQs
        xor     a
        ld      i,a             ; put I back where we assume it was
        db      0xed,0x39,.itc_reg      ; disable all INTs
        jp      0               ; exit

.dly:
        ld      b,15            ; how many frame times to wait
.dloop:
        call    .wait_vsync
        dec     b
        jp      nz,.dloop
        ret

        ; wait for the next vsync
.wait_vsync:

        ; if a key has been pressed, return early
        push    bc
        push    de
        ld      c,CONRDY
        call    BDOS
        pop     de
        pop     bc
        or      a
        ret     nz

        ;in      a,(.vdp_reg)
        ld      a,(.vdp_stat)

        and     0x80
        jp      z,.wait_vsync

        xor     a
        ld      (.vdp_stat),a   ; clear the flag for next time

        ret


.int2_handler:
        push    af              ; save the CPU state 
        in      a,(.vdp_reg)    ; read the VDP status reg
        ld      (.vdp_stat),a   ; save the value for later analysis
        pop     af              ; restore the CPU state
        ei
        ;reti   ; not really need since is not a Z80 peripheral
        ret


.null_handler:
        reti

.vdp_stat:
        db      0               ; the latest post-IRQ vdp status 

        ds      0x0100-($&0x00ff)       ; align thyself to the next multiple of 0x100
.vectab:
        dw      .null_handler           ; int1
        dw      .int2_handler           ; int2
        dw      .null_handler           ; prt0
        dw      .null_handler           ; prt1
        dw      .null_handler           ; dma0
        dw      .null_handler           ; dma1
        dw      .null_handler           ; csi/o
        dw      .null_handler           ; asci0
        dw      .null_handler           ; asci1
        

        org     $+0x200
.stack_top:

