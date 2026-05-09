class env;
    driver driver_obj;
    monitor monitor_obj;
    scoreboard scoreboard_obj;

    function new (virtual ifc_adder ifc_adder_obj);
        $display("Ambiente: Construyendo el ambiente y los componentes");
        scoreboard_obj = new();
        driver_obj = new(ifc_riscv_obj, scoreboard_obj);
        monitor_obj = new(ifc_riscv_obj, scoreboard_obj);
        fork
            monitor_obj.check();
        join_none
    endfunction

endclass