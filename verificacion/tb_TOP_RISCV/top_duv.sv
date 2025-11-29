module top_duv (test_if.duv bus) ; 

multiplicador  multiplicador_duv(
.CLK   (bus.reloj),     // Clock input
.RSTn  (bus.reset),     // Active LOW ASINCRONOUS reset
.A      (bus.data_X), // Data input
.B      (bus.data_Y), // Data input
.S     (bus.data_out),// Data Output
.START    (bus.empieza),   // duv empieza
.Fin_Mult    (bus.termina)     //duv termina
);

endmodule
