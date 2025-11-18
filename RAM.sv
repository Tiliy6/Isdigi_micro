// RAM parametrizable: lectura asíncrona, escritura síncrona
module RAM #(
    parameter ANCHO = 32,              // bits por palabra
    parameter LARGO = 1024,            // número de posiciones
    parameter INIT_FILE = ""           // fichero de inicialización
)(
    input                        clk,
    input                        write_enable,   // habilitación de escritura
    input  [$clog2(LARGO)-1:0]   addr,       // dirección
    input  [ANCHO-1:0]           din,        // datos de entrada
    output [ANCHO-1:0]           dout        // datos de salida
);
    // Memoria: LARGO x ANCHO
    reg [ANCHO-1:0] mem [0:LARGO-1];

    
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    // Escritura síncrona
    always @(posedge clk) begin
        if (write_enable) begin
            mem[addr] <= din;
        end
    end

    // Lectura asíncrona
    assign dout = mem[addr];

endmodule
