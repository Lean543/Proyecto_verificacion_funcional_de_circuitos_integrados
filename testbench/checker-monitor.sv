class monitor;
    virtual ifc_riscv ifc_riscv_obj;
    scoreboard scoreboard_obj;
    
    function new(virtual ifc_riscv ifc_riscv_obj, scoreboard scoreboard_obj);
        this.ifc_riscv_obj = ifc_riscv_obj;
        this.scoreboard_obj = scoreboard_obj;
    endfunction

    task check();      
        logic [31:0] expected_result;
      	logic [4:0]  rd_number;
        bit non_zero_found = 0;

        while (non_zero_found == 0) begin
            @(posedge ifc_riscv_obj.clk);
            for (int i = 0; i < 16; i++) begin
                if (ifc_riscv_obj.regs[i] != 0)
                    non_zero_found = 1;
            end
        end

        $display("Monitor: Primer registro no nulo detectado, comenzando verificacion.");

        forever begin
            @(negedge ifc_riscv_obj.clk);

          	if ($feof(scoreboard_obj.mem_file)) begin
    			$display("Monitor: Todas las instrucciones verificadas.");
    			break;
			end
            scoreboard_obj.ref_model();

            expected_result = scoreboard_obj.return_result();
            rd_number       = scoreboard_obj.return_rd();

            if (expected_result != ifc_riscv_obj.regs[rd_number]) begin
              $display("==========================================================");
              $display("Monitor: ERROR rd: x%0d esperado=%h, obtenido=%h",
                          rd_number, expected_result, ifc_riscv_obj.regs[rd_number]);

            end else begin
              $display("==========================================================");  
              $display("Monitor: OK rd: x%0d esperado=%h, obtenido=%h",
                         rd_number, expected_result, ifc_riscv_obj.regs[rd_number]);
            end

        end

    endtask
  
endclass