# PIC18F4520asm

Programas Exemplos para PIC18F4520 desenvolvido em Assembly no MPLab X v3.40 e simulado no Proteus 8.5.

## [README em Português do Brasil (PT-BR)]

### Programa 1: delayWithCounter

Programa que simula um delay de 1s construido através de contadores, ou seja, sem uso de timer.
  - main_asm.asm contém o código fonte.
  - ./dist/default/production/ contém o .hex, .cof para usar no simulador Proteus.
  - ./Proteus/ contém o arquivo de simulação para o Proteus versão 8+.

### Programa 2: priorityInterrupt

Programa que simula interrupções de alta e baixa prioridade via botão. Cada uma dessas acende um led diferente.
  - priority_interrupt_asm.asm contém o código fonte.
  - ./dist/default/production/ contém o .hex, .cof para usar no simulador Proteus.
  - ./Proteus/ contém o arquivo de simulação para o Proteus versão 8+.