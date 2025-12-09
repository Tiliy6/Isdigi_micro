module Inm_Gen(
    input  logic [31:0] inst, 
    output logic [31:0] inm
);

    // Extraemos opcode directamente de la instrucción
    logic [6:0] op_code;
    assign op_code = inst[6:0];

    // Codificación de formatos RISC-V
    localparam I_Format = 7'b0010011;
    localparam S_Format = 7'b0100011;
    localparam B_Format = 7'b1100011;
    localparam U_Format = 7'b0110111;
    localparam U_auipc  = 7'b0010111; 
    localparam J_Format = 7'b1101111;

    always_comb begin
        case (op_code)

            // -------- I-FORMAT --------
            I_Format: begin
                inm = {{21{inst[31]}}, inst[30:20]};
            end

            // -------- S-FORMAT --------
            S_Format: begin
                inm = {{21{inst[31]}}, inst[30:25], inst[11:7]};
            end

            // -------- B-FORMAT --------
            B_Format: begin
                inm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            end

            // -------- U-FORMAT --------
            U_Format: begin
                inm = {inst[31:12], 12'b0};
            end

            // --------  U_auipc -------- 
           U_auipc: begin
                inm = {inst[31:12], 12'b0};
            end

            // -------- J-FORMAT --------
            J_Format: begin
                inm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            end

            // -------- DEFAULT = I-FORMAT --------
            default: begin
                inm = {{21{inst[31]}}, inst[30:20]};
            end

        endcase
    end

endmodule




