`timescale 1ns/1ps
	module tb_RAM();
	
	parameter ANCHO = 32            
   parameter LARGO = 1024    
	
	logic 		CLK, write_enable;
	logic [$clog2(LARGO)-1:0] addr;
	logic [ANCHO-1:0]  din,dout;
	
	
	RAM (
	.clk(CLK),
	.write_enable(write_enable),
	.addr(addr),
	.din(din),
	.dout(dout)
	);
	
	
	always
	begin
		CLK = 1'b0;
		CLK = #50 1'b1;
		#50;
	end
	
	
	
	task escritura_correcta;
		begin
			write_enable = 1'b1;
			addr  = 5'b01101;
			din = 4'hA234;
			repeat(2) @(posedge CLK);
			rReg1 = 5'b01101;
			@(dout);
			assert (dout == 4'hA234) else $error("No escribe correctamente");
			
		end
	endtask
	
	task lectura_escritura_simultanea;
		begin
			write_enable = 1'b1;
			addr = 5'b10000;
			din = 4'h1234;
			@(posedge CLK);
			write_enable=1'b0;
			@(dout);
			assert (dout == 4'h1234) else $error("La lectura no es simultanea");
			
			
			
	initial
	begin
	escritura_correcta();
	@(negedge CLK);
	lectura_escritura_simultanea();
	end
	
	
			
			
	
endmodule
			
			
			