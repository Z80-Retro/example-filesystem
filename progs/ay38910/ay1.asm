;****************************************************************************
;
;    AY-3-8910 tone tester
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
;
;****************************************************************************

.ay_addr:       equ     0xb0
.ay_data:       equ     0xb1

.joy0:		equ	0xa8		; I/O port for joystick 0
.joy1:		equ	0xa9		; I/O port for joystick 1

joy_left:	equ	0x04		; and-mask for left
joy_right:	equ	0x20		; and-mask for right
joy_up:		equ	0x80		; and-mask for up
joy_down:	equ	0x40		; and-mask for down
joy_btn:	equ	0x01		; and-mask for button

bdos:           equ     0x0005          ; BDOS entry point

	org	0x100

        ld      bc,0x00e7               ; A low
        call    .ay_write_reg
        ld      bc,0x0107               ; A hi
        call    .ay_write_reg
        ld      bc,0x080f               ; A max amp, no env
        call    .ay_write_reg
        ld      bc,0x073e               ; enable A tone only
        call    .ay_write_reg

        ret

.joy_loop:
        ;just shove the joystick bits into the period reg so can change it easily 
        in      a,(.joy0)
        ld      b,0x01
        ld      c,a
        call    .ay_write_reg
        jp      .joy_loop

        ret

.ay_write_reg:
        ld      a,b
        out     (.ay_addr),a
        ld      a,c
        out     (.ay_data),a
        ret
