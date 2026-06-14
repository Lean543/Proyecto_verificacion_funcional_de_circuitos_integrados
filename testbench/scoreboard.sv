class riscv_scoreboard extends uvm_scoreboard;
	//Registrarse en la fábrica
    `uvm_component_utils(riscv_scoreboard)

  	uvm_analysis_imp #(riscv_item,riscv_scoreboard) analysis_export; //creación de un cable conexion analysis_export con el monitor (esto es el analisys port del lado del scoreboard)

  	uvm_analysis_port #(riscv_item) checker_port; //cable conexion con el checker
	//variables globales del scoreboard que tienen partes de la instruccion y la instruccion completa
    logic [31:0] result;

    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;

    logic [31:0] instruction;

    logic [31:0] regf [15:0];

  	function new(string name = "riscv_scoreboard", uvm_component parent = null); //constructor del scoreboard

      	super.new(name,parent); //llama al constructor de la clase padre

     	analysis_export = new("analysis_export",this); //constructor del cable conexion analysis_export

      	checker_port = new("checker_port",this); //constructor cable conexion con el checker

    endfunction

  	function void build_phase(uvm_phase phase);

        result = 0;
        rd     = 0;
        rs1    = 0;
        rs2    = 0;

      	for(int i=0; i<16; i++)
            regf[i] = 0;

    endfunction

    virtual function void write(riscv_item t); //algoritmo de ejecución de una instrucción

        instruction = t.instruction; //extrae la instrucción del item t del sequencer que llegó por el analysis_export y la guarda como una variable global del scoreboard

      	`uvm_info(get_type_name(), $sformatf("Procesando instruccion %08h", instruction), UVM_MEDIUM)

      	ref_model(); //calcula resultado teorico con la instruccion que se generó en el item
		
		t.expected_result = result;
        t.expected_rd     = rd;      
      
      	checker_port.write(t); //llama a funcion write() del checker y le pasa la instruccion que se genera en ref_model

    endfunction

    function void ref_model(); //calculo del modelo de referencia

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
          `uvm_info(get_type_name(), $sformatf("Scoreboard: El registro de destino es el registro 0"), UVM_MEDIUM); 

        end else begin
            case (opcode)
				//R-type
                7'b0110011: begin
                    case ({funct7, funct3})
                      
                        {7'b0000000,3'b000}: begin 
                          regf[rd] = regf[rs1] + regf[rs2];                     
                          $display("Instrucción ejecutada: ADD");  
                        end
                      
                        {7'b0100000,3'b000}: begin 
                          regf[rd] = regf[rs1] - regf[rs2];                     
                          $display("Instrucción ejecutada: SUB");  
                        end
                      
                        {7'b0000000,3'b111}: begin 
                          regf[rd] = regf[rs1] & regf[rs2];                     
                          $display("Instrucción ejecutada: AND");  
                        end
                      
                        {7'b0000000,3'b110}: begin 
                          regf[rd] = regf[rs1] | regf[rs2];                     
                          $display("Instrucción ejecutada: OR");   
                        end
                      
                        {7'b0000000,3'b100}: begin 
                          regf[rd] = regf[rs1] ^ regf[rs2];                     
                          $display("Instrucción ejecutada: XOR");  
                        end
                      
                        {7'b0000000,3'b001}: begin 
                          regf[rd] = regf[rs1] << regf[rs2][4:0];               
                          $display("Instrucción ejecutada: SLL");  
                        end
                      
                        {7'b0000000,3'b101}: begin 
                          regf[rd] = regf[rs1] >> regf[rs2][4:0];               
                          $display("Instrucción ejecutada: SRL");  
                        end
                      
                        {7'b0100000,3'b101}: begin 
                          regf[rd] = $signed(regf[rs1]) >>> regf[rs2][4:0];
                          //regf[rd] = regf[rs1] >>> regf[rs2][4:0];
                          $display("Instrucción ejecutada: SRA");  
                        end
                      
                        {7'b0000000,3'b011}: begin 
                          regf[rd] = (regf[rs1] < regf[rs2]);                   
                          $display("Instrucción ejecutada: SLTU"); 
                        end
                      
                        {7'b0000000,3'b010}: begin 
                          regf[rd] = ($signed(regf[rs1]) <$signed(regf[rs2])); 
                          $display("Instrucción ejecutada: SLT");  
                        end
                      
                        default: begin 
                          result = 32'hDEADBEEF;                                              $display("Instruction R no soportada"); 
                        end
                      
                    endcase
                    result = regf[rd];
                end
				//I-type
                7'b0010011: begin
                    imm = {{20{instruction[31]}}, instruction[31:20]};

                    case (funct3)
                        3'b000: begin 
                            regf[rd] = regf[rs1] + imm;                              
                          $display("Instrucción ejecutada: ADDI");  
                        end
                    
                        3'b010: begin 
                            regf[rd] = ($signed(regf[rs1]) < $signed(imm));          
                          $display("Instrucción ejecutada: SLTI");  
                        end
                    
                        3'b011: begin 
                          regf[rd] = ($unsigned(regf[rs1]) < $unsigned(imm));                            
                          $display("Instrucción ejecutada: SLTIU"); 
                        end
                    
                        3'b100: begin 
                            regf[rd] = regf[rs1] ^ imm;                              
                          $display("Instrucción ejecutada: XORI");  
                        end
                    
                        3'b110: begin 
                            regf[rd] = regf[rs1] | imm;                              
                          $display("Instrucción ejecutada: ORI");   
                        end
                    
                        3'b111: begin 
                            regf[rd] = regf[rs1] & imm;                              
                          $display("Instrucción ejecutada: ANDI");  
                        end
                    
                        3'b001: begin 
                            regf[rd] = regf[rs1] << imm[4:0];                        
                          $display("Instrucción ejecutada: SLLI");  
                        end
                    
                        3'b101: begin
                            if (funct7 == 7'b0100000) begin
                                regf[rd] = $signed(regf[rs1]) >>> imm[4:0];
                              $display("Instrucción ejecutada: SRAI");
                            end else begin
                                regf[rd] = regf[rs1] >> imm[4:0];
                              $display("Instrucción ejecutada: SRLI");
                            end
                        end
                    
                        default: begin 
                            result = 32'hDEADBEEF;                    
                          $display("Instruccion inmediata (I) no soportada"); 
                        end
                    
                    endcase
                    result = regf[rd];	
                end
				//U-type
                7'b0110111: begin
                    imm = {instruction[31:12], 12'b0};
                    regf[rd] = imm;
                    result = regf[rd];
                    $display("Instrucción ejecutada: LUI");
                end

                default: begin
                    result = 32'hDEADBEEF;
                    $display("Instruction no soportada por el scoreboard");
                end

            endcase
        end 
          if (opcode == 7'b0110111) begin
            `uvm_info(get_type_name(), $sformatf("Scoreboard: rd: %d, inmediato: %h", rd, instruction[31:12]), UVM_MEDIUM);
          end else if (opcode == 7'b0010011) begin
            `uvm_info(get_type_name(), $sformatf("Scoreboard: rd: %d, rs1: %d, inmediato: %h", rd, rs1, imm), UVM_MEDIUM);
          end else begin
            `uvm_info(get_type_name(), $sformatf("Scoreboard: rd: %d, rs1: %d, rs2: %d", rd, rs1, rs2), UVM_MEDIUM);
          end
    endfunction
  
    /*function logic [31:0] return_result();

        return result;

    endfunction

    function logic [4:0] return_rd();

        return rd;

    endfunction*/

    function logic [4:0] return_rs1();

        return rs1;

    endfunction

    function logic [4:0] return_rs2();

        return rs2;

    endfunction

endclass
