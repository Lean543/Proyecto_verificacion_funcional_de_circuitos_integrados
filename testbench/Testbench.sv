// Code your testbench here
// or browse Examples
`include "darksocv.v"

module testbench ();
    reg [15:0] [31:0] REGS;
  	wire        XCLK;      // external clock
    wire        XRES;      // external reset
  
  
  for(i=0;i!=16;i=i+1) assign REGS[i] = DUT.core0.REGS[i];
  
 darksocv DUT (
  .XCLK(XCLK),      // external clock
  .XRES(XRES)      // external reset

);
  
initial begin
        $dumpfile("resultados.vcd");
  $dumpvars(1, testbench);
    end  
  
  initial begin
    XCLK = 1'b1;
    XRES = 0;
    
    #10 XRES = 1;
    #10000 XRES = 0;
    
    
  
  #100 $finish;
  end
  

always begin
        #1 XCLK = !XCLK;
  end  

endmodule