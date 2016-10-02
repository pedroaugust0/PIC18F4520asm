; @author PEDRO AUGUSTO DI FRANCIA ROSSO (/pedroaugust0)
; Programa para tratar interrupções de alta prioridade e baixa prioridade

#include <p18f4520.inc>
		
; Configurações 
CONFIG  OSC = XT	    ; Oscillator Selection bits (XT oscillator)
CONFIG  WDT = OFF	    ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
CONFIG	PBADEN = OFF	    ; Desabilita funcao analógica do PORTB
		
; Declaração dos Registradores de Uso Geral (aka Variáveis de Memória)
cblock			0x0300	; área não utilizada no pic (visto no datasheet)
    WRK_TEMP			; Work
    STA_TEMP			; Status
    BSR_TEMP			; Bank Select Register - para saber qual banco de memoria está sendo usando 
endc				; Final das definicoes 
		
; Vetor de origem do programa (reset)
VETOR_RESET	CODE	0x0000	; Configuração do endereço de reset
		goto	SETUP
		
; Vetor de interupção de alta prioridade
Vetor_High_P	CODE	0x0008	; Configuração do endereço da interrupção da alta prioridade
		goto	SAVE_INT  ; Vai para onde salva contexto
		
Vetor_Low_P	CODE	0x0018	; Configuração do endereço da interrupção de baixa prioridade
		goto	SAVE_INT  ; Vai para onde salva contexto

; Programa Principal
SETUP
		movlw	B'00000011' ; Configura RBO e RB1 como entrada e o resto com saída (carrega no W)
		movwf	TRISB	    ; Seta PORTB como entrada e saida
		 
		movlw	B'00000000' ; Configura PORTC como saída (carrega no W)
		movwf	TRISC	    ; Seta PORTC como saída 
		
		; Configuração da interrupção
		bsf	INTCON, INT0IE	    ; Ativa interrupção em RB0
		bcf	INTCON, INT0IF	    ; Seta flag da interupção 0 em 0
		bsf	RCON, IPEN	    ; Ativa prioridade de alta e baixa prioridade
		bsf	INTCON, GIEH	    ; Ativa interrupções de alta prioridade
		bsf	INTCON, GIEL	    ; Ativa interrupções de baixa prioridade
		bcf	INTCON2, INTEDG0	    ; Seleciona a interrupção é na borda de descida INT0
		bcf	INTCON2, INTEDG1	    ; Seleciona a interrupção é na borda de descida INT1
		bcf	INTCON2, RBPU	    ; Ativa resistores de Pull UP do PORTB
		bcf	INTCON3, INT1P	    ; Interupção de RB1 como baixa prioridade
		bsf	INTCON3, INT1IE	    ; Ativa interrupção em RB1
		bcf	INTCON3, INT1IF	    ; Seta flag da interupção 1 em 0
		
		
		
MAIN
		goto	$   ; Fica no laço infinito
		
; Entrada da Interrupção 0
SAVE_INT	
		movwf	WRK_TEMP	    ; Copia o conteúdo de W para WRK_TEMP ; não precisa se movff porque já tem o movw (w de work)
		movff	STATUS, STA_TEMP	    ; Copia o conteúdo Status para STA_TEMP
		movff	BSR, BSR_TEMP	    ; Copia o conteúdo BSR pra BSR_TEMP
		btfsc	INTCON, INT0IF	    ; Testa o bit e for zero pula
		goto	TRATA_INT_0	    ; Vai para trata interrupção 0
		goto	TRATA_INT_1	    ; Vai para trata interrupção 1
	
; Saída da Interrupção 0
RESTORE_INT	
		movff	BSR_TEMP, BSR	    ; Copia o conteúdo de BSR_TEMP para BSR
		movf	WRK_TEMP, W	    ; Copia o conteúdo de WRK_TEMP para W
		movff	STA_TEMP, STATUS       ; Copia o conteúdo de STA_TEMP para STATUS
		bcf	INTCON, INT0IF	    ; Limpa flag, possibilita nova interrupção 0
		bcf	INTCON3, INT1IF	    ; Limpa flag, possibilita nova interrupção 1
		retfie			    ; Retorna da Interrupção
		
; Tratador da Interrupção O
TRATA_INT_0
		btg	PORTC, RC0	    ; Inverte o valor do bit 0 do PORTC
		goto	RESTORE_INT	    ; Restaura Contexto
		
; Tratado da Interrupção 1
TRATA_INT_1
		btg	PORTC, RC1	    ; Inverte o valor do bit 1 do PORTC
		goto	RESTORE_INT	    ; Restaura Contexto
		
		end	    ; Fim de Programa