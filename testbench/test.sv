program testcase (ifc_riscv ifc_riscv_obj);
    env env_obj = new (ifc_riscv_obj);

    //Esto es la "secuencia" del test. Es aquí donde usamos el driver para crear
    //ejercicios diferentes para estresar la lógica
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
        env_obj.driver_obj.reset();
        for (int i=0; i<100; i=i+1)begin
            env_obj.driver_obj.drive_operators();
            $display("////////////////////////////// Iteracion completada");
        end
    end
endprogram