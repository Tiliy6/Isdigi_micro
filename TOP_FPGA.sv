module TOP_FPGA(
    input  logic        CLOCK,
    input  logic        RST_n,

    // Placa DE2-115
    input  logic [15:0] SW,
    output logic [15:0] LEDR,
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3
);

    // =========================================================
    // Señales entre bloques (mismo estilo que TOP_RISCV.sv)
    // =========================================================
    logic [31:0] PC_addr;
    logic [31:0] instr_rom;

    // Señales del core hacia "memoria de datos"
    logic [31:0] alu_result;        // dirección de acceso (byte address)
    logic [31:0] dataram_wr_sig;    // dato a escribir
    logic        ena_wr_sig;        // write enable
    logic        ena_rd_sig;        // read enable

    // Señal que vuelve al core como "dato leído"
    logic [31:0] dmem_rdata_sig;

    // =========================================================
    // Señales internas de RAM
    // =========================================================
    logic [9:0]  ram_addr_sig;
    logic [31:0] ram_wdata_sig;
    logic [31:0] ram_rdata_sig;
    logic        ram_we_sig;
    logic        ram_re_sig;

    // =========================================================
    // Señales internas de GPIO (GP10)
    // =========================================================
    logic        gp10_memw_sig;
    logic        gp10_read_en_sig;
    logic [15:0] gp10_dataw_sig;
    logic [15:0] gp10_datar_sig;

    // =========================================================
    // 1) IMEM (ROM) — instrucción según PC
    // =========================================================
    ROM #(.ANCHO(32), .LARGO(1024), .INIT_FILE("")) ROM_inst
    (
        .addr(PC_addr[11:2]),   // word address (PC/4)
        .dout(instr_rom)
    );

    // =========================================================
    // 2) CORE — genera acceso a datos (addr/we/re/wdata)
    // =========================================================
    TOP_CORE TOP_CORE_inst
    (
        .instr      (instr_rom),
        .CLOCK      (CLOCK),
        .RST_n      (RST_n),
        .dataram_rd (dmem_rdata_sig), // <- viene de mem_control (RAM o GPIO)
        .PC         (PC_addr),
        .ena_wr     (ena_wr_sig),
        .ena_rd     (ena_rd_sig),
        .alu_out_ext(alu_result),     // byte address hacia mem_control
        .dataram_wr (dataram_wr_sig)
    );

    // =========================================================
    // 3) Memory Controller — decide RAM vs GPIO
    //    RAM: word_index 0..1023
    //    GPIO: word_index == 1024  (justo después de la RAM)
    // =========================================================
    mem_control mem_control_inst
    (
        // Lado CORE
        .dmem_we    (ena_wr_sig),
        .dmem_re    (ena_rd_sig),
        .dmem_addr  (alu_result),
        .dmem_wdata (dataram_wr_sig),
        .dmem_rdata (dmem_rdata_sig),

        // Lado RAM
        .ram_addr   (ram_addr_sig),
        .ram_wdata  (ram_wdata_sig),
        .ram_rdata  (ram_rdata_sig),
        .ram_we     (ram_we_sig),
        .ram_re     (ram_re_sig),

        // Lado GP10
        .gp10_memw    (gp10_memw_sig),
        .gp10_read_en (gp10_read_en_sig),
        .gp10_dataw   (gp10_dataw_sig),
        .gp10_datar   (gp10_datar_sig)
    );

    // =========================================================
    // 4) DMEM (RAM)
    // =========================================================
    RAM #(.INIT_FILE("")) RAM_inst
    (
        .CLK         (CLOCK),
        .write_enable(ram_we_sig),
        .read_enable (ram_re_sig),
        .addr        (ram_addr_sig),   // ya viene en 10 bits 0..1023
        .din         (ram_wdata_sig),
        .dout        (ram_rdata_sig)
    );

    // =========================================================
    // 5) GPIO (GP10) — registros y salida a placa
    // =========================================================
    GPIO GPIO_inst
    (
        // Lado bus
        .clk      (CLOCK),
        .reset    (RST_n),             // GPIO reset activo bajo (igual que RST_n)
        .write_en (gp10_memw_sig),
        .read_en  (gp10_read_en_sig),
        .dataw    (gp10_dataw_sig),
        .datar    (gp10_datar_sig),

        // Lado placa
        .SW       (SW),
        .LEDR     (LEDR),
        .HEX0     (HEX0),
        .HEX1     (HEX1),
        .HEX2     (HEX2),
        .HEX3     (HEX3)
    );

endmodule
