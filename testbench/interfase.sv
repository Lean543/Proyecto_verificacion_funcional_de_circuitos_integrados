interface ifc_riscv(input logic clk);
  
  logic reset;
  
  logic [31:0] regs [15:0];
  
endinterface