module CONTROL(
    input  logic [31:0] instruction,   // instrucción completa RISC-V
    output logic        Branch,
    output logic        MemRead,
    output logic        MemtoReg,
    output logic  [1:0] ALUOp,
    output logic        MemWrite,
    output logic        ALUSrc,
    output logic        RegWrite,
	 output logic        AuipcLui
);


    logic [4:0] opcode;
    assign opcode = instruction[6:2];

    always_comb begin
        Branch    = 0;
        MemRead   = 0;
        MemtoReg  = 0;
        ALUOp     = 2'b00;
        MemWrite  = 0;
        ALUSrc    = 0;
        RegWrite  = 0;
		  AuipcLui  = 0;
        case (opcode)

            // R-format
            7'b01100: begin
                ALUOp     = 2'b00;
                RegWrite  = 1;
            end

            // I-format
            7'b00100: begin
                ALUOp     = 2'b11;
                ALUSrc    = 1;
                RegWrite  = 1;
            end

            // LW
            7'b00000: begin
                MemRead   = 1;
                MemtoReg  = 1;
                ALUSrc    = 1;
                ALUOp     = 2'b10;
                RegWrite  = 1;
            end

            // SW
            7'b01000: begin
                MemWrite  = 1;
                ALUSrc    = 1;
                ALUOp     = 2'b10;
            end

            // BEQ
            7'b11000: begin
                Branch    = 1;
                ALUOp     = 2'b01;
            end
				
				// LUI
				7'b01101: begin
					 RegWrite  = 1;
					 AuipcLui  = 1;
				end

				// AUIPC
				7'b00101: begin
					 RegWrite  = 1;
					 AuipcLui  = 1;
				end


        endcase
    end

endmodule
