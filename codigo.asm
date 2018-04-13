.data

	entrada: .asciiz "./entrada.pgm"
	saida:	.asciiz "saida.pgm"
	espaco: .asciiz " "
	finalarquivo: .byte '0'
	buffer_entrada: .word 0
	buffer_saida: .word 0
	vetor: .word 1, 2, 3
	
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
		# ****Falta ver se o barran deu certo
		add $s0, $zero, $zero # contadora
		add $s1, $zero, $zero # comparação
		addi $s2, $zero, 4 # numero de vezes do loop
		addi $t7, $zero, 10 # NL line feed, new line
		add $s4, $zero, $zero
			
		loopDescarte:
			#li buffer_entrada, 0
			slt $s1, $s0, $s2 
			beq $s1, $zero, aqui2
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
			
		aqui2:
		
		# Aqui os números da matriz começam a ser identificados e transformados por meio da fórmula
		addi $s4, $zero, 32 # ascii espaço
		la $t4, vetor # carrego o vetor em $t4

		definicoesLoop:
		
		add $s3, $zero, $zero # quantidade lida
		addi $s5, $zero, 8 # ponteiro para a posição do vetor
		addi $s6, $zero, 8 # constante 8
		
		loopMatriz:
			# Lê o caracter
			move $a0, $t0            # a0 recebe o arquivo aberto
			la   $a1, buffer_entrada # a1 recebe o buffer de entrada
			addi $a2, $zero, 1   # a2 recebe o tamanho maximo
			addi $v0, $zero, 14	 # syscall para ler do arquivo
			syscall
			add $t3, $v0, $zero # quantidade caracteres lidos
			beq $t3, $zero, exit # é o fim do arquivo?
			
			lb $a0, buffer_entrada($zero)
			addi $v0, $zero, 1
			syscall
					
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
				#addi $s3, $s3, 3
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
						lw $s6, 0($t4)
						#mul $s6, $s6, 1
						add $t5, $t5, $s6
						addi $s4, $s4, 1
						addi $s7, $s7, 1
						j somaPosicoes
						
					mult10:
						lw $s6, 4($t4)
						mul $s6, $s6, 10
						add $t5, $t5, $s6
						addi $s4, $s4, 1
						addi $s7, $s7, 1
						j somaPosicoes
						
					mult100:
						lw $s6, 8($t4)
						mul $s6, $s6, 100
						add $t5, $t5, $s6
						addi $s4, $s4, 1
						addi $s7, $s7, 1
						j somaPosicoes
						
			
				formula:
					sub $t5, $t6, $t5
					
					# r1 = t5 / 100 parte inteira
					# rt = t5 - 100
					# r2 = rt / 10 parte inteira
					# r3 = rt - (t7 * 10) isso é unidade
					
					# cada r subtrai 48 e escreve no arquivo sem espaço
			
	
			# Aqui o valor obtido na fórmula é passado para o buffer e é escrito no arquivo de saída	
			sw $t6, buffer_saida # move o buffer para o $t5
			move $a0, $t1	# descriptor que está em t1 vem para a0
			la  $a1, buffer_saida  # buffer de saida é o mesmo
			add  $a2,  $zero, $t3	 # a leitura (syscall) 14 retorna a quantidade de caracteres em v0. Precisa ser passado aqui
			addi $v0, $zero, 15	 # syscall para escrever no arquivo
			syscall
			
			move $a0, $t1
			la $a1, espaco
			addi $v0, $zero, 15
			syscall
			
			add $t5, $zero, $zero
			
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
