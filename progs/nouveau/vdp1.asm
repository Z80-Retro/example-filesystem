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

; Read the status register in a spin loop
; We count the number of times that the VDP frame flag is seen over time.
; Stop by pressing a key and see the total frame count

.vdp_vram:	equ	0x80	; VDP port for accessing the VRAM
.vdp_reg:	equ	0x81	; VDP port for accessing the registers
BDOS:           equ     5       ; CP/M entry
CONOUT:         equ     0x02    ; print character in E
CONRDY:         equ     0x0b    ; a = 0 if no char ready, else 0xff
PSTRING:        equ     0x09    ; print string string from DE will $ found

	org	0x100
        ld      sp,.stack_top

.waitf:
        ; check if key hit
        ; key pressed, discard it and exit

        in      a,(.vdp_reg)
        and     0x80
        jp      z,.chkkey

        ; increment the low half
        ld      hl,(ctrl)
        inc     hl
        ld      (ctrl),hl
        ld      a,h
        or      l
        jp      nz,.skiphi

        ; increment the high half when the low half has a carry
        ld      hl,(ctrh)
        inc     hl
        ld      (ctrh),hl
        ld      a,h
        or      l

.skiphi:
        ; be careful here since must not waste more than 1/60 second printing!
        ld      c,CONOUT
        ld      e,'.'           ; the character to print is a dot
        call    BDOS

.chkkey:
        ld      c,CONRDY
        call    BDOS
        or      a
        jp      z,.waitf
        ; else fall thru to .shutdown

.shutdown:
        ld      c,PSTRING
        ld      de,cmsg
        call    BDOS

        ld      a,(ctrh+1)
        call    hexdump_a
        ld      a,(ctrh)
        call    hexdump_a
        ld      a,(ctrl+1)
        call    hexdump_a
        ld      a,(ctrl)
        call    hexdump_a
        call    puts_crlf

        jp      0


cmsg:   db      "\r\nframe count: 0x$"

; 32-bit count of the number of frames
ctrh:   dw      0
ctrl:   dw      0

; XXX Stealing these from the BIOS is just wrong.
; We need versions that will flow into the BDOS.
include 'hexdump.asm'
include 'puts.asm'
include 'console.asm'


        ds      0x200   ; more stack space than we will need
.stack_top:
