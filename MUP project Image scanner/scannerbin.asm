#make_bin#

; BIN is plain binary format similar to .com format, but not limited to 1 segment;
; All values between # are directives, these values are saved into a separate .binf file.
; Before loading .bin file emulator reads .binf file with the same file name.

; All directives are optional, if you don't need them, delete them.

; set loading address, .bin file will be loaded to this address:
#LOAD_SEGMENT=2000h#
#LOAD_OFFSET=0000h#

; set entry point:
#CS=2000h#	; same as loading segment
#IP=0000h#	; same as loading offset

; set segment registers
#DS=2000h#	; same as loading segment
#ES=0500h#	; same as loading segment

; set stack
#SS=2000h#	; same as loading segment
#SP=FFFEh#	; set to top of loading segment

; set general registers (optional)
#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#
                            
                            
; add your code here   

org 2000h  

	store db 10000 DUP(0)	; 100*100 pixels and every pixel = 1Byte
	stack dw 10 DUP(0)
	top_stack label word
	



lea sp, top_stack
		mov AX, 2000h 	; 
		mov ds, ax		; initializing DS
		
		lea di, store 	;
		mov bx, 00		; horizontal counter
		mov dx, 00		; vertical counter
		
X1:		CALL SCAN
		
		CMP BX, 20	; do the scanning again after shiftingif not reached at the end of the row.
		JNE shift 		; (call scanning function in shift)
		CMP DX, 100	; check if it reached to last row, if not then jump to nextline
		JNE nextl
		
		JMP stop		; to turn the stop led on.
		
		
		; to shift the LEDs by 0.5cm in a row
shift:	MOV al, 80h		; 
		out 26h, al	;
		mov al, 88h		; we want o/p = 10001000 at 20h
		mov cx, 40		; to shift by 0.5cm(pitch/5) we need 200/5 revolutions
loop1:	out 20h, al 	; 
		call delay1		; delay1 function to wait for atleast 10ms = internal delay1 of motor
		ROR al, 01		; clockwise direction is chosen to move shift right in a row
		loop loop1
		
		JMP X1			; jump to scan again after rotating the motor.
		
		
		; to move leds to starting of next line
nextl:	MOV al, 80h		
		out 26h, al
		mov al, 88h
		mov cx, 760	; to move the LEDs from end of the row to the starting. no. of times loop reqd = 40*19
loop2:	out 20h, al
		call delay1
		ROL al, 01		; anticlockwise direction to shift left the leds
		loop loop2
		
		MOV al, 80h
		out 26h, al
		mov al, 88h
		mov cx, 40		; to move down by 0.1cm(pitch/5) we need 200/5 revolutions
loop3:	out 22h, al
		call delay1
		ROR al, 01		; clockwise direction is chose to move down in a column
		loop loop3
		
		inc dx			; increment vertical counter
		
		JMP X1


stop:	mov al, 80h		; 10000000b - all port are output
		out 26h, al	; initializing port2
		
		mov al, 01h		; 00000001b - giving PC0 of port2 'stop' signal
		out 26h, al	; output to PC0 given to turn on stop led

		
	


SCAN:

	mov al, 98h 	;10011000b since only data lines(10h) and upper 14h are input and mode 0 - 
	out 16h, al	;initializing port1

	Scan1:	mov al, 06h		; 00000110b - PC3 = SOC low pulse
			out 16h, al

			mov al, 01h		; 01 is the ADC port
			out 12h, al 	; using B to select 1st input of ADC
		
			;we will be keeping ALE and OE at 5V all time.

			
			; giving SOC a pulse
			
			mov al, 07h 	; 00000111b - PC3 = SOC high pulse
			out 16h, al	
			call delay2				; use sufficient nop such that 8255 can read it..becz 86 runs at x5 speed than 8255 and therefore provide delay of atleast 2microsec
			mov al, 06h 	; 00000110b - PC3 = SOC low pulse
			out 16h, al 
		
	check11:in al, 14h 	; checking input of port C to know EOC value
			mov cl, 1
			rcl al, cl
			jc check11		; this is to check if EOC is low, if not repeat
			
	check12:in al, 14h
			mov cl,1 
			rcl al, cl
			jnc check12		; this is to check if EOC is high, if not then dont jump
			
		
			in al, 10h 	; 
			mov [di], al	; moving the data into store loc.
			inc di 			;
		
		
		



	Scan2:	mov al, 06h		; 00000110b - PC3 = SOC low pulse
			out 16h, al

			mov al, 02h		; 02 is the ADC port
			out 12h, al 	; using B to select 1st input of ADC
		
			;we will be keeping ALE and OE at 5V all time.
		
			
			; giving SOC a pulse
			
			mov al, 07h 	; 00000111b - PC3 = SOC high pulse
			out 16h, al	
			call delay2				; use sufficient nop such that 8255 can read it..becz 86 runs at very high speed than 8255
			mov al, 06h 	; 00000110b - PC3 = SOC low pulse
			out 16h, al 
		
	check21:in al, 14h 	; checking input of port C to know EOC value
			mov cl, 1
			rcl al, cl
			jc check21		; this is to check if EOC is low, if not repeat	
		
	check22:in al, 14h
			mov cl,1 
			rcl al, cl
			jnc check22		; this is to check if EOC is high, if not then dont jump
		
			
			in al, 10h 	; 
			mov [di], al	; moving the data into store loc.
			inc di 	
		
		
	Scan3:	mov al, 06h		; 00000110b - PC3 = SOC low pulse
			out 16h, al
	
			mov al, 03h		; 03 is the ADC port
			out 12h, al 	; using B to select 1st input of ADC
			
			;we will be keeping ALE and OE at 5V all time.
			
			
				; giving SOC a pulse
				
			mov al, 07h 	; 00000111b - PC3 = SOC high pulse
			out 16h, al	
			call delay2				; use sufficient nop such that 8255 can read it..becz 86 runs at very high speed than 8255
			mov al, 06h 	; 00000110b - PC3 = SOC low pulse
			out 16h, al 
		
	check31:in al, 14h 	; checking input of port C to know EOC value
			mov cl, 1
			rcl al, cl
			jc check31		; this is to check if EOC is low, if not repeat
		
	check32:in al, 14h
			mov cl,1 
			rcl al, cl
			jnc check32		; this is to check if EOC is high, if not then dont jump
			
			
			in al, 10h 	; 
			mov [di], al	; moving the data into store loc.
			inc di 
		
		
	Scan4:	mov al, 06h		; 00000110b - PC3 = SOC low pulse
			out 16h, al
	
			mov al, 04h		; 04 is the ADC port
			out 12h, al 	; using B to select 1st input of ADC
			
			;we will be keeping ALE and OE at 5V all time.
			
		
			; giving SOC a pulse
		
			mov al, 07h 	; 00000111b - PC3 = SOC high pulse
			out 16h, al	
			call delay2				; use sufficient nop such that 8255 can read it..becz 86 runs at very high speed than 8255
			mov al, 06h 	; 00000110b - PC3 = SOC low pulse
			out 16h, al 
		
	check41:in al, 14h 	; checking input of port C to know EOC value
			mov cl, 1
			rcl al, cl
			jc check41		; this is to check if EOC is low, if not repeat
		
	check42:in al, 14h
			mov cl,1 
			rcl al, cl
			jnc check42		; this is to check if EOC is high, if not then dont jump
			
		
			in al, 10h 	; 
			mov [di], al	; moving the data into store loc.
			inc di 
		
		
	Scan5:	mov al, 06h		; 00000110b - PC3 = SOC low pulse
			out 16h, al
	
			mov al, 05h		; 05 is the ADC port
			out 12h, al 	; using B to select 1st input of ADC
		
			;we will be keeping ALE and OE at 5V all time.
		
		
			; giving SOC a pulse
		
			mov al, 07h 	; 00000111b - PC3 = SOC high pulse
			out 16h, al	
			call delay2				; use sufficient nop such that 8255 can read it..becz 86 runs at very high speed than 8255
			mov al, 06h 	; 00000110b - PC3 = SOC low pulse
			out 16h, al 
		
	check51:in al, 14h 	; checking input of port C to know EOC value
			mov cl, 1
			rcl al, cl
			jc check51		; this is to check if EOC is low, if not repeat
			
	check52:in al, 14h
			mov cl,1 
			rcl al, cl
			jnc check52		; this is to check if EOC is high, if not then dont jump
	
			
			in al, 10h 	; 
			mov [di], al	; moving the data into store loc.
			inc di 
			
	INC BX	; increasing horizontal counter
		
	RET

		
delay1:
	push cx
		mov cx, 3000
loop4: 	nop
		nop
		nop
		nop
		nop
		loop loop4
	pop cx
	ret

delay2:
		nop 
		nop
		nop
		nop
	ret         


HLT           ; halt!


