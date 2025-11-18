module ALU (
    input      [31:0] A,
    input      [31:0] B,
    input      [3:0]  ALU_control,
    output reg [31:0] ALU_result,
    output            zero
);

    always @(*) begin
        case (ALU_control)

            4'b0000: ALU_result = A + B;                 // ADD
            4'b0001: ALU_result = A - B;                 // SUB
            4'b0010: ALU_result = A & B;                 // AND
            4'b0011: ALU_result = A | B;                 // OR
            4'b0100: ALU_result = A ^ B;                 // XOR
            4'b0101: ALU_result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'b0110: ALU_result = A << B[4:0];           // SLL
            4'b0111: ALU_result = A >> B[4:0];           // SRL (lógico)
            4'b1000: ALU_result = $signed(A) >>> B[4:0]; // SRA (aritmético)

            default: ALU_result = 32'd0;
        endcase
    end

    assign zero = (ALU_result == 32'd0);

endmodule
