class riscv_scoreboard extends uvm_scoreboard;
	//Registrarse en la fábrica
    `uvm_component_utils(riscv_scoreboard)
  	uvm_analysis_imp #(analysis_item, riscv_scoreboard) analysis_export;
  	uvm_analysis_port #(analysis_item) checker_port;

    logic [31:0] result;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [31:0] instruction;
    logic [31:0] regf [15:0];

    // Buffer para compensar el desfase de pipeline antes de enviar al checker
    analysis_item pending_queue[$];
  
    localparam int PIPELINE_DELAY = 2; //numero de instrucciones almacenadas en el buffer

  	function new(string name = "riscv_scoreboard", uvm_component parent = null);
      	super.new(name,parent);
     	analysis_export = new("analysis_export",this);
      	checker_port = new("checker_port",this);
    endfunction

  	function void build_phase(uvm_phase phase);
        result = 0;
        rd     = 0;
        rs1    = 0;
        rs2    = 0;
      	for(int i=0; i<16; i++)
            regf[i] = 0;
    endfunction

    virtual function void write(analysis_item t);
        analysis_item to_send;

        instruction = t.instruction;
      	ref_model(t);  // ahora se pasa t para que guarde los datos ahí

        pending_queue.push_back(t);

      	if(pending_queue.size() <= PIPELINE_DELAY) begin //no pasar nada al checker si aún no se cumplen los retardos del buffer
            return;
        end

      	to_send = pending_queue.pop_front(); //liberar el bufer

        `uvm_info(get_type_name(), $sformatf("Procesando instruccion %08h", to_send.instruction), UVM_MEDIUM)
        $display("Instruccion ejecutada: %s", to_send.executed_op);

        if(to_send.opcode_val == 7'b0110111) begin         
            `uvm_info(get_type_name(), $sformatf("Scoreboard: rd: %0d, inmediato: %h", to_send.expected_rd, to_send.imm_val), UVM_MEDIUM);
          
        end else if(to_send.opcode_val == 7'b0010011) begin
            `uvm_info(get_type_name(), $sformatf("Scoreboard: rd: %0d, rs1: %0d, inmediato: %h", to_send.expected_rd, to_send.rs1_val, to_send.imm_val), UVM_MEDIUM);
          
        end else begin
          
            `uvm_info(get_type_name(), $sformatf("Scoreboard: rd: %0d, rs1: %0d, rs2: %0d", to_send.expected_rd, to_send.rs1_val, to_send.rs2_val), UVM_MEDIUM);
        end

        checker_port.write(to_send);
    endfunction

    function void ref_model(analysis_item t); //calculo del modelo de referencia
        bit [6:0] opcode;
        bit [2:0] funct3;
        bit [6:0] funct7;
        logic signed [31:0] imm;

        opcode = instruction[6:0];
        funct3 = instruction[14:12];
        funct7 = instruction[31:25];

        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        rd  = instruction[11:7];

        if (rd == 0) begin
          
            result = 0;
            t.executed_op = "RD=0 (ignorada)";
        end else begin
            case (opcode)
                //tipo R
                7'b0110011: begin
                    case ({funct7, funct3})
                        {7'b0000000,3'b000}: begin 
                          regf[rd] = regf[rs1] + regf[rs2]; 
                          t.executed_op = "ADD"; 
                        end
                        {7'b0100000,3'b000}: begin 
                          regf[rd] = regf[rs1] - regf[rs2]; 
                          t.executed_op = "SUB"; 
                        end
                        {7'b0000000,3'b111}: begin 
                          regf[rd] = regf[rs1] & regf[rs2]; 
                          t.executed_op = "AND"; 
                        end
                        {7'b0000000,3'b110}: begin 
                          regf[rd] = regf[rs1] | regf[rs2]; 
                          t.executed_op = "OR";  
                        end
                        {7'b0000000,3'b100}: begin 
                          regf[rd] = regf[rs1] ^ regf[rs2]; 
                          t.executed_op = "XOR"; 
                        end
                        {7'b0000000,3'b001}: begin 
                          regf[rd] = regf[rs1] << regf[rs2][4:0]; 
                          t.executed_op = "SLL"; 
                        end
                        {7'b0000000,3'b101}: begin 
                          regf[rd] = regf[rs1] >> regf[rs2][4:0]; 
                          t.executed_op = "SRL"; 
                        end
                        {7'b0100000,3'b101}: begin 
                          regf[rd] = $signed(regf[rs1]) >>> regf[rs2][4:0]; 
                          t.executed_op = "SRA"; 
                        end
                        {7'b0000000,3'b011}: begin 
                          regf[rd] = (regf[rs1] < regf[rs2]); 
                          t.executed_op = "SLTU"; 
                        end
                        {7'b0000000,3'b010}: begin 
                          regf[rd] = ($signed(regf[rs1]) < $signed(regf[rs2])); 
                          t.executed_op = "SLT"; 
                        end
                        default: begin result = 32'hDEADBEEF; 
                          t.executed_op = "R no soportada"; 
                        end
                    endcase
                    result = regf[rd];
                end
                //tipo I
                7'b0010011: begin
                    imm = {{20{instruction[31]}}, instruction[31:20]};
                    case (funct3)
                        3'b000: begin 
                          regf[rd] = regf[rs1] + imm; 
                          t.executed_op = "ADDI"; 
                        end
                        3'b010: begin 
                          regf[rd] = ($signed(regf[rs1]) < $signed(imm)); 
                          t.executed_op = "SLTI"; 
                        end
                        3'b011: begin 
                          regf[rd] = ($unsigned(regf[rs1]) < $unsigned(imm)); 
                          t.executed_op = "SLTIU"; end
                        3'b100: begin 
                          regf[rd] = regf[rs1] ^ imm; 
                          t.executed_op = "XORI"; 
                        end
                        3'b110: begin 
                          regf[rd] = regf[rs1] | imm; 
                          t.executed_op = "ORI"; 
                        end
                        3'b111: begin 
                          regf[rd] = regf[rs1] & imm; 
                          t.executed_op = "ANDI"; 
                        end
                        3'b001: begin 
                          regf[rd] = regf[rs1] << imm[4:0]; 
                          t.executed_op = "SLLI"; 
                        end
                        3'b101: begin
                            if (funct7 == 7'b0100000) begin
                                regf[rd] = $signed(regf[rs1]) >>> imm[4:0];
                                t.executed_op = "SRAI";
                              
                            end else begin
                                regf[rd] = regf[rs1] >> imm[4:0];
                                t.executed_op = "SRLI";
                            end
                        end
                        default: begin result = 32'hDEADBEEF; 
                          t.executed_op = "I no soportada"; 
                        end
                    endcase
                    result = regf[rd];
                end
                //tipo U
                7'b0110111: begin
                    imm = {instruction[31:12], 12'b0};
                    regf[rd] = imm;
                    result = regf[rd];
                    t.executed_op = "LUI";
                end
                default: begin
                    result = 32'hDEADBEEF;
                    t.executed_op = "no soportada";
                end
            endcase
        end

        // Guardar todo lo necesario en t para impresión
        t.expected_result = result;
        t.expected_rd      = rd;
        t.rs1_val           = rs1;
        t.rs2_val           = rs2;
        t.imm_val           = imm;
        t.opcode_val        = opcode;
    endfunction
  
endclass
