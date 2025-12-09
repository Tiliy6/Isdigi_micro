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

	
//Valores de la ROM de fibonacci.txt
	localparam logic [31:0] pos0 = 32'h10000197;
	localparam logic [31:0] pos1 = 32'h00a00393;
	localparam logic [31:0] pos2 = 32'h00818413;
	localparam logic [31:0] pos3 = 32'h00418493;


initial
	begin
	CLK = 0;
	address = 0;

 //Comprobacion de los valores
	address = 8'd0;
		#3 assert(instruction == pos0)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
		
	address = 8'd1;
		#3 assert(instruction == pos1)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
		
	address = 8'd2;
		#3 assert(instruction == pos2)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
		
	address = 8'd3;
		#3 assert(instruction == pos3)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(negedge CLK)
	$display("Simulacion finalizada");
	$stop;
	end
	
endmodule	



