`timescale 1ns/100ps

module tb_ROM ();
localparam T = 20;

parameter pos = 1024;
parameter num_bits = 32;

logic [$clog2(pos)-1:0] address;
logic [num_bits-1:0] instruction;
logic CLK;

ROM duv(
	.addr(address),
	.dout(instruction)
);

	 always
	 begin
	 #(T/2) CLK = ~CLK;
	 end

	
initial begin //Valores esperados de la ROM a falta del fichero
	duv.mem[0] = 32'h0ff00013;
	duv.mem[1] = 32'h0ff08093;
	duv.mem[2] = 32'h0ff10113;
	duv.mem[3] = 32'h0ff18193;
end

initial
	begin
	CLK = 0;
	address = 0;

 //Comprobacion de los valores
	address = 8'd0;
	#3 assert(instruction == 32'h0ff00013)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
		
	address = 8'd1;
	#3 assert(instruction == 32'h0ff08093)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
		
	address = 8'd2;
	#3 assert(instruction == 32'h0ff10113)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
		
	address = 8'd3;
	#3 assert(instruction == 32'h0ff18193)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
	$display("Simulacion finalizada");
	$stop;
	end
	
endmodule	
