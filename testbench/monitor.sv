class monitor;
    virtual ifc_riscv ifc_riscv_obj;
    scoreboard scoreboard_obj;
    
    function new(virtual ifc_riscv ifc_riscv_obj, scoreboard scoreboard_obj);
        this.ifc_riscv_obj = ifc_riscv_obj;
        this.scoreboard_obj = scoreboard_obj;
    endfunction

    task check();
      	
        forever begin
          @(posedge ifc_riscv_obj.clk);
          @(negedge ifc_riscv_obj.clk); //Esperamos al negedge después del posedge para evitar "race conditions"
          integer error = 0;
       
          	for (int i = 0; i < 16; i++) begin
              if (scoreboard_obj.return_out_value(i) != ifc_riskv_obj.regs[i]) begin
                $display("ERROR: x%0d esperado=%h, obtenido=%h", i, scoreboard_obj.return_out_value(i), ifc_riskv_obj.regs[i]);
              	error = 1;
              end
            end
          
          if (!error) $display("Monitor-checker: Los resultados de la instrucción coinciden");
        end
    endtask

endclass