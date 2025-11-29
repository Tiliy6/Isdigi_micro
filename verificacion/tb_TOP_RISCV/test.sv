program estimulos
  (test_if.test testar,
   test_if.monitor monitorizar  
  );
  
  utilidades_verificacion::enviroment casos = new(testar, monitorizar);     //declaración e instanciación objeto                 


initial
begin
casos.muestrear;
  $display("hacemos un test directo");
  casos.prueba_directa;
  $display("functional coverage after prueba_directa  is %e", casos.valores_X.idea1.get_coverage());
// $stop;       

  $display("hacemos un test random de positivos");
  casos.prueba_random_pos_pos;
  $display("functional coverage after prueba_random_pos_pos  is %e", casos.valores_X.idea1.get_coverage());
//  $stop;  
           
  $display("hacemos un test random de negativos");
  casos.prueba_random_neg_neg;
  $display("functional coverage after prueba_random_neg_neg  is %e", casos.valores_X.idea1.get_coverage());
//  $stop;

  $display("hacemos un test random de X positivos e Y negativos");
  casos.prueba_random_pos_neg;
  $display("functional coverage after prueba_random_pos_neg  is %e", casos.valores_X.idea1.get_coverage());
//  $stop;

  $display("hacemos un test random de X negativos e Y positivos");
  casos.prueba_random_neg_pos;
  $display("functional coverage after prueba_random_neg_pos  is %e", casos.valores_X.idea1.get_coverage());
//  $stop;

  $display("hacemos un test random de valores extremos");
  casos.prueba_extremosXY;
  $display("functional coverage after prueba_random_extremosXY  is %e", casos.extremos_XY.crossXY.get_coverage());
  $stop;
end
endprogram
