.data

	entrada: .asciiz "./entrada.pgm"
	saida:	.asciiz "saida.pgm"
	barran: .asciiz "\n"
	buffer_entrada: .word
	buffer_saida: .word
	vetor: .word 0, 0, 0
	
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
		
		
		
			# ler primeira e a segunda linha e salvando no arquivo
			# fazer isso duas vezes dentro de um loop até o \n
			
			# ****Falta ver se o barran deu certo
			
		add $s0, $zero, $zero # contadora
		add $s1, $zero, $zero # comparação
		addi $s2, $zero, 2 # numero de vezes do loop
		addi $s3, $zero, 3 # end of line
			
		loopDescarte:
			slt $s1, $s0, $s2 
			beq $s1, $zero, aqui2
				loopFimLinha:
					move $a0, $t0
					la   $a1, buffer_entrada
					addi $a2, $zero, 1
					addi $v0, $zero, 14
					syscall
					add $t3, $v0, $zero

					beq $a1, $s3, aqui # é o fim do arquivo?
					j loopFimLinha
					
					aqui:
						# falta resolver: nao esta escrevendo tudo no arquivo de saida
						move $a0, $t1
						la  $a1, buffer_entrada
						add  $a2,  $zero, $t3
						addi $v0, $zero, 15
						syscall
			
						addi $s0, $s0, 1
						j loopDescarte
			
		aqui2:
		
		add $s0, $zero, $zero # contadora
		add $s1, $zero, $zero # comparação
		add $s2, $zero, $zero # numero de vezes do loop
		add $s3, $zero, $zero # quantidade lida
		addi $s4, $zero, 32 # ascii espaço
		
		
		# aqui tem que ler o tamanho do arquivo e colocar no $s2
		
		la $t4, matriz # provavelmente isso ta errado
		
		loopMatriz:
			slt $s1, $s0, $s2
			beq $s1, $zero, saida
			stringInt:
				#to lendo 1 por 1 pq não sei mais o que fazer
				move $a0, $t0            # a0 recebe o arquivo aberto
				la   $a1, buffer_entrada # a1 recebe o buffer de entrada
				addi $a2, $zero, 1   # a2 recebe o tamanho maximo
				addi $v0, $zero, 14	 # syscall para ler do arquivo
				syscall
				add $t3, $v0, $zero # quantidade caracteres lidos
				
				lb $a1, buffer_entrada($zero) # carregando o primeiro byte do buffer para a1
				bne $a1, $s4, naoSoma1
				addi $s3, $s3, 1
				naoSoma1:
					addi $a1, $a1, -48
					sw $a1,8($t4) # colocando a1 na terceira posição do vetor
				
				addi $s3, $s3, 4
				lb $a1, buffer_entrada($s3) # carregando o segundo byte do buffer para a1
				bne $a1, $s4, naoSoma2
				addi $s3, $s3, 1
				
				j vaiPraCa
				naoSoma2:
					addi $a1, $a1, -48
					sw $a1,4($t4) # colocando a1 na segunda posição do vetor
					
				vaiPraCa:
				
				addi $s3, $s3, 4
				lb $a1, buffer_entrada($s3) # carregando o terceiro byte do buffer para a1
				bne $a1, $s4, naoSoma3
				addi $s3, $s3, 1
				naoSoma3:
					addi $a1, $a1, -48
					sw $a1,0($t4) # colocando a1 na primeira posição do vetor
				
				
				addi $s4, $zero, 2 # variavel contadora
				add $s5, $zero, $zero # flag de comparacao
				addi $s3, $s3, -3
				add $s5, $zero, $zero
				
				# falta termina aqui
				somaPosicoes:
					slt $s5, $s3, $s4
					beq $s5, $zero, exit
						beq
						lw $s6, 0($t4)
			
			
			# transformar string em inteiro 
				# salvar no vetor com o numero ao contrario, de trás pra frente, ex se for 253 salvar 352, usar loop
				# usando lb (load byte) contando os espaços (olhar a folha)
				# a partir disso subtrair 48 de cada numero encontrado
				# multiplicar a primeira posição por 1
				# multiplicar a segunda posição por 10
				# multiplicar a terceira posição por 100
				# ir somando em um registrador ex t4
		
				#ex:
				# lb $t4, buffer_entrada($zero) # carregando um byte do buffer
				# addi $t4, $t4, -48 # transforma a string em um numero
		
			# ler no maximo 3 caracteres por vez, pois no maximo 255
			
				# le arquivo
			
				move $a0, $t0            # a0 recebe o arquivo aberto
				la   $a1, buffer_entrada # a1 recebe o buffer de entrada
				addi $a2, $zero, 3   # a2 recebe o tamanho maximo
			
				# transformar string em inteiro (processo da folha) usando lb
			
				addi $v0, $zero, 14	 # syscall para ler do arquivo
				syscall
				add $t3, $v0, $zero # quantidade caracteres lidos
				
				# aplicar a formula: soma = -soma+255
				# levar a soma para o buffer
		
				# escreve 
				
				move $a0, $t1		 # descriptor que está em t1 vem para a0
				la  $a1, buffer_saida  # buffer de saida é o mesmo
				add  $a2,  $zero, $t3	 # a leitura (syscall) 14 retorna a quantidade de caracteres em v0. Precisa ser passado aqui
				addi $v0, $zero, 15	 # syscall para escrever no arquivo
				syscall
			
				addi $s0, $s0, 1
				j loopMatriz
	
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
		
