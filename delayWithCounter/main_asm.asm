; @author PEDRO AUGUSTO DI FRANCIA ROSSO (/pedroaugust0)

#include <p18f4520.inc>
    
;Configuracoes 
CONFIG OSC	= XT  ;Oscilador para 4Mhz
CONFIG WDT	= OFF ;Nao tem watch dog timer
CONFIG PBADEN	= OFF ;Portas do PORTB em digitais
		
		
;Declaração dos Registradores de Uso Geral (aka Variveis de Memoria)
cblock			0x0300	;Area não utilizada no pic (visto no datasheet)
    TEMPO0			;Variavel para delay 1
    TEMPO1			;Variavel para delay 2
    TEMPO2			;Variavel para delay 3
endc				;Final das declaracoes
    
;Vetor de RESET
VETOR_RESET	CODE	0x0000	;Configura do endereco de reset
		goto	SETUP	;Vai para as configuracoes
		
;Setup 
SETUP
		movlw	B'00000000' ;Configurando portas para Output
		movwf	TRISC	    ;Seta todas as portas do PORTC para Output
		movlw	B'00000000' ;Configura para zero
		movwf	PORTC	    ;Inicia LED apagado
		
;Programa Principal
LOOP		btg	PORTC, RC0  ;Inverte o valor do bit 0 do PORTC
    		call	DELAY	    ;Chama a funcao delay
		goto	LOOP	    ;Loop Infinito
		
;Funcao Delay
;--*
;	ciclo de maquina = 1/1Mhz = 1us
;	delay 1s = 1000000 de ciclos
;       cada comparacao = 1 ciclo de maquina	
;
;	conta => 2 + 4 = 6 (conf tempo0 e call e return); 
;	1ms   => 4 + 250 + 250 + 2*250 = 1004
;	250ms => 250+ 2*250 +2*250 = 1250 + 250*1004 = 252.25*10e3		
;	1s    => 2 + 4*252.25*10e3 = 1.009*10e6 + 6 = 1.009006*10e6 = aprox 1s;
;--*
DELAY    	
		movlw	0x03	;Carrega valor 4 decimal
		movwf	TEMPO0	;Seta contador TEMPO0 = 4; -> 2 ciclo
;Conta 1s			
C_1s
		movlw	0xFA	    ;Carrega valor 250 decimal
		movwf	TEMPO1	    ;Seta contador TEMPO2 = 249 -> 2 ciclo
;Conta 250ms
C_250ms		
		movlw	0xFA	    ;Carrega valor 250 decimal
		movwf	TEMPO2	    ;Seta contador TEMPO2 = 250  -> 2 ciclo
;Conta 1ms
C_1ms	
		nop		    ;Gasta 1 ciclo de maquina	-> 1 ciclo * 250
		decfsz	TEMPO2, F   ;Decrementa contador TEMPO1, pula se valor = 0, -> 1 ciclo* 250 
		goto	C_1ms	    ;Volta para C_1ms 	     -> 2 ciclo * 250 
				
		decfsz	TEMPO1, F   ;Decrementa contador TEMPO1, pula se valor = 0	-> 1 ciclo
		goto	C_250ms	    ;Volta para C_250ms	    -> 2ciclo
		
		decfsz	TEMPO0, F   ;Decrementa contador TEMPO1, pula se valor = 0  -> 1 ciclo
		goto	C_1s	    ;Volta para C_1s - 2 ciclo
		return		    ;Retorna ao loop - 4ciclo de maquina (call e return) 
		
		
		end	;Fim de programa