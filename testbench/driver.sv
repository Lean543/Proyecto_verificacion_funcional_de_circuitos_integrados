class riscv_driver extends uvm_driver #(riscv_item); //usa get_next_item() / get() para tomar el item, lo drivea a DUT y llama item_done() (o envía RSP) para desbloquear la sequence.
	//Registrarse en la fábrica
    `uvm_component_utils(riscv_driver)

    int instructions_file;

  	function new(string name = "riscv_driver", uvm_component parent = null); //constructor del driver
        super.new(name,parent);
    endfunction

  function void build_phase(uvm_phase phase); //se llama sola cuando llega la etapa build

        super.build_phase(phase);

    endfunction

  	task run_phase(uvm_phase phase); //run se ejecuta al inicio de la simulacion sin ser llamado explicitamente

        riscv_item req; //instancia del sequence_item
      	//comprobacion del archivo de instrucciones desde aqui:
      	instructions_file = $fopen("darksocv.mem","a");

        if(!instructions_file)
          	`uvm_fatal(get_type_name(), "No se pudo abrir darksocv.mem")
          
        $fwrite(instructions_file,"\n");

      	`uvm_info(get_type_name(), "Archivo darksocv.mem abierto", UVM_LOW)
      

      	forever begin
          	seq_item_port.get_next_item(req); //recibe y se sincroniza con un ejercicio del sequencer

            $fwrite(instructions_file, "%h\n", req.instruction);

            `uvm_info(get_type_name(), $sformatf("Instruccion escrita: %08h", req.instruction), UVM_MEDIUM)
          
            $fflush(instructions_file); //hace que el archivo darcsov.mem se escriba en la memoria de la pc a como está en ese momento sin 
            //cerrar el archivo pero provoca warning porque el archivo queda abierto, hay que solucionarlo
          	seq_item_port.item_done(); //manda al sequencer que ya termino el ejercio para que empiece con otro

        end

        if(instructions_file) begin
            $fclose(instructions_file);
            `uvm_info(get_type_name(), "Archivo darksocv.mem cerrado", UVM_LOW)
        end
    endtask

    /*function void report_phase(uvm_phase phase);
      
        if(instructions_file)
            $fclose(instructions_file);

      	`uvm_info(get_type_name(), "Archivo darksocv.mem cerrado", UVM_LOW)
      
      	$system("cat darksocv.mem");

    endfunction*/

endclass