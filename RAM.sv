// RAM parametrizable: lectura asíncrona, escritura síncrona, enable de lectura
module RAM #(
    parameter ANCHO = 32,              // bits por palabra
    parameter LARGO = 1024,            // número de posiciones
    parameter INIT_FILE = ""           // fichero de inicialización
)(
    input                        CLK,
    input                        write_enable,     // habilitación de escritura
    input                        read_enable,      // habilitación de lectura
    input  [$clog2(LARGO)-1:0]   addr,             // dirección
    input  [ANCHO-1:0]           din,              // datos de entrada
    output [ANCHO-1:0]           dout              // datos de salida
);

    // Memoria: LARGO x ANCHO
    reg [ANCHO-1:0] mem [0:LARGO-1];

    // Inicialización opcional
    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    // Escritura síncrona
    always @(posedge CLK) begin
        if (write_enable) begin
            mem[addr] <= din;
        end
    end

    // Lectura asíncrona CON habilitación
    assign dout = (read_enable) ? mem[addr] : {ANCHO{1'b0}};

endmodule
