module CONTROL(
    input  logic [31:0] instruction,   // instrucción completa RISC-V
    output logic        Branch,
    output logic        MemRead,
    output logic        MemtoReg,
    output logic  [2:0] ALUOp,
    output logic        MemWrite,
    output logic        ALUSrc,
    output logic        RegWrite,
	 output logic  [1:0] AuipcLui
);


    logic [4:0] opcode;
    assign opcode = instruction[6:2];

    always_comb begin
        Branch    = 0;
        MemRead   = 0;
        MemtoReg  = 0;
        ALUOp     = 3'b000;
        MemWrite  = 0;
        ALUSrc    = 0;
        RegWrite  = 0;
		  AuipcLui  = 2'b11;
        case (opcode)

            // R-format
            7'b01100: begin
                ALUOp     = 3'b000;
                RegWrite  = 1;
            end

            // I-format
            7'b00100: begin
                ALUOp     = 3'b011;
                ALUSrc    = 1;
                RegWrite  = 1;
            end

            // LW
            7'b00000: begin
                MemRead   = 1;
                MemtoReg  = 1;
                ALUSrc    = 1;
                ALUOp     = 3'b010;
                RegWrite  = 1;
            end

            // SW
            7'b01000: begin
                MemWrite  = 1;
                ALUSrc    = 1;
                ALUOp     = 3'b010;
            end

            // BEQ
            7'b11000: begin
                Branch    = 1;
                ALUOp     = 3'b001;
            end
				
				// LUI
				7'b01101: begin
					 RegWrite  = 1;
					 ALUOp     = 3'b100;
					 ALUSrc    = 1;
					 AuipcLui  = 2'b01;//Esto equivale a que el MUX saque un 0
					 
				end

				// AUIPC
				7'b00101: begin
					 RegWrite  = 1;
					 ALUOp     = 3'b100; 
					 ALUSrc    = 1;
					 AuipcLui  = 2'b00;//Esto equivale a que el MUX saque el PC
				end
			default: begin
				Branch    = 0;
				MemRead   = 0;
				MemtoReg  = 0;
				ALUOp     = 3'b000;
				MemWrite  = 0;
				ALUSrc    = 0;
				RegWrite  = 0;
				AuipcLui  = 2'b11;
			end


        endcase
    end

endmodule
