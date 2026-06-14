interface ifc_riscv(input logic clk);

    logic reset;

    logic [0:15][31:0] regs;

    logic activeprocesor;

endinterface