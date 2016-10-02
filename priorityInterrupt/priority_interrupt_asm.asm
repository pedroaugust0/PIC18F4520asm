; @author PEDRO AUGUSTO DI FRANCIA ROSSO (/pedroaugust0)
; Programa para tratar interrup��es de alta prioridade e baixa prioridade

#include <p18f4520.inc>
		
; Configura��es 
CONFIG  OSC = XT	    ; Oscillator Selection bits (XT oscillator)
CONFIG  WDT = OFF	    ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
CONFIG	PBADEN = OFF	    ; Desabilita funcao anal�gica do PORTB
		
; Declara��o dos Registradores de Uso Geral (aka Vari�veis de Mem�ria)
cblock			0x0300	; �rea n�o utilizada no pic (visto no datasheet)
    WRK_TEMP			; Work
    STA_TEMP			; Status
    BSR_TEMP			; Bank Select Register - para saber qual banco de memoria est� sendo usando 
endc				; Final das definicoes 
		
; Vetor de origem do programa (reset)
VETOR_RESET	CODE	0x0000	; Configura��o do endere�o de reset
		goto	SETUP
		
; Vetor de interup��o de alta prioridade
Vetor_High_P	CODE	0x0008	; Configura��o do endere�o da interrup��o da alta prioridade
		goto	SAVE_INT  ; Vai para onde salva contexto
		
Vetor_Low_P	CODE	0x0018	; Configura��o do endere�o da interrup��o de baixa prioridade
		goto	SAVE_INT  ; Vai para onde salva contexto

; Programa Principal
SETUP
		movlw	B'00000011' ; Configura RBO e RB1 como entrada e o resto com sa�da (carrega no W)
		movwf	TRISB	    ; Seta PORTB como entrada e saida
		 
		movlw	B'00000000' ; Configura PORTC como sa�da (carrega no W)
		movwf	TRISC	    ; Seta PORTC como sa�da 
		
		; Configura��o da interrup��o
		bsf	INTCON, INT0IE	    ; Ativa interrup��o em RB0
		bcf	INTCON, INT0IF	    ; Seta flag da interup��o 0 em 0
		bsf	RCON, IPEN	    ; Ativa prioridade de alta e baixa prioridade
		bsf	INTCON, GIEH	    ; Ativa interrup��es de alta prioridade
		bsf	INTCON, GIEL	    ; Ativa interrup��es de baixa prioridade
		bcf	INTCON2, INTEDG0	    ; Seleciona a interrup��o � na borda de descida INT0
		bcf	INTCON2, INTEDG1	    ; Seleciona a interrup��o � na borda de descida INT1
		bcf	INTCON2, RBPU	    ; Ativa resistores de Pull UP do PORTB
		bcf	INTCON3, INT1P	    ; Interup��o de RB1 como baixa prioridade
		bsf	INTCON3, INT1IE	    ; Ativa interrup��o em RB1
		bcf	INTCON3, INT1IF	    ; Seta flag da interup��o 1 em 0
		
		
		
MAIN
		goto	$   ; Fica no la�o infinito
		
; Entrada da Interrup��o 0
SAVE_INT	
		movwf	WRK_TEMP	    ; Copia o conte�do de W para WRK_TEMP ; n�o precisa se movff porque j� tem o movw (w de work)
		movff	STATUS, STA_TEMP	    ; Copia o conte�do Status para STA_TEMP
		movff	BSR, BSR_TEMP	    ; Copia o conte�do BSR pra BSR_TEMP
		btfsc	INTCON, INT0IF	    ; Testa o bit e for zero pula
		goto	TRATA_INT_0	    ; Vai para trata interrup��o 0
		goto	TRATA_INT_1	    ; Vai para trata interrup��o 1
	
; Sa�da da Interrup��o 0
RESTORE_INT	
		movff	BSR_TEMP, BSR	    ; Copia o conte�do de BSR_TEMP para BSR
		movf	WRK_TEMP, W	    ; Copia o conte�do de WRK_TEMP para W
		movff	STA_TEMP, STATUS       ; Copia o conte�do de STA_TEMP para STATUS
		bcf	INTCON, INT0IF	    ; Limpa flag, possibilita nova interrup��o 0
		bcf	INTCON3, INT1IF	    ; Limpa flag, possibilita nova interrup��o 1
		retfie			    ; Retorna da Interrup��o
		
; Tratador da Interrup��o O
TRATA_INT_0
		btg	PORTC, RC0	    ; Inverte o valor do bit 0 do PORTC
		goto	RESTORE_INT	    ; Restaura Contexto
		
; Tratado da Interrup��o 1
TRATA_INT_1
		btg	PORTC, RC1	    ; Inverte o valor do bit 1 do PORTC
		goto	RESTORE_INT	    ; Restaura Contexto
		
		end	    ; Fim de Programa