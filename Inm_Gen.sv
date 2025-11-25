module Inm_Gen(
    input  logic [31:0] inst, 
    input  logic [6:0]  op_code, 
    output logic [31:0] inm
);

    // Definir parámetros para los tipos de formato
    localparam I_Format = 7'b0010011;
    localparam S_Format = 7'b0100011;
    localparam B_Format = 7'b1100011;
    localparam U_Format = 7'b0110111;
    localparam J_Format = 7'b1101111;

    always_comb begin
        case (op_code)
            I_Format: inm = {{21{inst[31]}}, inst[30:20]};
            S_Format: inm = {{21{inst[31]}}, inst[30:25], inst[11:7]};
            B_Format: inm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            U_Format: inm = {inst[31:12], 12'b0};
            J_Format: inm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            default:  inm = {{21{inst[31]}}, inst[30:20]}; // por defecto I-Format
        endcase
    end

endmodule
