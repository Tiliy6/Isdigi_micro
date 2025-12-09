// Generador de inmediatos hasta la entrega de la fase 2
// Soporta:
//   - I-type: ADDi, SLTi, SLTiU, XORi, ORi, ANDi, SLLi, SRLi, SRAi, LW
//   - S-type: SW
//   - B-type: BEQ, BNE, BGE
//   - U-type: LUI, AUIPC
//   - R-type: sin inmediato (imm = 0)

module Inm_Gen (
    input  logic [31:0] instr,   // instrucción completa
    output logic [31:0] imm      // inmediato sign-extendido
);

    // Opcode de la instrucción
    logic [6:0] opcode;
    assign opcode = instr[6:0];

    // Opcodes RV32I que usamos en el proyecto
    localparam logic [6:0]
        OPCODE_LOAD   = 7'b0000011, // LW
        OPCODE_OPIMM  = 7'b0010011, // ADDi, ANDi, ...
        OPCODE_STORE  = 7'b0100011, // SW
        OPCODE_BRANCH = 7'b1100011, // BEQ, BNE, BGE
        OPCODE_LUI    = 7'b0110111, // LUI
        OPCODE_AUIPC  = 7'b0010111; // AUIPC

    always_comb begin
        unique case (opcode)

            // ======================= I-TYPE ==========================
            // LW (LOAD) y ALU inmediatas (ADDi, ANDi, SLTi, ...)
            OPCODE_LOAD,
            OPCODE_OPIMM: begin
                // imm[31:0] = sign-extend(instr[31:20])
                imm = {{20{instr[31]}}, instr[31:20]};
            end

            // ======================= S-TYPE ==========================
            // SW
            OPCODE_STORE: begin
                // imm[31:0] = sign-extend(instr[31:25] instr[11:7])
                imm = {{20{instr[31]}},
                        instr[31:25],
                        instr[11:7]};
            end

            // ======================= B-TYPE ==========================
            // BEQ, BNE, BGE (todas usan el mismo formato B)
            OPCODE_BRANCH: begin
                // imm[31:0] = sign-extend( instr[31] instr[7]
                //                           instr[30:25] instr[11:8] 0 )
                imm = {{19{instr[31]}},
                        instr[31],
                        instr[7],
                        instr[30:25],
                        instr[11:8],
                        1'b0};
            end

            // ======================= U-TYPE ==========================
            // LUI y AUIPC (mismo formato)
            OPCODE_LUI,
            OPCODE_AUIPC: begin
                // imm[31:0] = instr[31:12] << 12
                imm = {instr[31:12], 12'b0};
            end

            // ======================= R-TYPE / otros ==================
            // ADD, SUB, SLT, ... no tienen inmediato
            default: begin
                imm = 32'd0;
            end

        endcase
    end

endmodule
