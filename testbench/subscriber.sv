class riscv_subscriber extends uvm_subscriber #(riscv_item);
	//Registrarse en la fábrica
    `uvm_component_utils(riscv_subscriber)
	//convertura estructural de linea
    riscv_item tr;

    bit [4:0] rs1;
    bit [4:0] rs2;
    bit [4:0] rd;

    bit [2:0] funct3;
    bit [6:0] funct7;

    bit [6:0] opcode;

    bit is_shift;
    bit is_logic;
    bit is_arithmetic;

    covergroup instruction_cg;

        cp_rs1 : coverpoint rs1 {
            bins low_regs[] = {[0:15]};
        }

        cp_rs2 : coverpoint rs2 {
            bins low_regs[] = {[0:15]};
        }

        cp_rd : coverpoint rd {
            bins low_regs[] = {[0:15]};
        }

        cp_funct3 : coverpoint funct3;

        cp_funct7 : coverpoint funct7 {
            bins normal = {7'b0000000};
            bins alt    = {7'b0100000};
        }

        cp_opcode : coverpoint opcode {
            bins r_type = {7'b0110011};
            bins i_type = {7'b0010011};
            bins lui    = {7'b0110111};
        }

        cp_shift_operation : coverpoint is_shift {
            bins shift_no  = {0};
            bins shift_yes = {1};
        }

        cp_logic_operation : coverpoint is_logic {
            bins logic_no  = {0};
            bins logic_yes = {1};
        }

        cp_arithmetic_operation : coverpoint is_arithmetic {
            bins arith_no  = {0};
            bins arith_yes = {1};
        }

        cross_funct :
            cross cp_funct3, cp_funct7;

        cross_regs :
            cross cp_rs1, cp_rs2;

        cross_opcode_funct3 :
            cross cp_opcode, cp_funct3;

    endgroup

    function new(
        string name = "riscv_subscriber",
        uvm_component parent = null
    );

        super.new(name,parent);

        instruction_cg = new();

    endfunction

  	virtual function void write(riscv_item t);

        opcode = t.instruction[6:0];
        rd      = t.instruction[11:7];
        funct3  = t.instruction[14:12];
        rs1     = t.instruction[19:15];
        rs2     = t.instruction[24:20];
        funct7  = t.instruction[31:25];

        is_shift = 0;
        is_logic = 0;
        is_arithmetic = 0;

        // clasificación solo válida para tipo R; funct7/funct3 no aplican a I ni U
        if (opcode == 7'b0110011) begin
            case ({funct7,funct3})

                {7'b0000000,3'b001},
                {7'b0000000,3'b101},
                {7'b0100000,3'b101}:
                    is_shift = 1;

                {7'b0000000,3'b111},
                {7'b0000000,3'b110},
                {7'b0000000,3'b100}:
                    is_logic = 1;

                {7'b0000000,3'b000},
                {7'b0100000,3'b000},
                {7'b0000000,3'b010},
                {7'b0000000,3'b011}:
                    is_arithmetic = 1;

            endcase
        end

        instruction_cg.sample();

        // rd está en bits [11:7] en todos los tipos — siempre es un registro destino
        assert(rd < 16)
        else
            `uvm_error(get_type_name(), $sformatf("rd invalido: %0d", rd))

        // rs1 está en bits [19:15] — válido en tipo R e I; en tipo U esos bits son parte del inmediato
        if (opcode == 7'b0110011 || opcode == 7'b0010011)
            assert(rs1 < 16)
            else
                `uvm_error(get_type_name(), $sformatf("rs1 invalido: %0d", rs1))

        // rs2 está en bits [24:20] — solo válido en tipo R; en I y U esos bits son parte del inmediato
        if (opcode == 7'b0110011)
            assert(rs2 < 16)
            else
                `uvm_error(get_type_name(), $sformatf("rs2 invalido: %0d", rs2))

          	`uvm_info(get_type_name(), $sformatf("Cobertura muestreada para instruccion %08h", t.instruction), UVM_HIGH)

    endfunction

    function void report_phase(uvm_phase phase);

        real cov;

        cov = instruction_cg.get_coverage();

      	`uvm_info(get_type_name(), $sformatf("Cobertura total = %0.2f%%", cov), UVM_NONE)

    endfunction

endclass
