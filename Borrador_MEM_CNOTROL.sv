// -----------------------------------------------------------------------------
// MEM_CONTROL
// Decide si un acceso del core va a la RAM (0..1023) o al periférico GP10 (1024)
// -----------------------------------------------------------------------------
module mem_control (
    // Lado CORE
    input  logic        dmem_we,        // write enable global
    input  logic        dmem_re,        // read enable global
    input  logic [31:0] dmem_addr,      // dirección de BYTE del core
    input  logic [31:0] dmem_wdata,     // dato que escribe el core
    output logic [31:0] dmem_rdata,     // dato que lee el core

    // Lado RAM (LARGO = 1024, ANCHO = 32)
    output logic [9:0]  ram_addr,       // 10 bits -> 0..1023
    output logic [31:0] ram_wdata,
    input  logic [31:0] ram_rdata,
    output logic        ram_we,
    output logic        ram_re,

    // Lado GP10 (periférico)
    output logic        gp10_memw,      // write enable registro 1 (LEDR/HEX)
    output logic        gp10_read_en,   // read enable registro 2 (SW)
    output logic [15:0] gp10_dataw,     // dato hacia GP10 (LSB de wdata)
    input  logic [15:0] gp10_datar      // dato desde GP10 (SW)
);

    // Índice de palabra (dirección en palabras, no en bytes)
    // Suponiendo direcciones alineadas a 4 bytes:
    //   word_index = dmem_addr / 4 = dmem_addr[12:2]
    logic [10:0] word_index;   // 0..1024

    // Señales de selección
    logic sel_ram;
    logic sel_gp10;

    // -------------------------------------------------------------------------
    // 1) Cálculo del índice de palabra
    // -------------------------------------------------------------------------
    assign word_index = dmem_addr[12:2];   // 11 bits: 0..2047 posible

    // -------------------------------------------------------------------------
    // 2) Decodificación: ¿RAM (0..1023) o GP10 (1024)?
    // -------------------------------------------------------------------------
    always_comb begin
        sel_ram  = 1'b0;
        sel_gp10 = 1'b0;

        if (word_index < 11'd1024) begin
            sel_ram = 1'b1;                // 0..1023 -> RAM
        end
        else if (word_index == 11'd1024) begin
            sel_gp10 = 1'b1;               // 1024 -> GP10
        end
        // Resto de direcciones: ni RAM ni GP10 (rdata = 0)
    end

    // -------------------------------------------------------------------------
    // 3) Señales hacia la RAM
    // -------------------------------------------------------------------------
    assign ram_addr  = word_index[9:0];    // solo 0..1023 se usan en la RAM
    assign ram_wdata = dmem_wdata;
    assign ram_we    = dmem_we & sel_ram;
    assign ram_re    = dmem_re & sel_ram;

    // -------------------------------------------------------------------------
    // 4) Señales hacia el periférico GP10
    // -------------------------------------------------------------------------
    assign gp10_dataw   = dmem_wdata[15:0];      // 16 bits menos significativos
    assign gp10_memw    = dmem_we & sel_gp10;    // escritura a GP10
    assign gp10_read_en = dmem_re & sel_gp10;    // lectura de GP10

    // -------------------------------------------------------------------------
    // 5) MUX de lectura hacia el core
    // -------------------------------------------------------------------------
    always_comb begin
        if (sel_ram) begin
            dmem_rdata = ram_rdata;
        end
        else if (sel_gp10) begin
            dmem_rdata = {16'd0, gp10_datar};    // zero-extend de 16 a 32 bits
        end
        else begin
            dmem_rdata = 32'd0;                  // direcciones no mapeadas
        end
    end

endmodule
