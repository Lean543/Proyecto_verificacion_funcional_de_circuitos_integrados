class riscv_test extends uvm_test;
	//Registrarse en la fábrica
    `uvm_component_utils(riscv_test)
	//instacias de las clases del entorno y la secuencia
    riscv_env env;
    riscv_sequence seq;

    function new(
        string name = "riscv_test",
        uvm_component parent = null
    );
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
      
      super.build_phase(phase); //llama a la funcion build_phase de la clase padre

      	env = riscv_env::type_id::create("env", this); // Definimos los objetos mediante el creador de la fábrica
        // "env" corresponde al nombre de la instancia con el que lo podemos encontrar en la base de datos.
        // this corresponde al "parent" de la instancia en cuestión.

    endfunction

    // Cada test hijo sobrescribe SOLO esta funcion para instanciar su propia secuencia
    virtual function riscv_sequence crear_secuencia();
        return riscv_sequence::type_id::create("seq");
    endfunction

    task run_phase(uvm_phase phase);

      	phase.raise_objection(this); // Debemos levantar una objecion para que el test no termine antes de tiempo

      	`uvm_info(get_type_name(), "Iniciando secuencia RISCV", UVM_LOW)

      	seq = crear_secuencia(); //Se crea la secuencia (la base o la del test hijo)

      	seq.start(env.agent.sequencer); //llama a que se generen ejercicios (instrucciones)

        // Tiempo de simulacion escalado con el largo del programa: base de arranque
        // (reset + preload) mas margen por instruccion (stalls / re-fetch del pipeline)
        #(1000 + seq.numero_instrucciones * 20);

      	phase.drop_objection(this); //llama a que termine la simulacion y uvm entre en estado de extract, check y report

    endtask

endclass
