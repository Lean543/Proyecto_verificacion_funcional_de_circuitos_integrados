// Code your testbench here
// or browse Examples
`include "darksocv.v"

module testbench();

    reg  XCLK;
    reg  XRES;

    darksocv DUT (
        .XCLK    (XCLK),
        .XRES    (XRES)
    );

    // registros del procesador
    wire [31:0] x0  = DUT.core0.REGS[0];
    wire [31:0] x1  = DUT.core0.REGS[1];
    wire [31:0] x2  = DUT.core0.REGS[2];
    wire [31:0] x3  = DUT.core0.REGS[3];
    wire [31:0] x4  = DUT.core0.REGS[4];
    wire [31:0] x5  = DUT.core0.REGS[5];
    wire [31:0] x6  = DUT.core0.REGS[6];
    wire [31:0] x7  = DUT.core0.REGS[7];
    wire [31:0] x8  = DUT.core0.REGS[8];
    wire [31:0] x9  = DUT.core0.REGS[9];
    wire [31:0] x10 = DUT.core0.REGS[10];
    wire [31:0] x11 = DUT.core0.REGS[11];
    wire [31:0] x12 = DUT.core0.REGS[12];
    wire [31:0] x13 = DUT.core0.REGS[13];
    wire [31:0] x14 = DUT.core0.REGS[14];
    wire [31:0] x15 = DUT.core0.REGS[15];

    initial begin
        $dumpfile("resultados.vcd");
        $dumpvars(0, testbench);
    end

    always #1 XCLK = ~XCLK;

    initial begin
        XCLK = 1'b1;
      	XRES = 1'b0; // es activo en bajo

        #1000;

        XRES = 1'b1;

        #500 $finish;
    end

endmodule