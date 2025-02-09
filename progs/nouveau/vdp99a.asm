
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

	org	0x100

        ld      b,8
        ld      c,0x87
        ld      d,0x80
.loop:
        ld      a,c
        out     (.vdp_reg),a
        ld      a,d
        out     (.vdp_reg),a
        dec     c
        inc     d
        djnz    .loop

        ret

