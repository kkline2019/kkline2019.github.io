;Dodge the Lasers
;In this game you are put in a grid and dodge the lasers for as 
;long as possible the game is best played on a screen size 120 by 40.
INCLUDE Irvine32.inc

.data 
	wall BYTE "------------------------------------------------------------------------------------------------------------------------",0
	attack BYTE "________________________________________________________________________________________________________________________",0
	blank BYTE "                                                                                                                        ",0
	game_over BYTE "Game Over You have been shot!",0
	x_coord BYTE 20
	y_coord BYTE 20
	atk_y_coord BYTE 1
	atk_y_coord2 BYTE 1
	atk_y_coord3 BYTE 1

	atk_x_coord BYTE 1
	atk_x_coord2 BYTE 1

	old_y_coord BYTE 1
	old_y_coord2 BYTE 1
	old_y_coord3 BYTE 1
	old_x_coord BYTE 1
	old_x_coord2 BYTE 1

	input BYTE ?
.code
main PROC
;Sets the boundaries for the game sets up the player location then starts the game
	
	mov edx, OFFSET wall
	call WriteString
	mov dl, 0
	mov dh, 29
	call Gotoxy
	mov edx, OFFSET wall
	call WriteString
	call Player

	call Game

	mov dl, 0
	mov dh, 31
	call Gotoxy

	exit
main ENDP
;Determines where the attacks are coming from and tells the player
Incoming PROC
;Inorder to remove the attack on screen we need to save the previous attack coordinates
	mov ah, atk_y_coord
	mov old_y_coord, ah
	mov ah, atk_y_coord2
	mov old_y_coord2, ah
	mov ah, atk_y_coord3
	mov old_y_coord3, ah
	mov ah, atk_x_coord
	mov old_x_coord, ah
	mov ah, atk_x_coord2
	mov old_x_coord2, ah
;A random number generator for the y coordinate attacks from 1-28
	mov ah, 27
	call RandomRange
	inc ah

	mov atk_y_coord, ah
	mov dl, 0
	mov dh, atk_y_coord
	call Gotoxy
;Alerts the player that an attack will come from this spot
	mov al, "!"
	call WriteChar

	mov ah, 27
	call RandomRange
	inc ah

	mov atk_y_coord2, ah
	mov dl, 0
	mov dh, atk_y_coord2
	call Gotoxy

	mov al, "!"
	call WriteChar

	mov ah, 27
	call RandomRange
	inc ah

	mov atk_y_coord3, ah
	mov dl, 0
	mov dh, atk_y_coord3
	call Gotoxy

	mov al, "!"
	call WriteChar
;A random number generator which finds the x coordinate for an attack (1-119)
	mov ah, 118
	call RandomRange
	inc ah

	mov atk_x_coord, ah
	mov dl, atk_x_coord
	mov dh, 1
	call Gotoxy

	mov al, "!"
	call WriteChar

	mov ah, 118
	call RandomRange
	inc ah

	mov atk_x_coord2, ah
	mov dl, atk_x_coord2
	mov dh, 1
	call Gotoxy

	mov al, "!"
	call WriteChar
	ret
Incoming ENDP
;Removes the previous attack from the screen to avoid clutter
Reset PROC
;Goes to the y coordinate and erases the row
	mov dl, 0
	mov dh, old_y_coord
	call Gotoxy

	mov edx, OFFSET blank
	call WriteString

	mov dl, 0
	mov dh, old_y_coord2
	call Gotoxy

	mov edx, OFFSET blank
	call WriteString

	mov dl, 0
	mov dh, old_y_coord3
	call Gotoxy

	mov edx, OFFSET blank
	call WriteString

	mov dl, old_x_coord
	mov dh, 1
;To remove the x coordinate attack a loop is called to go row by row setting that rows x coordinate equal to " "
	x1:
		call Gotoxy
		mov al, " "
		inc dh
		call WriteChar
	;Stops erasing when the loop reaches the boundary
		cmp dh, 28
		jle x1

	mov dl, old_x_coord2
	mov dh, 1
	x2:
		call Gotoxy
		mov al, " "
		inc dh
		call WriteChar

		cmp dh, 28
		jle x2
	ret
Reset ENDP
;Attacks the user
Strike PROC
;Goes to the y coordinate and sets the row equal to the attack laser
	mov dl, 0
	mov dh, atk_y_coord
	call Gotoxy

	mov edx, OFFSET attack
	call WriteString
;Checks if the users y coordinate is equal to the y coordinate the attack comes from
	mov ah, y_coord
	cmp atk_y_coord, ah
	je lose

	mov dl, 0
	mov dh, atk_y_coord2
	call Gotoxy

	mov edx, OFFSET attack
	call WriteString

	mov ah, y_coord
	cmp atk_y_coord2, ah
	je lose

	mov dl, 0
	mov dh, atk_y_coord3
	call Gotoxy

	mov edx, OFFSET attack
	call WriteString

	mov ah, y_coord
	cmp atk_y_coord3, ah
	je lose
;For the x coordinate attacks it goes row by row placing "|" at the specified x coordinate
	mov dl, atk_x_coord
	mov dh, 1
	atk_x1:
		call Gotoxy
		mov al, "|"
		inc dh
		call WriteChar
	;Once the attack reaches the boundary it stops 
		cmp dh, 28
		jle atk_x1

		mov ah, x_coord
		cmp atk_x_coord, ah
		je lose

	mov dl, atk_x_coord2
	mov dh, 1
	atk_x2:
		call Gotoxy
		mov al, "|"
		inc dh
		call WriteChar

		cmp dh, 28
		jle atk_x2

		mov ah, x_coord
		cmp atk_x_coord2, ah
		je lose
	ret
	lose:
		mov dl, 0
		mov dh, 31
		call Gotoxy

		mov edx, offset game_over
		call WriteString
		call Crlf
		exit
Strike ENDP

Player PROC
;Finds the users location and places an "X" indicating where the user is
	mov dl, x_coord
	mov dh, y_coord
	call Gotoxy
	mov al, "X"
	call WriteChar
	ret
Player ENDP

Game Proc
	L1:	
		mov dl, x_coord
		mov dh, y_coord
		call Gotoxy
		;Asks the user where they want to move 
		call ReadChar		  
		mov input,al		   
		call Reset
		;User wants to quit
		cmp input, "x"
		je exitGame
		;User wants to move up
		cmp input, "w"
		je Up
		;User wants to move down
		cmp input, "s"
		je Down
		;User wants to move right
		cmp input, "d"
		je Right
		;User wants to move left
		cmp input, "a"
		je Left
		;If the users input doesn't match any case nothing happens and the user tries again
		jmp L1

		;Make sure the user doesn't go off board if the user is at a boundary the input is invalid and the user 
		;Can enter a new input, otherwise the game continues i.e. the user moves, attacks are shown, and shows the next attacks
		Up:	
			cmp y_coord, 2
			je L1

			call Erase
			dec y_coord
			call Player
			call Strike
			call Incoming
			jmp L1
		Down:
			cmp y_coord, 28
			je L1

			call Erase
			
			inc y_coord
			call Player
			call Strike
			call Incoming
			jmp L1
		Right:
			cmp x_coord, 119
			je L1

			call Erase

			inc x_coord
			call Player
			call Strike
			call Incoming
			jmp L1
		Left:
			cmp x_coord, 1
			je L1

			call Erase

			dec x_coord
			call Player
			call Strike
			call Incoming
			jmp L1

	;Ends the game
	exitGame:
		ret
Game ENDP

Erase PROC
;Removes the users old location
	mov dl, x_coord
	mov dh, y_coord
	call Gotoxy
	mov al, " "
	call WriteChar
	ret
Erase ENDP

end main
