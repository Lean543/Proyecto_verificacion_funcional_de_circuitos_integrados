class riscv_item extends uvm_sequence_item;

    typedef enum bit [1:0] {R_TYPE = 2'b00, I_TYPE = 2'b01, U_TYPE = 2'b10} instr_type_e;

    rand  instr_type_e instr_type;

    randc bit [4:0] rs1;
    randc bit [4:0] rs2;
    randc bit [4:0] rd;

    randc bit [6:0] funct7;
    randc bit [2:0] funct3;

    rand  bit [11:0] imm_i;   // inmediato de 12 bits (tipo I)
    rand  bit [19:0] imm_u;   // inmediato superior de 20 bits (tipo U — LUI)

    logic [31:0] instruction;
    logic [31:0] expected_result;
    logic [4:0]  expected_rd;

    localparam logic [6:0] opcode_r     = 7'b0110011;
    localparam logic [6:0] opcode_i     = 7'b0010011;
    localparam logic [6:0] opcode_lui   = 7'b0110111;

	//Registrarse en la fábrica
    `uvm_object_utils(riscv_item)

    // Solo 3 de los 4 valores posibles de 2 bits son miembros válidos del enum
    constraint valid_type {
        instr_type inside {R_TYPE, I_TYPE, U_TYPE};
    }

    // funct7 solo es relevante en tipo R; se fuerza a 0 en los demás tipos
    constraint valid_funct7 {
        if (instr_type == R_TYPE)
            funct7 inside {7'b0000000, 7'b0100000};
        else
            funct7 == 7'b0000000;
    }

    // Se limitan los índices de registro a la mitad inferior (x0–x15)
    constraint lower_registers {
        rs1[4] == 1'b0;
        rs2[4] == 1'b0;
        rd[4]  == 1'b0;
        rd     != 5'b00000; // escrituras a x0 se descartan — se evita para pruebas más interesantes
    }

    // SUB y SRA requieren funct7=0100000; las demás operaciones R usan 0000000
    constraint valid_r_funct3 {
        if (instr_type == R_TYPE && funct7 == 7'b0100000)
            funct3 inside {3'b000, 3'b101};
    }

    // Para SRLI/SRAI (funct3=101 en tipo I), imm[11:5] codifica la variante de desplazamiento
    constraint valid_i_shift {
        if (instr_type == I_TYPE && funct3 == 3'b101)
            imm_i[11:5] inside {7'b0000000, 7'b0100000};
    }

    // Inmediato superior no nulo para resultados no triviales en LUI/AUIPC
    constraint nonzero_u_imm {
        imm_u != 20'b0;
    }

  	function new(string name = "riscv_item");
        super.new(name);
    endfunction

    function void build_instruction();
        case (instr_type)
            R_TYPE: instruction = {funct7, rs2, rs1, funct3, rd, opcode_r};
            I_TYPE: instruction = {imm_i, rs1, funct3, rd, opcode_i};
            U_TYPE: instruction = {imm_u, rd, opcode_lui};
            default: instruction = 32'h00000013; // NOP: ADDI x0, x0, 0
        endcase
    endfunction

    function string convert2string();
        string type_str;
        case (instr_type)
            R_TYPE:  type_str = "R";
            I_TYPE:  type_str = "I";
            U_TYPE:  type_str = "U(LUI)";
            default: type_str = "?";
        endcase
        return $sformatf(
            "[%s] instruction=%08h rd=%0d rs1=%0d rs2=%0d funct7=%07b funct3=%03b imm_i=%03h imm_u=%05h",
            type_str, instruction, rd, rs1, rs2, funct7, funct3, imm_i, imm_u
        );
    endfunction

endclass
