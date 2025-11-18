`timescale 1ns/1ps

module tb_ALU();

	parameter T = 20;
	
	reg CLOCK;
	reg [31:0] A, B;
	reg [3:0] ALU_control;
	wire zero;
	wire [31:0] ALU_result;
	
	ALU duv
	(
		.A(A) ,
		.B(B) ,
		.ALU_control(ALU_control) ,
		.zero(zero) ,
		.ALU_result(ALU_result)
	);
	
//Clock generation
	always 
	begin 
	#(T/2) CLOCK = ~CLOCK;
	end
	
//Tasks								
	task op_ADD;
		begin
			A = $random;
			B = $random;
			@(posedge CLOCK);
			ALU_control = 4'b0000;
		end
	endtask
	
	task op_SUB;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b0001;
		end
	endtask
	
	task op_AND;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b0010;
		end
	endtask

	task op_OR;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b0011;
		end
	endtask

	task op_XOR;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b0100;
		end
	endtask
	
	task op_SLL;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b0101;
		end
	endtask
	
	task op_SRL;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b0110;
		end
	endtask
	
	task op_SRA;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b0111;
		end
	endtask

	task op_SLTU;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b1000;
		end
	endtask
	
	task op_SLT;
		begin
			A = $random;
			B = $random;
			ALU_control = 4'b1001;
		end
	endtask
	
	assert property (@(posedge CLOCK) (ALU_control == 4'b0000) |-> (ALU_result = A + B))	else	$error("La operacion ADD no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b0001) |-> (ALU_result = A + B))	else	$error("La operacion SUB no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b0010) |-> (ALU_result = A + B))	else	$error("La operacion AND no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b0011) |-> (ALU_result = A + B))	else	$error("La operacion OR no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b0100) |-> (ALU_result = A + B))	else	$error("La operacion XOR no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b0101) |-> (ALU_result = A + B))	else	$error("La operacion SLL no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b0110) |-> (ALU_result = A + B))	else	$error("La operacion SRL no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b0111) |-> (ALU_result = A + B))	else	$error("La operacion SRA no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b1000) |-> (ALU_result = A + B))	else	$error("La operacion SLTU no se ha realizado de manera correcta");
	assert property (@(posedge CLOCK) (ALU_control == 4'b1001) |-> (ALU_result = A + B))	else	$error("La operacion SLT no se ha realizado de manera correcta");

	initial 
	begin
	$display("Running testbench");
	@(negedge CLOCK)
	op_ADD();
	@(negedge CLOCK)
	op_SUB();
	@(negedge CLOCK)
	op_AND();
	@(negedge CLOCK)
	op_OR();
	@(negedge CLOCK)
	op_XOR();
	@(negedge CLOCK)
	op_SLL();
	@(negedge CLOCK)
	op_SRL();
	@(negedge CLOCK)
	op_SRA();
	@(negedge CLOCK)
	op_SLTU();
	@(negedge CLOCK)
	op_SLT();
	repeat(5) @(negedge CLOCK)
		
	$stop;
	end

	
endmodule
