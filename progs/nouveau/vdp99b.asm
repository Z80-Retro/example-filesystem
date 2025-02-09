
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

.vdp_vram:	equ	0x80	; VDP port for accessing the VRAM
.vdp_reg:	equ	0x81	; VDP port for accessing the registers

BDOS:           equ     5       ; CP/M entry
CONOUT:         equ     0x02    ; print character in E
CONRDY:         equ     0x0b    ; a = 0 if no char ready, else 0xff
PSTRING:        equ     0x09    ; print string string from DE will $ found

	org	0x100
        ld      sp,.stack_top

        ld      e,0             ; modulo counter for pattern starting point

        ; toss any pre-existing IRQ status
        in      a,(.vdp_reg)

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
        ld      c,CONRDY
        call    BDOS
        or      a
        jp      z,.loop

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
        in      a,(.vdp_reg)
        and     0x80
        jp      z,.wait_vsync
        ret

        ds      0x200
.stack_top:

