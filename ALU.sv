module ALU (
    input logic	 [31:0] A,
    input logic signed  [31:0] B,
    input logic     [3:0]  ALU_control,
	input logic sel, //seleccion por si necesitamos operar con un inmediato negativo
    output logic [31:0] ALU_result,
    output logic          zero

);

	always @(*) begin
		case (ALU_control)

			4'b0000: ALU_result = (!sel) ? (A + $unsigned(B)) : (A + $signed(B));             // ADD o ADDi
			4'b0001: ALU_result = A - $unsigned(B) ;             // SUB 
			4'b0010: ALU_result = (!sel) ? (A & $unsigned(B)) : (A & $signed(B));             // AND o ANDi
			4'b0011: ALU_result = (!sel) ? (A | $unsigned(B)) : (A | $signed(B));             // OR o ORi
			4'b0100: ALU_result = (!sel) ? (A ^ $unsigned(B)) : (A ^ $signed(B));             // XOR o XORi

			// SHIFT LEFT LOGIC
			4'b0101: ALU_result = A << $unsigned(B[4:0]);        // SLL

			// SHIFT RIGHT LOGIC
			4'b0110: ALU_result = A >> $unsigned(B[4:0]);        // SRL

			// SHIFT RIGHT ARITHMETIC (CON SIGNO)
			// Nota: A debe ser tratado como signed para el shift
			4'b0111: ALU_result = $signed(A) >>> $unsigned(B[4:0]); // SRA 

			// LESS THAN (unsigned) - SLTU / BLTU
			4'b1000: ALU_result = (!sel) ? ((A < $unsigned(B)) ? 32'd1 : 32'd0) : 
										((A < $signed(B)) ? 32'd1 : 32'd0);

			// LESS THAN (signed) - SLT / BLT
			4'b1001: ALU_result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; 
				
			// BNE (Comparación)
			4'b1010: ALU_result = A - $unsigned(B);
				
			// LESS THAN (unsigned) - SLTU / BGEU
			4'b1011: ALU_result = (A < $unsigned(B)) ? 32'd1 : 32'd0; 

			// LESS THAN (signed) - SLT / BGE
			4'b1100: ALU_result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; 
				
			default: ALU_result = 32'd0;
		endcase
	end

    assign zero =
    (ALU_control == 4'b0001) ? (ALU_result == 0) :      // BEQ  → igual
    (ALU_control == 4'b1010) ? (ALU_result != 0) :      // BNE  → distinto
    (ALU_control == 4'b1001) ? (ALU_result == 1) :      // BLT  → SLT = 1
    (ALU_control == 4'b1000) ? (ALU_result == 1) :      // BLTU → SLTU = 1
	(ALU_control == 4'b1011) ? (ALU_result == 0) :      // BGE  → SLT = 0
	(ALU_control == 4'b1100) ? (ALU_result == 0) :      // BGEU → SLTU = 0
    1'b0;                                               // resto (no branch)
endmodule
