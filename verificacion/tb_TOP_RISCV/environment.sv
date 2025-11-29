package utilidades_verificacion;

class puntero;
    logic [31:0] pc, instr, alu_result, wb_data, din, dout;
    logic memtoreg, memwrite, memread;
endclass

class Scoreboard;
  puntero cola_targets [$];
  logic [31:0] expected;
  logic [31:0] last_pc = 32'hFFFF_FFFF;
  virtual test_if.monitor mports;
  
  function new (virtual test_if.monitor mpuertos);
  begin
    this.mports = mpuertos;
  end
  endfunction
    
 function logic [31:0] modelo_ideal(puntero t);
	logic [31:0] instr   = t.instr;
   logic [6:0] opcode   = instr[6:0];
   logic [2:0] funct3   = instr[14:12];
   logic [6:0] funct7   = instr[31:25];
   logic [31:0] immI    = {{20{instr[31]}}, instr[31:20]};
   logic [31:0] immU    = {instr[31:12], 12'b0};
   logic [31:0] immB    = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
	
   //R-TYPE: ADD, SUB
   if (opcode == 7'b0110011)
		begin
		if (funct3 == 3'b000 && (funct7 == 7'b0000000 || funct7 == 7'b0100000))
        return t.alu_result;
		else
        return 32'hXXXX_XXXX;
      end
		
    //I-TYPE: ADDI
    if (opcode == 7'b0010011 && funct3 == 3'b000)
		return t.alu_result;

    //LW
    if (opcode == 7'b0000011 && funct3 == 3'b010)
      return t.dout;

    //SW
    if (opcode == 7'b0100011)
      return 32'hXXXX_XXXX;

    //BRANCH: BEQ
     if (opcode == 7'b1100011)
      return 32'hXXXX_XXXX;
		
    //LUI
     if (opcode == 7'b0110111)
      return immU;
		
    //AUIPC
     if (opcode == 7'b0010111)
      return t.pc + immU;

	  return 32'hXXXX_XXXX;

 endfunction
   
 task monitor_input;
	puntero t;
   begin
     while (1)
       begin       
         @(mports.md);
         if (!$isunknown(mports.md.PC_addr) && mports.md.PC_addr!=last_pc)
				begin
				last_pc = mports.md.PC_addr;
				t = new();
				t.pc         = mports.md.PC_addr;
				t.instr      = mports.md.instr_rom;
				t.alu_result = mports.md.alu_result;
				t.wb_data    = mports.md.datareg_wr_sig;
				t.memtoreg   = mports.md.MemtoReg_mux;
				t.memwrite   = mports.md.ena_wr_sig;
				t.memread    = mports.md.ena_rd_sig;
				t.din        = mports.md.dataram_wr_sig;
				t.dout       = mports.md.dout_ram;
				cola_targets.push_front(t);
				end
		 end
   end
  endtask
 
  task monitor_output;
	puntero t;
   begin
		while (1)
		begin       
			@(mports.md);
			if (cola_targets.size() > 0)
				begin
				t = cola_targets.pop_back();
				expected = modelo_ideal(t);
				if (expected !== 32'hXXXX_XXXX)
					begin
					logic [31:0] wb_actual = mports.md.datareg_wr_sig;
					assert (wb_actual == expected) else $error("ERROR: PC=%h INSTR=%h WB=%h EXPECTED=%h", t.pc, t.instr, wb_actual, expected);
					end
				end
		 end
   end
  endtask 
endclass 
    
	 
class enviroment;

  virtual test_if.test testar_ports;
  virtual test_if.monitor monitorizar_ports;
  

//declaraciones de objetos
Scoreboard sb;


function new(virtual test_if.test ports, virtual test_if.monitor mports);
	this.testar_ports = ports;
	this.monitorizar_ports = mports;
	sb = new(monitorizar_ports);
endfunction

  // muestreo
  task muestrear;
    fork
      sb.monitor_input();
      sb.monitor_output();
    join_none
  endtask

  // prueba directa deja correr el RISCV
  task prueba_directa;
    $display("== PRUEBA DIRECTA ==");
    repeat(200) @(testar_ports.sd);
  endtask

  // ejemplo de prueba random cargas ROMs aleatorias
  task prueba_random;
    $display("Lanzando prueba random RISCV");
    repeat(20)
	 begin
      repeat(200) @(testar_ports.sd);
    end
  endtask
endclass

endpackage
