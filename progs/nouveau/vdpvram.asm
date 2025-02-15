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

; test the VRAM by writing data into it, reading it back, and comparing.

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

        xor     a
        ld      (.pat_ctr),a

.loop:
        ld      a,(.pat_ctr)
        inc     a                               ; on the first pass, this will be 1
        ld      (.pat_ctr),a
        ld      (.vram_buf),a

        ld      hl,.vram_buf
        ld      de,.vram_buf+1
        ld      bc,.vram_buf_end-.vram_buf-1
        ldir

        ; this is a waste of ram but it tests the speed of the VDP vram I/O

        ; copy the VRAM buffer out
        ld      hl,.vram_buf                    ; starting address of buf to write
        ld      e,(.vram_buf_end-.vram_buf)/256 ; how many 256-byte blocks to write
.wr_256:
        ld      b,0             ; 256 bytes
        ld      c,.vdp_vram
        otir
        dec     e
        jr      nz,.wr_256

        ; read the VRAM buffer back to compare its contents
        ld      hl,.vram_buf2
        ld      e,(.vram_buf_end2-.vram_buf2)/256
.rd_256:
        ld      b,0                             ; 256 bytes
        ld      c,.vdp_vram
        otir
        dec     e
        jr      nz,.rd_256

        ; compare the contents of the two buffers
        ld      a,(.pat_ctr)                    ; needle
        inc     a
        ld      (.needle),a
        ld      hl,.vram_buf                    ; haystack
        ld      bc,.vram_buf_end-.vram_buf+2    ; include the needle/sentinel byte (plus one)
        cpir                                    ; find needle in haystack

        jp      nz,.cpir_fail
        dec     bc                              ; if found the sentinel then BC should be 1
        jp      nz,.cpir_fail

        ; if a key has been pressed, exit
        push    de
        ld      c,CONRDY
        call    BDOS
        pop     de
        or      a
        jp      nz,.success

        ld      a,(.pat_ctr)
        or      a                               ; if we didn't complete a pass with the value 0..
        jp      nz,.loop                        ; then keep going

.success:
        ; print a success message

        ld      de,.success_msg
        ld      c,PSTRING
        call    BDOS
        jp      0               ; exit

.cpir_fail:

        ; print fail message
        ld      de,.fail_msg
        ld      c,PSTRING
        call    BDOS
        jp      0

.success_msg:
        db      "success\r\n$"
.fail_msg:
        db      "failed\r\n$"
.pat_ctr:
        db      0

.vram_buf:
        org     $+8192
.vram_buf_end:

.vram_buf2:
        org     $+8192
.vram_buf_end2:
.needle:                        ; place for a sentinel value 
        org     $+1

        org     $+0x200
.stack_top:

