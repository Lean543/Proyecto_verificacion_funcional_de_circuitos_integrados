//El estímulo es lo que se transmite, no como un protocolo, pero el
//elemento envuelto en el protocolo que se utiliza para ejercitar la lógica
//El protocolo puede ser enviar paquetes, pero el estímulo corresponde al 
//contenido de esos paquetes así como el tiempo de atraso entre ellos.
//En el caso de una memoria, las direcciones de lectura/escritura pueden
//ser parte del estímulo.

class stimulus;
  randc bit [4:0] rs1, rs2, rd;
  randc bit [6:0] funct7;
  randc bit [2:0] funct3;
  logic [31:0]    instruction;
  
  localparam logic [6:0] opcode_r = 7'b0110011;
  
  constraint valid_funct7 {
    funct7 inside {7'b0000000, 7'b0100000};
  }
  
  constraint lower_registers {
    rs1[4] == 1'b0;
    rs2[4] == 1'b0;
    rd[4]  == 1'b0;
  }

  constraint valid_funct3 {
    if (funct7 == 7'b0100000) funct3 inside {3'b000, 3'b101};
    // si funct7 == 0000000, funct3 es libre (cualquier valor de 3 bits)
  }
    function void build_instruction();
        instruction = {funct7, rs2, rs1, funct3, rd, opcode_r};
    endfunction
endclass 