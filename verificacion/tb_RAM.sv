`timescale 1ns/1ps

	module tb_RAM();
	localparam T = 20;
	
	parameter ANCHO = 32;        
   parameter LARGO = 1024;
	
	logic 		CLK, write_enable, read_enable;
	logic [$clog2(LARGO)-1:0] addr;
	logic [ANCHO-1:0]  din,dout;
	
	
	RAM duv(
	.CLK(CLK),
	.write_enable(write_enable),
	.read_enable(read_enable),
	.addr(addr),
	.din(din),
	.dout(dout)
	);
	
	
	 always
	 begin
	 #(T/2) CLK = ~CLK;
	 end
	
	
	task escritura_correcta;
		begin
			write_enable = 1'b1;
			read_enable = 1'b1;
			addr  = 10'd13;
			din = 32'hA234;
			repeat(2) @(negedge CLK);
			addr = 10'd13;
			@(negedge CLK);
			assert (dout == 32'hA234) else $error("No escribe correctamente");
		end
	endtask
	
	task lectura_escritura_simultanea;
		begin
			write_enable = 1'b1;
			read_enable = 1'b1;
			addr = 10'd16;
			din = 32'h1234;
			@(negedge CLK);
			write_enable=1'b0;
			@(negedge CLK);
			assert (dout == 32'h1234) else $error("La lectura no es simultanea");
		end
	endtask
			
			
	initial
	begin
	CLK = 0;
	escritura_correcta();
	@(negedge CLK);
	lectura_escritura_simultanea();
	@(negedge CLK);
	$display("Simulacion finalizada");
	$stop;
	end
	
endmodule
		
