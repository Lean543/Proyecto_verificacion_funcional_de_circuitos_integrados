class analysis_item extends uvm_sequence_item;
    `uvm_object_utils(analysis_item)
    logic [31:0] instruction;
    logic [31:0] expected_result;
    logic [4:0]  expected_rd;

    string        executed_op;   // nombre de la instrucción ej "ADD", "ADDI", "LUI"
    logic [4:0]   rs1_val;
    logic [4:0]   rs2_val;
    logic [31:0]  imm_val;
    bit [6:0]     opcode_val;

    function new(string name="analysis_item");
      super.new(name);
    endfunction
endclass