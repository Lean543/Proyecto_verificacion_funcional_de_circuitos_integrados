# Proyecto de Verificación UVM para un Procesador RISC-V
## Avance 3

Este repositorio contiene el tercer avance del proyecto de verificación funcional de un procesador **RISC-V** utilizando la metodología **UVM (Universal Verification Methodology)**.

## Objetivo

Desarrollar un ambiente de verificación capaz de generar, ejecutar y verificar instrucciones RISC-V sobre el procesador, evaluando el correcto funcionamiento de las diferentes unidades del diseño.

## Contenido

El proyecto incluye:

- Ambiente UVM completo.
- Agente (Driver, Monitor y Sequencer).
- Secuencias de generación de instrucciones.
- Scoreboard y Checker.
- Recolección de cobertura funcional.
- Programas dirigidos y aleatorios.
- Soporte para instrucciones:
  - Tipo R
  - Tipo I (ALU)
  - Load
  - Store
  - Branch
  - JAL
  - AUIPC
  - LUI
  - JALR (mediante generación de parejas AUIPC + JALR)

## Estructura

```
.
├── rtl/                # Procesador RISC-V
├── tb/
│   ├── agent/
│   ├── driver/
│   ├── monitor/
│   ├── scoreboard/
│   ├── checker/
│   ├── sequences/
│   ├── tests/
│   └── interfaces/
├── darksocv.mem
├── run.do
└── README.md
```

## Ejecución en EDA playground

Seleccionar el test deseado desde `run.do` utilizando:

```tcl
vsim +access+r -sv_seed random +UVM_TESTNAME=riscv_test
```

o cualquier otro test dirigido, por ejemplo:

```tcl
+UVM_TESTNAME=riscv_r_test
+UVM_TESTNAME=riscv_i_test
+UVM_TESTNAME=riscv_load_test
+UVM_TESTNAME=riscv_store_test
+UVM_TESTNAME=riscv_branch_test
+UVM_TESTNAME=riscv_u_test
+UVM_TESTNAME=riscv_j_test
```

### Test con variación de reloj

```tcl
vsim +access+r -sv_seed random +UVM_TESTNAME=riscv_store_test +CLK_TEST
```

### Test con reset durante la ejecución

```tcl
vsim +access+r -sv_seed random +UVM_TESTNAME=riscv_store_test +RESET_TEST
```

### Test combinado

```tcl
vsim +access+r -sv_seed random +UVM_TESTNAME=riscv_store_test +CLK_TEST +RESET_TEST
```

## Características implementadas

- Generación aleatoria restringida de instrucciones.
- Tests dirigidos por tipo de instrucción.
- Verificación automática mediante Checker.
- Scoreboard para seguimiento de la ejecución.
- Cobertura funcional.