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
        ld      (.vram_buf),a
        ld      hl,.vram_buf
        ld      de,.vram_buf+1
        ld      bc,.vram_buf_end-.vram_buf-1
        ldir

        ; Note that this program might not work properly when VDP interrupts 
        ; are enabled and the VDP handler reads the status register.


        ; This is a waste of ram but it tests the speed of the VDP vram I/O.

        ;********************************************************
        ; copy the VRAM buffer out
        in      a,(.vdp_reg)                    ; read the status register to reset the reg fsm
        ld      a,0x00
        out     (.vdp_reg),a                    ; VRAM address LSB
        ld      a,0x40                          ; VRAM MSB (with 01 in msbs)
        out     (.vdp_reg),a                    ; VRAM address MSB

        ld      hl,.vram_buf                    ; starting address of buf to write
        ld      e,(.vram_buf_end-.vram_buf)/256 ; how many 256-byte blocks to write
.wr_256:
        ld      b,0             ; 256 bytes
        ld      c,.vdp_vram
        otir
        dec     e
        jr      nz,.wr_256

        ;********************************************************
        ; read the VRAM buffer back to compare its contents
        in      a,(.vdp_reg)                    ; read the status register to reset the reg fsm
        ld      a,0x00
        out     (.vdp_reg),a                    ; VRAM address LSB
        ;ld      a,0x00                          ; VRAM MSB (with 00 in msbs)
        out     (.vdp_reg),a                    ; VRAM address MSB

        ld      hl,.vram_buf2
        ld      e,(.vram_buf_end2-.vram_buf2)/256
.rd_256:
        ld      b,0                             ; 256 bytes
        ld      c,.vdp_vram
        inir
        dec     e
        jr      nz,.rd_256

        ;********************************************************
        ; compare the contents of the two buffers
        ld      hl,.vram_buf                    ; buffer A
        ld      de,.vram_buf2                   ; buffer B
        ld      bc,.vram_buf_end-.vram_buf      ; number of bytyes to compare
.cmp_loop:
        ld      a,(de)
        cp      (hl)
        jp      nz,.cmp_fail
        inc     hl
        inc     de
        dec     bc
        ld      a,b
        or      c
        jr      nz,.cmp_loop

        ;********************************************************
        ; if a key has been pressed, exit
        ld      c,CONRDY
        call    BDOS
        or      a                               ; a = 0xff if a key is pressed
        jp      nz,.success

        ;********************************************************
        ; Say something as we go so we know that it is working
        ld      e,'.'
        ld      c,CONOUT
        call    BDOS

        ; twiddle the border color
        ld      a,(.pat_ctr)
        out     (.vdp_reg),a                    ; reg value we want to set
        ld      a,0x87                          ; reg number 7 (with msbs set to 10)
        out     (.vdp_reg),a

        ;********************************************************
        ; increment the pattern number for the next pass 
        ld      a,(.pat_ctr)
        inc     a                               ; on the first pass, this will be 1
        ld      (.pat_ctr),a
        or      a                               ; if we count back to 0 then we're done
        jp      nz,.loop                        ; else keep going
        ; else fall through to success

.success:
        ; print a success message

        ld      de,.success_msg
        ld      c,PSTRING
        call    BDOS
        jp      0               ; exit

.cmp_fail:

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

        org     $+0x200
.stack_top:

