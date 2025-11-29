`timescale 1ns/1ps
module prueba_multiplicador();
// constants                                           
// general purpose registers
reg CLK;
reg RESET;

//instanciacion del interfaz
test_if interfaz(.reloj(CLK),.reset(RESET));

//instanciacion del disenyo                  
 top_duv duv (.bus(interfaz));
            
//instanciacion del program  
estimulos estim1 (.testar(interfaz),.monitorizar(interfaz));  

// CLK
always
begin
	CLK = 1'b0;
	CLK = #50 1'b1;
	#50;
end 

// RESET
initial
begin
  RESET=1'b1;
  # 1  RESET=1'b0;
  #99 RESET = 1'b1;
end 

//volcado de valores para el visualizados
  
initial begin
  $dumpfile("multiplicador.vcd");
  $dumpvars(1,prueba_multiplicador.duv.multiplicador_duv.A);
  $dumpvars(1,prueba_multiplicador.duv.multiplicador_duv.B);
  $dumpvars(1,prueba_multiplicador.duv.multiplicador_duv.S);
end  
endmodule
