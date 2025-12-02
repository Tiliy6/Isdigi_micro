module GP10 (
  // Lado bus
  input  logic        clk,
  input  logic        reset,      // activo bajo
  input  logic        write_en,       // write enable registro 1
  input  logic        read_en,    // read enable registro 2
  input  logic [15:0] dataw,      // dato que escribe el core en GP10
  output logic [15:0] datar,      // dato que lee el core desde GP10

  // Lado placa
  input  logic [15:0] SW,         // switches físicos
  output logic [15:0] LEDR,       // leds rojos
  output logic [6:0]  HEX0,       // unidades
  output logic [6:0]  HEX1,       // decenas
  output logic [6:0]  HEX2,       // centenas
  output logic [6:0]  HEX3        // millares
);

  // ==============================
  // REGISTRO 1: LEDR (escritura)
  // ==============================
  // LEDR guarda dataw cuando memw=1
  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      LEDR <= 16'd0;
    end else begin
      if (write_en) begin
        LEDR <= dataw;
      end
    end
  end

  // ==============================
  // REGISTRO 2: lectura asíncrona
  // ==============================
  // datar devuelve los switches cuando read_en=1
  always_comb begin
    if (read_en)
      datar = SW;
    else
      datar = 16'd0;
  end

  // ==================================================
  // BCD + 7 segmentos a partir de la salida LEDR
  // ==================================================
  // Tomamos el valor de LEDR (0..65535) y lo limitamos a 0..9999
  logic [15:0] val;
  logic [3:0]  u, d, c, m; // unidades, decenas, centenas, millares

  always_comb begin
    val = LEDR;
    if (val > 16'd9999)
      val = 16'd9999;

    // Conversión binario -> BCD por división (sintetizable)
    u =  val % 10;
    d = (val / 10)  % 10;
    c = (val / 100) % 10;
    m = (val / 1000)% 10;
  end

  // Decoder BCD -> 7 segmentos (asumiendo activos en bajo )
  function automatic logic [6:0] bcd_to_7seg (input logic [3:0] bcd);
    case (bcd)
      4'd0: bcd_to_7seg = 7'b1000000;
      4'd1: bcd_to_7seg = 7'b1111001;
      4'd2: bcd_to_7seg = 7'b0100100;
      4'd3: bcd_to_7seg = 7'b0110000;
      4'd4: bcd_to_7seg = 7'b0011001;
      4'd5: bcd_to_7seg = 7'b0010010;
      4'd6: bcd_to_7seg = 7'b0000010;
      4'd7: bcd_to_7seg = 7'b1111000;
      4'd8: bcd_to_7seg = 7'b0000000;
      4'd9: bcd_to_7seg = 7'b0010000;
      default: bcd_to_7seg = 7'b1111111; // todo apagado
    endcase
  endfunction

  // Asignar cada dígito a su display
  always_comb begin
    HEX0 = bcd_to_7seg(u); // unidades
    HEX1 = bcd_to_7seg(d); // decenas
    HEX2 = bcd_to_7seg(c); // centenas
    HEX3 = bcd_to_7seg(m); // millares
  end

endmodule 
