class riscv_monitor extends uvm_monitor; //maneja las conexiones con otros componentes y la sincronizacion
	  //Registrarse en la fábrica
    `uvm_component_utils(riscv_monitor)

  	uvm_analysis_port #(riscv_item) ap; //instancia de la conexion al scoreboard y suscriber
  
  	virtual ifc_riscv ifc_riscv_obj; //instacia de la interfaz virtual

    int mem_file;
    int total_instructions;
    int complete_count;

    logic [31:0] instruction;
    logic [31:0] tmp;

  	function new(string name = "riscv_monitor", uvm_component parent = null); //constructor del monitor
      	super.new(name,parent); //llama al constructor de la clase padre

      	ap = new("ap",this); //constructor del cable conexion ap
    endfunction
  
  	function void build_phase(uvm_phase phase);

      	super.build_phase(phase); //llama a la funcion build_phase de la clase padre
 
      	if(!uvm_config_db#(virtual ifc_riscv)::get(this, "", "ifc_riscv_obj", ifc_riscv_obj)) //comprobacion de la conexion con la interfaz virtual		
          	`uvm_fatal(get_type_name(), "No se pudo obtener la interfaz")

    endfunction

    task run_phase(uvm_phase phase); //se llama sola cuando empieza la simulacion

      	riscv_item item;
      
     	@(negedge ifc_riscv_obj.activeprocesor); //queda pegado aqui hasta que el idle del procesador se desactive
      	#3; //retardo para que termine la primera instruccion
      
        mem_file = $fopen("darksocv.mem","r");	

        if(!mem_file)
          	`uvm_fatal(get_type_name(), "No se pudo abrir darksocv.mem")

        total_instructions = 0;

        while(!$feof(mem_file)) begin
            if($fscanf(mem_file,"%h",tmp)==1)
                total_instructions++;
        end //recuento de instrucciones detectadas luego de que el driver cerró el .mem

        $fclose(mem_file);

        mem_file = $fopen("darksocv.mem","r");

        complete_count = 0;

      	`uvm_info(get_type_name(), $sformatf("%0d instrucciones encontradas", total_instructions), UVM_LOW)

        while(!$feof(mem_file)) begin
          
          	@(posedge ifc_riscv_obj.clk); //para sincronizacion con la interfaz virtual

          	item = riscv_item::type_id::create("item"); //llamada al constructor de un nuevo contenerdor de una instruccion

          	if($fscanf(mem_file,"%h",instruction)==1) begin //si no hay linea en blanco:

                item.instruction = instruction; //pone la instruccion que obtuvo del .mem en el item

                complete_count++;

              	ap.write(item); //manda el item (instruccion) por la conexion al scoreboard y suscriber

            	//`uvm_info(get_type_name(), $sformatf("Instruccion leida: %08h", instruction), UVM_MEDIUM)

            end

        end
      	`uvm_info(get_type_name(), $sformatf("%0d instrucciones procesadas", complete_count), UVM_LOW)

        $fclose(mem_file);

    endtask

endclass