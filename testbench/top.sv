// Code your testbench here
// or browse Examples
`include "darksocv.v"

module top();

   	logic  clk;
    logic  res;

    ifc_riscv ifc_riscv_obj(clk);
  
    env env_obj = new (ifc_riscv_obj);

    darksocv DUT (
      .XCLK    (clk),
      .XRES    (res)
    );

    always #1 clk = ~clk;
  
    genvar i;
    generate
    for (i=0; i<16; i=i+1)begin
      assign ifc_riscv_obj.regs[i] = DUT.core0.REGS[i];
    end
    endgenerate
  
  	initial begin
      $dumpfile("dump.vcd");
      $dumpvars(1, top);
    end
  
    initial begin
      env_obj.driver_obj.reset();
      for (int i=0; i<30; i=i+1)begin
            env_obj.driver_obj.drive_operators();
            //$display("////////////////////////////// Iteracion completada");
        end
      env_obj.driver_obj.close_file();
    end

    initial begin 
        clk = 1'b1;
      	res = 1'b1;
      	#10;
        res = 1'b0;
        #700
        res = 1'b1;
        $display("Termina el reset");
        #100 $finish;
    end
  
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

endmodule