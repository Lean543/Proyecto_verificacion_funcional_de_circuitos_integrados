class riscv_sequence extends uvm_sequence #(riscv_item); //genera la transacción y llama start_item() y finish_item() para coordinar envío y espera de respuesta.
	//Registrarse en la fábrica
    `uvm_object_utils(riscv_sequence)

  	function new(string name = "riscv_sequence"); //constructor del sequence
        super.new(name);
    endfunction

  	task body(); //genera un número de instrucciones randomizadas y las manda a probar

        riscv_item req;

      	repeat (50) begin //generar un número de instrucciones randomizadas

          	req = riscv_item::type_id::create("req"); //creacion de un nuevo ejercicio

          	start_item(req); //señala a componentes que empieza un ejercicio

            if (!req.randomize())
                `uvm_fatal(get_type_name(), "Error al randomizar instruction item")

            req.build_instruction(); // mete en el contenedor la instrucción que generó el sequence_item

          	`uvm_info(get_type_name(), $sformatf("Generada instruccion: %s", req.convert2string()), UVM_MEDIUM)

          	finish_item(req); //señala a componentes que terminó un ejercicio

        end

    endtask

endclass
