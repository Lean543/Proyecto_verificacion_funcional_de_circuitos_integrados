class driver;
    stimulus   stimulus_obj;
    scoreboard scoreboard_obj;
    virtual ifc_riscv ifc_riscv_obj;
    
    int instructions_file;

    function new(virtual ifc_riscv ifc_riscv_obj, scoreboard scoreboard_obj);
        this.ifc_riscv_obj  = ifc_riscv_obj;
        this.scoreboard_obj = scoreboard_obj;
    endfunction

    task reset();
        instructions_file = $fopen("darksocv.mem", "w");
        if (!instructions_file) $fatal(1, "Driver: No se pudo abrir darksocv.mem");
    endtask

    task drive_operators();
        $display("Driver: Creando instruccion.");
        stimulus_obj = new();
        stimulus_obj.randomize();
        stimulus_obj.build_instruction();
        $display("Driver: Instruccion = %h", stimulus_obj.instruction);
        $fwrite(instructions_file, "%h\n", stimulus_obj.instruction);
      repeat(20) @(posedge ifc_riscv_obj.clk); // suponemos que hay que esperar para poder volver a enviar una instrucion 
    endtask

    task close_file();
        $fclose(instructions_file);
    endtask

endclass
