`timescale 1ns/1ps
	module tb_banco_registros();
	localparam T = 20;
	
	logic 		CLK;
	logic [4:0] rReg1, rReg2, wReg;
	logic 		RegWrite;
	logic [31:0]	wData, rData1, rData2;
	
	
	banco_registros  duv(
	.CLK(CLK),
	.readReg1(rReg1),
	.readReg2(rReg2),
	.writeReg(wReg),
	.writeData(wData),
	.RegWrite(RegWrite),
	.readData1(rData1),
	.readData2(rData2)
	);
	
	
	 always
	 begin
	 #(T/2) CLK = ~CLK;
	 end
	
	
	
	task x0_a_cero;
		begin
			RegWrite = 1;
			wReg = 0;
			wData = 4'h00A1;
			rReg1 = 0;
			@(negedge CLK);
			assert (rData1 == 0) else $error("El primer valor del banco  de registros no es 0");
		end
	endtask
	
	
	task escritura_correcta;
		begin
			wReg  = 5'b01101;
			wData = 4'hA234;
			repeat(2) @(negedge CLK);
			rReg1 = 5'b01101;
			@(negedge CLK);
			assert (rData1 == 4'hA234) else $error("No escribe correctamente");
			
		end
	endtask
	
	task lectura_escritura_simultanea;
		begin
			RegWrite = 1;
			wReg = 5'b10000;
			wData = 4'h1234;
			@(negedge CLK);
			wReg = 5'b11000;
			wData = 4'h2345;
			@(negedge CLK);
			rReg1 = 5'b10000;
			rReg2 = 5'b11000;
			@(negedge CLK);
			assert (rData1 == 4'h1234 && rData2 == 4'h2345) else $error("La lectura no es simultanea");
		end
	endtask
			
			
	initial
	begin
	CLK = 0;
	RegWrite = 0;
    rReg1 = 0;
	rReg2 = 0;
	wReg = 0;
	wData = 0;
	@(negedge CLK);
	x0_a_cero();
	@(negedge CLK);
	escritura_correcta();
	@(negedge CLK);
	lectura_escritura_simultanea();
	@(negedge CLK);
	$display("Test finished");
    $stop;
	end
	
	
endmodule
