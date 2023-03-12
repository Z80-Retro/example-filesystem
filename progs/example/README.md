# Simple Example CP/M Programs 

Transient (.COM file) applications designed to be cross-assembled
and executed on a CP/M 2.x system.

To run a .COM file, the CCP will read its contents into memory starting 
at the base TPA address (0x100 on most systems) and then `CALL 0x100`

Upon entry, a .COM file application can count on the CP/M zero-page being 
initialized as per the Alteration guide's discussion of the warm boot
initialization logic and that the stack pointer will be set to an address
such that an RET instruction will resume the execution of the CCP.

    Upon entry to a transient program, the CCP leaves the stack
    pointer set to an eight level stack area with the CCP return 
    address pushed onto the stack, leaving seven levels before 
    overflow occurs.
                                     -- CP/M 2.0 Interface Guide (p. 4)

Recall that it is legal for a .COM file to take over the machine in any 
way.  

If this application overwrites the memory used by the CCP then it MUST return 
to the operating system by executing a JP 0 instruction to force a warm-boot.

    The machine code found at location BOOT performs a system 
    "warm start" which loads and initializes the programs and 
    variables necessary to return control to the CCP. Thus, 
    transient programs need only jump to location BOOT to return 
    control to CP/M at the command level.
                                     -- CP/M 2.0 Interface Guide (p. 1)

If this application overwrites the zero-page jump instruction(s) and/or the 
BIOS then it will no longer be possible to use the BDOS or BIOS.  Such an 
application can only return to CP/M by a cold-boot (press the reset switch.)

The amount of 'available' memory can be determined by knowing that the FDOS
starts at the address in a jump instruction in the the zero-page at 0005.  
The address in the jump instruction is at location 0x0006.  Recall that the 
FDOS begins immediately after the CCP. (Note that the CCP is 0x800 bytes in
size.)
