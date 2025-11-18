`timescale 1ns/100ps

module ROM_tb ();

parameter pos = 1024;
parameter num_bits = 32;

logic [$clog2(pos-1):0] address;
logic [num_bits-1:0] instruction;
logic reloj;

ROM rom_inst(

	.addr(address),
	.dout(instruction)
);


always
begin
	reloj = 1'b0;
	forever #10 reloj = ~reloj;
end



initial begin //Valores esperados de la ROM a falta del fichero
	rom_inst.mem[0] = 32'h0ff00013;
	rom_inst.mem[1] = 32'h0ff08093;
	rom_inst.mem[2] = 32'h0ff10113;
	rom_inst.mem[3] = 32'h0ff18193;
end

initial
begin //Comprobacion de los valores
	address = 8'd0;
	#3 assert(instruction == 32'h0ff00013)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(posedge reloj)
		
	address = 8'd1;
	#3 assert(instruction == 32'h0ff08093)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(posedge reloj)
		
	address = 8'd2;
	#3 assert(instruction == 32'h0ff10113)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(posedge reloj)
		
	address = 8'd3;
	#3 assert(instruction == 32'h0ff18193)
		else $error("Error en la lectura de la ROM");
		repeat (5) @(posedge reloj)
	$display("Simulación realizada correctamente");
	$stop;
	
end
	
endmodule	