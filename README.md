# Proyecto_verificacion_funcional_de_circuitos_integrados

# Avance 1

### Creacion del estimulo: 

Este debe generar de manera aleatoria instrucciones de RISCV con el formato tipo R

| Campo   | Bits     | Tamaño | Descripción                              |
|---------|----------|--------|------------------------------------------|
| funct7  | [31:25]  | 7 bits | Especifica la operación (ej: ADD vs SUB) |
| rs2     | [24:20]  | 5 bits | Segundo registro fuente                  |
| rs1     | [19:15]  | 5 bits | Primer registro fuente                   |
| funct3  | [14:12]  | 3 bits | Tipo de operación dentro de la clase     |
| rd      | [11:7]   | 5 bits | Registro destino                         |
| opcode  | [6:0]    | 7 bits | Tipo de instrucción (R-type = 0110011)   |


Las siguientes son todas las combinaciones validas de funct7 y funct3;

| Instruction| funct7   | funct3 | Operation                  |
|------------|----------|--------|----------------------------|
| add        | 0000000  | 000    | rd = rs1 + rs2             |
| sub        | 0100000  | 000    | rd = rs1 - rs2             |
| sll        | 0000000  | 001    | rd = rs1 << rs2            |
| slt        | 0000000  | 010    | rd = (rs1 < rs2) signed    |
| sltu       | 0000000  | 011    | rd = (rs1 < rs2) unsigned  |
| xor        | 0000000  | 100    | rd = rs1 ^ rs2             |
| srl        | 0000000  | 101    | rd = logical right shift   |
| sra        | 0100000  | 101    | rd = arithmetic right shift|
| or         | 0000000  | 110    | rd = rs1 | rs2             |
| and        | 0000000  | 111    | rd = rs1 & rs2             |

Entonses para tener una instruccion tipo R definidas en el ISA se debe tomar en cuenta que:
- funct7 puede ser: 0000000 o 0100000.
- si funct7 = 0000000, funct3 puede ser {000,101,001,010,011,100,111,110} (esto es cualquier numero de 3 bits).
- si funct7 = 0100000, funct3 puede ser {000,101}.
- rd, rs1, rs2 pueden ser: cualquier numero de 5 bits, estos no tienen restricciones ya que cualquier combinación de registros es válida para instrucciones tipo R segun el ISA.

Luego de tener el stimulo con las reglas anteriores se puede hacer el driver. Este debe poder:
- Instanciar la clase estimulo y scoreboard (aunque para implementar este primer modulo no es necesaria)
- luego escribir las instruciones generadas por el estimulo en el archivo
- cerrar el archivo al final de la ejecucion (todas estas operaciones deben ser metodos de la clase driver)