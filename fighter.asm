;Fighting Game
;This is my entry for the assembly language game contest. In this game you build a character's stats and have fight against 
;A preset opponent
INCLUDE Irvine32.inc
.data
	msg byte "Character Build",0
	character byte "You have 18 points to spend on character stats for attack, defense, and speed",0
	attack byte "How many points do you wanna put into attack: ",0
	defense byte "How many points do you wanna put into defense: ",0
	speed byte "How many points do you wanna put into speed: ",0
	remaining byte "The number of stats you have left are ",0
	rules1 byte "You have 30 health points and your opponent has 40", 0
	rules2 byte "Your goal is to reduce your opponents health to 0", 0
	rules3 byte "You have 2 fireballs that deals 7 damage to your opponent always and 1 shield that reduces damage to 0", 0
	opponent byte "Choose opponent 1, 2: ", 0
	invalid byte "This is an invalid entry please try again", 0
	use_fireball byte "It is your turn do you want to use a fireball (y/n): ", 0
	use_shield byte "Your opponent is going to attack do you want to shield (y/n): ", 0
	lost byte "Sorry you lost better luck next time", 0
	won byte "Congratulations you won!!", 0
	damage byte "You dealt ", 0
	damage2 byte " points of damage.", 0
	hit1 byte "You were hit for ", 0
	hit2 byte " points of damage.", 0
	outof byte "You are out of this action", 0

	atk DWORD ?
	def DWORD ?
	spd DWORD ?
	op_atk DWORD ?
	op_def DWORD ?
	op_spd DWORD ?

	health DWORD 30
	op_health DWORD 40	
	total_stats DWORD 18
	fireball DWORD 2
	shield DWORD 1

	buffer byte 129 DUP(0)
.code

main PROC
    mov edx, offset msg
	call WriteString
	call Crlf
	call Stats
	call Rules
	call Challenger
	call Fight
	exit
main ENDP

Challenger PROC
;This procedure determines who you are fighting 
;You are asked if you want to fight opponent 1 or 2 and depending on your answer stats are assigned to the opponent
	mov edx, offset opponent
	call WriteString
	call readInt
	
	cmp eax, 1
	je opponent_1

	cmp eax, 2
	je opponent_2

	mov edx, offset invalid
	call WriteString
	call Crlf
	call Challenger
	ret

	opponent_1:
		mov op_atk, 12
		mov op_def, 3
		mov op_spd, 3
		ret
	opponent_2:
		mov op_atk, 3
		mov op_def, 12
		mov op_spd, 3
		ret
	
Challenger ENDP

Fight PROC
;To decide who goes first we compare your characters speed to your opponents
;If your speed is higher or equal to your opponents you go first
	mov eax, spd
	cmp eax, op_spd
	jl opponent_turn
	jge your_turn

	opponent_turn:
;At the start of the opponents turn it checks if you have any shields left if yes you'll get asked if you want to use it
		cmp shield, 0
		jg shield_call
		jle continue

		shield_call:
;This asks if you want to use your shield if you enter yes(y) it moves to your turn and you take no damage
;If no the opponent attacks like normally
			mov edx, offset use_shield
			call WriteString
				
			mov ecx, offset 128
			mov edx, offset buffer
			call ReadString
			cmp buffer, "n"
			je continue
			;You can only use the shield once and after using it a message displays saying you're out and lowers the count to 0
			cmp buffer, "y"
			jne error_shield
			sub shield, 1
			mov edx, offset outof
			call WriteString
			call Crlf
			cmp buffer, "y"
			je your_turn

			;If the user enters a statement the program doesn't expect an error message will be displayed then lets the user enter
			;Whether they want to use the shield again
			error_shield:
				mov edx, offset invalid
				call WriteString
				call Crlf
				call shield_call
			
		continue:
		;If the user doesn't use a shield the opponent does a regular attack by comparing its attack to the users defense
		;If the user has lower defense than the opponents defense the difference is dealt as damage
		;Otherwise the opponent only deals 1 point of damage
			mov eax, op_atk
			sub eax, def
			cmp eax, 0
			jg dmg
			jle weak
		dmg:
		;This is called to calculate opponents damage when the opponents attack is higher than users defense
			sub health, eax
			mov edx, offset hit1
			call WriteString
			call WriteInt
			mov edx, offset hit2
			call WriteString
			call Crlf

			jmp lose?
		weak:
		;If the opponents attack is lower than the users defense this is called
			mov edx, offset hit1
			call WriteString
			mov eax, 1
			call WriteInt
			mov edx, offset hit2
			call WriteString
			call Crlf

			sub health, 1
			jmp lose?
	your_turn:
	;At the start of the users turn the program checks if you have any fireballs left
	;If yes then you are asked if you want to use one, if no then it skips to a standard attack
		cmp fireball, 0
		jle standard
		mov edx, offset use_fireball
		call WriteString

		mov ecx, offset 128
		mov edx, offset buffer
		call ReadString
		cmp buffer, "y"
		je fireball_call
		cmp buffer, "n"
		je standard

		mov edx, offset invalid
		call WriteString
		call Crlf
		call your_turn
		fireball_call:
		;When the user uses a fireball it deals 7 damage regardless of the opponents defense
			sub op_health, 7

			mov edx, offset damage
			call WriteString
			mov eax, 7
			call WriteInt
			mov edx, offset damage2
			call WriteString
			call Crlf

			sub fireball, 1
			cmp fireball, 0
			je used_up
			;When the user runs out of fireballs this is called to let the user know they ran out
			used_up:
				mov edx, offset outof
				call WriteString
				call Crlf
			jmp win?
			
		standard:
		;When the user doesn't use a fireball a standard attack is used 
		;Where the damage dealt is the users attack minus the opponents defense 
		;If the users attack is lower than the opponents defense the user only deals 1 point of damage
			mov eax, atk
			sub eax, op_def
			cmp eax, 0
			jle weak2
			jg dmg2
			weak2:
			;When the user has lower attack than opponents defense this is called
				sub op_health, 1
				mov edx, offset damage
				call WriteString
				mov eax, 1
				call WriteInt
				mov edx, offset damage2
				call WriteString
				call Crlf

				jmp win?
			dmg2:
			;When the user has higher attack than opponents defense this is called
				sub op_health, eax
				mov edx, offset damage
				call WriteString
				call WriteInt
				mov edx, offset damage2
				call WriteString
				call Crlf

				jmp win?
		call your_turn
	;The following are used to determine if you win or lose
	;The lose statements are called after the end of the opponents turn and checks to see if the users health is at 0
	;The win statements are called after the end of the users turn and checks if the opponents health is at 0
	win?:
		cmp op_health, 0
		jle win
		call opponent_turn
	lose?:
		cmp health,0 
		jle lose
		call your_turn
	lose:
		mov edx, offset lost
		call WriteString
		exit
	win:
		mov edx, offset won
		call WriteString
		exit
	exit
Fight ENDP
;This procedure displays the rules of the game
Rules PROC
	mov edx, offset rules1
	call WriteString
	call Crlf

	mov edx, offset rules2
	call WriteString
	call Crlf

	mov edx, offset rules3
	call WriteString
	call Crlf
	ret
Rules ENDP
;The following procedures is where you determine your character's stats
;This procedure calls a set of other procedures 
Stats PROC
	mov edx, offset character
	call WriteString
	call Crlf

	call AtkLoop
	mov eax, total_stats

	mov edx, offset remaining
	call WriteString
	call WriteInt
	call Crlf

	call DefLoop
	mov eax, total_stats

	mov edx, offset remaining
	call WriteString
	call WriteInt
	call Crlf

	call SpdLoop
	mov eax, total_stats

	mov edx, offset remaining
	call WriteString
	call WriteInt
	call Crlf
	call Crlf
	ret
Stats ENDP

;This determines how much damage you can deal 
AtkLoop PROC
	mov edx, offset attack
	call WriteString
	call readInt

	mov atk, eax
	;This determines if the stat the user enters is a valid integer
	;If the stat is higher than the stats points available it'll keep looping until you enter a valid value
	mov eax, 18
	sub eax, atk

	cmp eax, 0
	jl AtkLoop 
	mov eax, atk
	;The total stats variable keeps track of how many stat points you have left to use starting at 18
	sub total_stats, eax
	ret
AtkLoop ENDP

;This determines how much each attack is reduced by
DefLoop PROC
	mov edx, offset defense
	call WriteString
	call readInt

	mov def, eax
	mov eax, total_stats
	sub eax, def

	cmp eax, 0
	jl DefLoop
	mov eax, def
	sub total_stats, eax
	ret
DefLoop ENDP

;This stat helps to determine who goes first
SpdLoop PROC
	mov edx, offset speed
	call WriteString
	call readInt

	mov spd, eax

	mov eax, total_stats
	sub eax, spd

	cmp eax, 0
	jl SpdLoop
	mov eax, spd
	sub total_stats, eax
	ret
SpdLoop ENDP
end main
