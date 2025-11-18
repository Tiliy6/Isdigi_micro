`timescale 1ns/1ps
	module tb_banco_registros();
	
	logic 		CLK;
	logic [4:0] rReg1, rReg2, wReg;
	logic 		RegWrite;
	logic [31:0]	wData, rData1, rData2;
	
	
	banco_registros (
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
		CLK = 1'b0;
		CLK = #50 1'b1;
		#50;
	end
	
	
	
	task x0_a_cero;
		begin
			wreg = 0;
			wData = 4'h00A1;
			rReg1 = 0;
			@(posedge CLK)
			assert (rData1 == 0) else $error("El primer valor del banco  de registros no es 0")
		end
	endtask
	
	
	task lectura_escritura_smultanea;
		begin
			wReg  = 5'b01101;
			wData = 4'hA234;
			repeat(2) @(posedge CLK)
			rReg1 = 5'b01101;
			@(rData1)
			assert (radata1 == 4'hA234) else $error("No escribe correctamente")
			
		end
	endtask
			
			
	
endmodule
			
			
			