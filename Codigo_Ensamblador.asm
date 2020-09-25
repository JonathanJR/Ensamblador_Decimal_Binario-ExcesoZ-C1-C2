.MODEL small 						;Modelo de programación
.STACK 100h							;Reserva de espacio para la pila
.DATA								;Segmento de datos, declaracion de variables
	cadena db 5,0,0,0,0,0,0			;Reserva de 7 posiciones de memoria para guardar la cadena que pedimos por teclado, el ultimo 0 es para el intro
	peso db 8,4,2,1  				;Reserva de 4 posiciones de memoria para 4 datos tipo byte y los inicializo a 8, 4, 2 y 1 - Para guardar los pesos asociados a cada posicion de la cadena
	valor_decimal_binario db 0		;Reserva de una posicion de memoria para un dato tipo byte y la inicializo a 0 - Aqui guardaremos el valor decimal binario
	valor_complemento_1 db 15		;Reserva de una posicion de memoria para un dato tipo byte y la inicializo a 15 - Valor del complemento a 1
	valor_complemento_2 db 16		;Reserva de una posicion de memoria para un dato tipo byte y la inicializo a 16 - Valor del complemento a 2
	valor_exceso_z db 8				;Reserva de una posicion de memoria para un dato tipo byte y la inicializo a 8 - Valor del exceso Z

.CODE 								;Segmento de codigo
     MOV AX,SEG cadena 				;Inicializamos el registro segmento de datos (cadena es la direccion de memoria donde esta el primer dato-
									;-definida con 20bits, segmento (16) y desplazamiento(4))
									;-al poner SEG indicamos que solo queremos la zona de segmento
     MOV DS,AX						;Inicializo DS llevando un valor (DataSegment)
	
    MOV DX, OFFSET cadena   ;Indica la posicion de memoria a partir de la que se almacenara la CADENA
    MOV AH, 0Ah 			;Codigo de funcion
    INT 21h
                
    ;DECIMAL_BINARIO
    mov si,0				;Ponemos el indice a cero
    
    bucle:
    mov al, cadena[si+2]  	;Ponemos en al el contenido de la cadena para esa posicion [si+2]
    sub al, 48  			;Le restamos 48 para pasarlo a binario natural
    mul peso[si]			;Multiplicamos por el peso asociado a esa casilla de la cadena
    add bl, al				;En bl vamos acumulando las cantidades obtenidas
    cmp si, 3 				;Comparo si el valor del indice llega a 3
    inc si					;Incremento el indice
    jbe bucle   			;Comparacion jbe -> menor o igual que
    
    mov valor_decimal_binario, bl	;Guardo la solucion en su variable correspondiente

    ;EXCESO_Z                       ;X-(2^(n-1))
    mov cl, valor_decimal_binario	;Utilizamos el registro cl para trabajar con el valor de decimal binario (para no modificar el valor de decimal_binario
    cmp bl, 8						;Comparo si el valor es mayor o igual a 8
    jl excesoz						;si es menor salto (porque la solucion va a ser negativa) a excesoz para calcular y mostrar el numero negativo
    
    ;Exceso Z Positivo          ;He llegado aqui porque decimal_binario = cl >= 8
    sub cl, valor_exceso_z   	;decimal_binario-(2^(4-1))= cl - 8
    mov valor_exceso_z, cl   	;Guardo la solucion en su variable correspondiente
    
    ;Muestro exceso z positivo
    add valor_exceso_z, 48		;Le sumamos 48 para pasarlo a ascii
    MOV DX, 0B801h 				;Direccion de la memoria de video en modo texto
    MOV ES,DX					;La pongo en el registro ES encargado de pintar
								;Pintando caracteres...
    MOV ES:[0], 'E'
    MOV ES:[2], 'Z'
    MOV ES:[4], ':'
    MOV ES:[6], ' '
    
    MOV DH,00001111b			;Fondo negro y letras en color blanco
    MOV DL,valor_exceso_z		;Preparo para mostrar el valor de exceso z
    MOV ES:[8],DX				;Lo muestro en pantalla en la posicion indicada entre corchetes
    
    jmp signo					;Salto a signo para no entrar en exceso z negativo puesto que ha sido positivo
    
    ;Exceso Z Negativo          ;He llegado aqui porque decimal_binario = cl < 7
    excesoz:                   
    sub valor_exceso_z, cl      ;Guardo en la variable de exceso z el valor 8 - cl
    
    ;Muestro exceso z negativo
    add valor_exceso_z, 48		;Le sumamos 48 para pasarlo a ascii
    MOV DX, 0B801h 				;Direccion de la memoria de video en modo texto
    MOV ES,DX					;La pongo en el registro ES encargado de pintar
    
    MOV ES:[0], 'E'				;Pintando caracteres...
    MOV ES:[2], 'Z'
    MOV ES:[4], ':'
    
    MOV DH,00001111b			;Fondo negro y letras en color blanco
    MOV DL,45					;Signo - en ascii
    MOV ES:[6],DX				;Muestro en pantalla el signo -
    
    MOV DH,00001111b			;Fondo negro y letras en color blanco
    MOV DL,valor_exceso_z		;Preparo para mostrar el valor de exceso z
    MOV ES:[8],DX				;Muestro en pantalla el valor de exceso z
    
    ;Vamos a comprobar el signo con el primer bit de la cadena
    signo:                 ;Salto para no entrar en Execeso z negativo
    cmp cadena[2], 48
    je positivo            ;Puesto que el primer bit es un 0, el resultado
                           ;para binario decimal, c1 y c2 es el mismo
   
    
    ;COMPLEMENTO_1					;Si he llegado aqui es porque el signo es negativo
    sub valor_complemento_1, bl		;Guardo en valor_complemento_1 el resultado de restar 15 - decimal_binario
  
    
    ;COMPLEMENTO_2             
    sub valor_complemento_2, bl 	;Guardo en valor_complemento_1 el resultado de restar 16 - decimal_binario
    
    jmp negativo					;Salto para mostrar la solucion en negativo
    
    ;Mostrar positivo				;Si he llegado aqui es porque hay que mostrar c1 y c2 en postivo
    positivo:    
    
    add valor_decimal_binario, 48	;Le sumamos 48 para pasarlo a ascii
  
    MOV DX, 0B801h 					;Direccion de la memoria de video en modo texto
    MOV ES,DX 						;La pongo en el registro ES encargado de pintar
    
    ;Muestro c1 y c2 que son iguales
    MOV ES:[10], ','				;Pintando caracteres...
    MOV ES:[12], ' '
    MOV ES:[14], 'C'
    MOV ES:[16], '1'
    MOV ES:[18], ' '
    MOV ES:[20], 'Y'
    MOV ES:[22], ' '
    MOV ES:[24], 'C'
    MOV ES:[26], '2'
    MOV ES:[28], ':'
    MOV ES:[30], ' ' 
  
    MOV DH,00001111b				;Fondo negro y letras en color blanco
    MOV DL,valor_decimal_binario	;Preparo para mostrar el valor decimal_binario que es igual a c1 y c2 en este caso
    MOV ES:[32],DX					;Muestro en pantalla el valor decimal_binario
	
    jmp salir						;Siguiendo este camino el programa se acaba aqui por tanto salto para terminar la ejecucion
          
    ;Mostrar negativo  				;Si he llegado aqui es porque los complementos son negativos
    negativo:
    add valor_complemento_1, 48		;Le sumamos 48 para pasarlo a ascii
    add valor_complemento_2, 48 	;Le sumamos 48 para pasarlo a ascii
    
    MOV DX, 0B801h 					;Direccion de la memoria de video en modo texto
    MOV ES,DX  						;La pongo en el registro ES encargado de pintar
    
    ;Muestro C1
    
    MOV ES:[10], ','				;Pintando caracteres...
    MOV ES:[12], ' '
    MOV ES:[14], 'C'
    MOV ES:[16], '1'
    MOV ES:[18], ':'
    MOV ES:[20], ' '
    
    MOV DH,00001111b				;Fondo negro y letras en color blanco
    MOV DL,45						;Signo - en ascii
    MOV ES:[22],DX					;Muestro en pantalla el signo -
    
    MOV DH,00001111b				;Fondo negro y letras en color blanco
    MOV DL,valor_complemento_1		;Preparo para mostrar el valor complemento a 1
    MOV ES:[24],DX 					;Muestro en pantalla el valor complemento a 1
    MOV ES:[26], ' '				;Pintando caracteres...
    MOV ES:[28], 'Y'
    MOV ES:[30], ' ' 
    
    ;Muestro C2
    
    MOV ES:[32], 'C'				;Pintando caracteres...
    MOV ES:[34], '2'
    MOV ES:[36], ':'
    MOV ES:[38], ' '
    
    MOV DH,00001111b				;Fondo negro y letras en color blanco
    MOV DL,45						;Signo - en ascii
    MOV ES:[40],DX					;Muestro en pantalla el signo -
    
    MOV DH,00001111b				;Fondo negro y letras en color blanco
    MOV DL,valor_complemento_2		;Preparo para mostrar el valor complemento a 2
    MOV ES:[42],DX  				;Muestro en pantalla el valor complemento a 2
    
    
        
    salir:							;Salto para poder terminar la ejecicion
        
      MOV AH, 4CH		;Interrupción software para devolver el control al S.O.
      INT 21H			;Ejecutamos el numero de funcion que hemos indicado en la instruccion anterior
END						;Fin

; Complemento a 1

; Si el primer bit de la cadena es 0 el valor del complemento a 1 = BL (osea, el sumatorio)
; Si el primer bit de la cadena es 1 el valor del complemento a 1 = X - (2^n - 1) 

; X - (2^4 - 1)


;Complemento a 2

; Si el primer bit de la cadena es 0 el valor del complemento a 2 = BL (osea, el sumatorio)
; Si el primer bit de la cadena es 1 el valor del complemento a 2 = X - 2^n 

; X - 2^4


;Exceso Z 

; El resultado es   SUM(Cadena[si]*peso[si]  - z  -> Z=2^(n-1)  

; BL - Z -> Z=2^(4-1)