// Code your testbench here
// or browse Examples
`include "darksocv.v"

module top();

   	logic  XCLK;
    logic  XRES;

    darksocv DUT (
        .XCLK    (XCLK),
        .XRES    (XRES)
    );

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

        #10000 $finish;
    end
  
  	// registros del procesador
    //     wire [31:0] x0  = DUT.core0.REGS[0];
    //     wire [31:0] x1  = DUT.core0.REGS[1];
    //     wire [31:0] x2  = DUT.core0.REGS[2];
    //     wire [31:0] x3  = DUT.core0.REGS[3];
    //     wire [31:0] x4  = DUT.core0.REGS[4];
    //     wire [31:0] x5  = DUT.core0.REGS[5];
    //     wire [31:0] x6  = DUT.core0.REGS[6];
    //     wire [31:0] x7  = DUT.core0.REGS[7];
    //     wire [31:0] x8  = DUT.core0.REGS[8];
    //     wire [31:0] x9  = DUT.core0.REGS[9];
    //     wire [31:0] x10 = DUT.core0.REGS[10];
    //     wire [31:0] x11 = DUT.core0.REGS[11];
    //     wire [31:0] x12 = DUT.core0.REGS[12];
    //     wire [31:0] x13 = DUT.core0.REGS[13];
    //     wire [31:0] x14 = DUT.core0.REGS[14];
    //     wire [31:0] x15 = DUT.core0.REGS[15];

    assign ifc_riskv_obj.regs[0]  = DUT.core0.REGS[0];
    assign ifc_riskv_obj.regs[1]  = DUT.core0.REGS[1];
    assign ifc_riskv_obj.regs[2]  = DUT.core0.REGS[2];
    assign ifc_riskv_obj.regs[3]  = DUT.core0.REGS[3];
    assign ifc_riskv_obj.regs[4]  = DUT.core0.REGS[4];
    assign ifc_riskv_obj.regs[5]  = DUT.core0.REGS[5];
    assign ifc_riskv_obj.regs[6]  = DUT.core0.REGS[6];
    assign ifc_riskv_obj.regs[7]  = DUT.core0.REGS[7];
    assign ifc_riskv_obj.regs[8]  = DUT.core0.REGS[8];
    assign ifc_riskv_obj.regs[9]  = DUT.core0.REGS[9];
    assign ifc_riskv_obj.regs[10]  = DUT.core0.REGS[10];
    assign ifc_riskv_obj.regs[11]  = DUT.core0.REGS[11];
    assign ifc_riskv_obj.regs[12]  = DUT.core0.REGS[12];
    assign ifc_riskv_obj.regs[13]  = DUT.core0.REGS[13];
    assign ifc_riskv_obj.regs[14]  = DUT.core0.REGS[14];
    assign ifc_riskv_obj.regs[15]  = DUT.core0.REGS[15];

    ifc_riskv ifc_riskv_obj(XCLK);

  	testcase test(ifc_riskv_obj);

endmodule