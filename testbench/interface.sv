interface ifc_riscv(input logic clk);

    logic reset;

  	logic [0:15][31:0] regs; //registros del core
  
  	logic [31:0] addr; //registro pc
  	logic [31:0] data; //instruccion cargada

    logic idleproc; //idle del core

endinterface