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
          
          	rd = scoreboard_obj.return_result();
          	rd_number = scoreboard_obj.return_rd();
       
            if (rd != ifc_riskv_obj.regs[rd_number]) begin
                $display("ERROR rd: x%0d esperado=%h, obtenido=%h", rd_number, rd, ifc_riskv_obj.regs[rd_number]);
                error = 1;	
            end
          
          	if (!error) $display("Monitor-checker: Los resultados de la instrucción actual coinciden");
        end
    endtask

endclass