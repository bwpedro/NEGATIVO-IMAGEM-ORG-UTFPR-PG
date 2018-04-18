.data

	entrada: .asciiz "./fas.pgm"
	saida:	.asciiz "saida.pgm"
	espaco: .asciiz " "
	finalarquivo: .byte '0'
	buffer_entrada: .word
	buffer_saida: .word
	vetor: .word 0, 0, 0, 0
	
.text

	main:
		jal le_arquivo
		jal exit	
	
	le_arquivo:
		# empilha
		add $sp, $sp, -20
		sw $ra, 16($sp)
		sw $t0, 12($sp)
		sw $a0, 8($sp)
		sw $a1, 4($sp)
		sw $a2, 0($sp)
	
	
		# abre arquivo de leitura
		la   $a0, entrada      # a0 recebe o nome do arquivo
		addi $a1, $zero, 0     # a1 e a2 recebem o valor para leitura
		addi $a2, $zero, 0
		addi $v0, $zero, 13    # código do syscall para abertura de arquivo
		syscall
		move $t0, $v0	       # salva o pointer do arquivo aberto
	
		# abre arquivo de saida
		la   $a0, saida        # a0 recebe o nome do arquivo
		addi $a1, $zero, 1     # a1 recebe o valor para escrita
		addi $a2, $zero, 0
		addi $v0, $zero, 13    # código do syscall para abertura de arquivo
		syscall
		move $t1, $v0	       # salva o pointer do arquivo aberto
			
		# Aqui lê a primeira, a segunda e a terceira linha do arquivo de entrada e salva no arquivo de saída
		add $s0, $zero, $zero # contadora
		add $s1, $zero, $zero # comparação
		addi $s2, $zero, 4 # numero de vezes do loop
		addi $t7, $zero, 10 # NL line feed, new line
		add $s4, $zero, $zero
			
		loopDescarte:
			slt $s1, $s0, $s2 
			beq $s1, $zero, definicoesLoop
				loopFimLinha:
				
					#le
					move $a0, $t0
					la   $a1, buffer_entrada
					addi $a2, $zero, 1
					addi $v0, $zero, 14
					syscall
					add $t3, $v0, $zero
					
					#escreve
					move $a0, $t1
					la  $a1, buffer_entrada
					add  $a2,  $zero, $t3
					addi $v0, $zero, 15
					syscall
					
					lb $s4, buffer_entrada($zero)
					
					beq $s4, $t7, fimDaLinha # é o fim da linha?
					
					j loopFimLinha
					
					fimDaLinha:
						addi $s0, $s0, 1
						j loopDescarte
						
						
		# Aqui os números da matriz começam a ser identificados e transformados por meio da fórmula
		definicoesLoop:
		addi $s4, $zero, 32 # ascii espaço
		la $t4, vetor # carrego o vetor em $t4
		add $s3, $zero, $zero # quantidade lida
		addi $s5, $zero, 12 # ponteiro para a posição do vetor
		addi $s6, $zero, 12 # constante 8
		
		loopMatriz:
			# Lê o caracter
			move $a0, $t0            # a0 recebe o arquivo aberto
			la   $a1, buffer_entrada # a1 recebe o buffer de entrada
			addi $a2, $zero, 1   # a2 recebe o tamanho maximo
			addi $v0, $zero, 14	 # syscall para ler do arquivo
			syscall
			add $t3, $v0, $zero # quantidade caracteres lidos
			beq $t3, $zero, exit # é o fim do arquivo?
					
			# Transforma o caracter lido em inteiro
			lb $a1, buffer_entrada($zero)
			beq $a1, $s4, ehEspaco # é um espaço?
			beq $a1, $t7, ehEspaco # é \n? 
			addi $s3, $s3, 1
			addi $a1, $a1, -48
			
			# Insiro o caracter lido na posição do vetor
			add $s5, $t4, $s5
			sw $a1,0($s5)
			addi $s6, $s6, -4
			add $s5, $s6, $zero
			
			j loopMatriz
			
			# Se for um espaço, então o número inteiro já foi lido
			ehEspaco:
				addi $s0, $zero, 1 # constante 1
				addi $s1, $zero, 2 # constante 2
				addi $s2, $zero, 3 # constante 3
				sub $s4, $s2, $s3 # loop começa com esse valor (3-quantidadeLida)
				add $s5, $zero, $zero # flag de comparacao
				add $s6, $zero, $zero #lugar onde vai ser carregado as posições do vetor
				add $s7, $zero, $zero # cont
				
				add $t5, $zero, $zero # soma de tudo (x da fórmula)
				addi $t6, $zero, 255 # constante 255
				
			somaPosicoes:
				beq $s2, $s4, formula
				beq $s7, $zero, mult1
				beq $s7, $s0, mult10
				beq $s7, $s1, mult100
				
						
					mult1:
						lw $s6, 4($t4)	
						add $t5, $t5, $s6
						addi $s4, $s4, 1
						addi $s7, $s7, 1
						j somaPosicoes
						
					mult10:
						lw $s6, 8($t4)
						mul $s6, $s6, 10
						add $t5, $t5, $s6
						addi $s4, $s4, 1
						addi $s7, $s7, 1
						j somaPosicoes
						
					mult100:
						lw $s6, 12($t4)
						mul $s6, $s6, 100
						add $t5, $t5, $s6
						addi $s4, $s4, 1
						addi $s7, $s7, 1
						j somaPosicoes
						
			
				formula:
					sub $t5, $t6, $t5
					
				
				
				addi $s6, $zero, 10
				slt $s0, $t5, $s6
				beq $s3, $s0, escreveQuandoApenasUm
				
				addi $s6, $zero, 100
				beq $s3, $s0, divisaopor10
					
				divisaopor100:
					add $s5, $zero, $zero # cont
					addi $s7, $zero, 100
					add $s3, $t5, $zero # numero que diminui
					
					voltaLoop100:
					add $s6, $zero, $zero # flag de comparação
					slt $s6, $s7, $s3
					beq $s6, $zero, escreveArquivo100

					loopDivide100:
						addi $s5, $s5, 1
						sub $s3, $s3, $s7
						j voltaLoop100
					
					#Escreve centena no arquivo
					escreveArquivo100:
					addi $s5, $s5, 48
					sw $s5, buffer_saida 					
					move $a0, $t1						
					la  $a1, buffer_saida  					
					add  $a2,  $zero, $t3	 				
					addi $v0, $zero, 15	 			
					syscall
					
					sub $s0, $t5, $s7
				
				divisaopor10:
					add $s5, $zero, $zero # cont
					addi $s7, $zero, 10
					add $s3, $s0, $zero # numero que diminui
					
					voltaLoop10:
					add $s6, $zero, $zero
					slt $s6, $s7, $s3
					beq $s6, $zero, escreveArquivo10

					loopDivide10:
						addi $s5, $s5, 1
						sub $s3, $s3, $s7
						j voltaLoop10
					
					#Escreve dezena no arquivo
					escreveArquivo10:
					addi $s5, $s5, 48
					sw $s5, buffer_saida 					
					move $a0, $t1						
					la  $a1, buffer_saida  					
					add  $a2,  $zero, $t3	 				
					addi $v0, $zero, 15	 			
					syscall	
					addi $s5, $s5, -48
					
					
				# trata unidade	
				
				mul $s5, $s5, 10
				sub $s0, $s0, $s5


				#Escreve unidade no arquivo
				addi $s0, $s0, 48
				sw $s0, buffer_saida 					
				move $a0, $t1						
				la  $a1, buffer_saida  					
				add  $a2,  $zero, $t3	 				
				addi $v0, $zero, 15	 			
				syscall
				j naoLoop
				
				escreveQuandoApenasUm:
				addi $t5, $t5, 48
				sw $t5, buffer_saida 					
				move $a0, $t1						
				la  $a1, buffer_saida  					
				add  $a2,  $zero, $t3	 				
				addi $v0, $zero, 15	 			
				syscall
				addi $t5, $zero, 48
			
			naoLoop:
			
			add $t5, $zero, $zero
			sw $t5, 4($t4)
			sw $t5, 8($t4)
			sw $t5, 12($t4)
			
			move $a0, $t1
			la $a1, espaco
			addi $v0, $zero, 15
			syscall
			
				
			j definicoesLoop
			
		# desempilha registradores
		sw $a2, 0($sp)
		sw $a1, 4($sp)
		sw $a0, 8($sp)
		sw $t0, 12($sp)
		sw $ra, 16($sp)
		addi $sp, $sp, 20
		
		# fecha arquivos
		move $a0, $t0
		addi $v0, $zero, 16
		syscall
	
		move $a0, $t1
		addi $v0, $zero, 16
		syscall
	
		jr $ra
		
	
	exit:
		
		addi $v0, $zero, 10  # syscall para encerrar o programa
		syscall
