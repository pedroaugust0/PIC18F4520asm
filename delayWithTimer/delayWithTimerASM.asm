;@author PEDRO AUGUSTO DI FRANCIA ROSSO
    
#include <p18f4520.inc>
    
;Configuracoes 
CONFIG OSC	= XT  ;Oscilador para 4Mhz
CONFIG WDT	= OFF ;Nao tem watch dog timer
CONFIG PBADEN	= OFF ;Portas do PORTB em digitais
    
;Declaração dos Registradores de Uso Geral (aka Variveis de Memoria)
cblock			0x0300	;Area não utilizada no pic (visto no datasheet)
    CONTADOR			;Variavel para delay do TIMER0
endc			
		
;Vetor de RESET
VETOR_RESET	CODE	0x0000	;Configura do endereco de reset
		goto	SETUP	;Vai para as configuracoes

;Vetor de Interrupcao
ISR_TMR0	CODE	0x0008		;Define indereco da interrupcao
		goto	TRATA_TMR0	;Vai para onde trata a Interrupcao
		
;Trata a interrupcao
TRATA_TMR0
		decfsz	CONTADOR, F	;Decrementa contador TEMPO1, pula se valor = 0
		goto	VOLTA_TMR0	;Vai para onde retorna da interrupcao
		
		movlw	0x0F		;Configura Contador para 5 em decimal
		movwf	CONTADOR	;Seta Contador em 5
		
		btg	PORTC, RC0	;Inverte o valor do bit 0 do PORTC
		
		
;Volta da Interrupcao
VOLTA_TMR0	
		bcf	INTCON, TMR0IF	;Limpa flag da Interrupcao de TMR0
		retfie			;Retorna da Interrupcao
	
		
;Setup
SETUP
		movlw	B'00000000' ;Configura as portas para Output
		movwf	TRISC	    ;Seta PORTC como Output
		clrf	PORTC	    ;Zera PORTC
		;Configura 1 contador
		movlw	0x0F		;Configura Contador para 5 em decimal
		movwf	CONTADOR	;Seta Contador em 5
		;Configuracoes do TMR0
		bsf	INTCON, GIE	;Habilita Interrupcoes Globais
		bsf	INTCON, TMR0IE	;Habilita Interrupcao no TIMER0
		bcf	INTCON, TMR0IF	;Limpa Flag da Interrupcao no TIMER0
		bsf	INTCON2, TMR0IP	;Alta Prioridades
		movlw	B'11000111'	;Configura TIMER0
		movwf	T0CON
		;bit7	TMR0ON	;1 = Habilita TIMER0
		;bit6	T08BIT	;1 = TIMER0 de 8 bits
		;bit5	T0CS	;0 = Usa clock interno
		;bit4	T0SE	;Borda do timer0, nao usado, porque eh clock interno
		;bit3	PSA	;0 = Informa que tem Preescaler 	
		;bit2	T0PS2	;Seta Valor 1
		;bit1	T0PS1	;Seta Valor 1
		;bit0	T0PS0	;Seta Valor 1 -> os 3 comandos seta preescaler em 1:256
		

;Programa Princiapl
LOOP
		goto	LOOP		;Fica em Loop Infinito
		
		end			;Fim de Programa