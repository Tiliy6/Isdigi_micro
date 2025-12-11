`timescale 1ns/1ps
module tb_TOP_CORE();
	localparam T = 20;
	
	logic [31:0] instr, datareg_wr, PC, alu_out_ext, dataram_wr;
	logic CLOCK, RST_n, ena_wr, ena_rd, MemtoReg_sig;
	
	logic [31:0] [31:0] registro; //x0=registro[0],x1=registro[1], ect
	logic [31:0] rs1, rs2; // Contenido de 32 bits
	logic [11:0] inm_orshamt;
	logic [2:0] func3;
	logic [31:0] resultado_esperado;

	TOP_CORE duv (
		.instr(instr) ,
		.datareg_wr(alu_out_ext) ,
		.CLOCK(CLOCK) ,
		.RST_n(RST_n) ,
		.PC(PC) ,
		.ena_wr(ena_wr) ,
		.ena_rd(ena_rd) ,
		.alu_out_ext(alu_out_ext) ,
		.MemtoReg_sig(MemtoReg_sig) ,
		.dataram_wr(dataram_wr) 
	);
	
	class instruccionRandom;
		rand logic [31:0] instr;

		constraint R_format {
			instr[6:0] == 7'b0110011;
			instr[31:25] == 7'b0000000 ||
			instr[31:25] == 7'b0100000 && instr[14:12] == 3'b000 ||
			instr[31:25] == 7'b0100000 && instr[14:12] == 3'b101;
		} 
		
		
		constraint I_format {
			instr[6:0] == 7'b0010011;
			instr[31:25] == 7'b0000000 && instr[14:12] == 3'b001 ||
			instr[31:25] == 7'b0000000 && instr[14:12] == 3'b101 ||
			instr[31:25] == 7'b0100000 && instr[14:12] == 3'b101;
		}
		/*
		constraint carga_format {
			instr[6:0] == 7'b0000011;
			instr[14:12] == 3'b010;
		}
		constraint S_format {
			instr[6:0] == 7'b0100011;
			instr[14:12] == 3'b010;
		}
		constraint B_format {
			instr[6:0] == 7'b1100011;
		}
		constraint U_format {
			instr[6:0] == 7'b0010111;
		}
		*/
	endclass


	// --- COVERGROUPS ---
	
	// R_TYPE (ACTIVO)
	covergroup R_type @(posedge CLOCK); 
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		rs2_cp: coverpoint instr[24:20] {
			bins val[4] = {[0:31]};
		}
		func3_cp: coverpoint instr[14:12] {
			bins val[] = {[0:7]};
		}
		cruceR: cross rd_cp, rs1_cp, rs2_cp, func3_cp;
	endgroup;
	
	
	
	covergroup I_type @(posedge CLOCK); 
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[4] = {[0:31]};
		}
		func3_cp: coverpoint instr[14:12] {
			bins val[] = {[0:7]};
		}
		inm_cp: coverpoint $signed(instr[31:20]) {
			bins val[4] = {[-2048:2047]};
		} 
		cruceI: cross rd_cp, rs1_cp, func3_cp, inm_cp;
	endgroup;
	/* 
	covergroup carga_type @(posedge CLOCK);	
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		rs1_cp: coverpoint instr[19:15] {
			bins val[] = {[0:31]};
		}
		inm_cp: coverpoint instr[31:20] {
			bins val[] = {[0:4095]};
		}
		cruce_carga: cross rd_cp, rs1_cp, inm_cp;
	endgroup;
	
	covergroup S_type @(posedge CLOCK); 
		rs1_cp: coverpoint instr[19:15] {
			bins val[] = {[0:31]};
		}
		rs2_cp: coverpoint instr[24:20] {
			bins val[] = {[0:31]};
		}
		inm_cp: coverpoint {instr[31:25],instr[11:7]} {
			bins val[] = {[0:4095]};
		}
		cruceS: cross rs1_cp, rs2_cp, inm_cp;
	endgroup;
	
	covergroup B_type @(posedge CLOCK); 
		rs1_cp: coverpoint instr[19:15] {
			bins val[] = {[0:31]};
		}
		rs2_cp: coverpoint instr[24:20] {
			bins val[] = {[0:31]};
		}
		func3_cp: coverpoint instr[14:12] {
			bins val[] = {[0:7]};
		}
		inm_cp: coverpoint {instr[31],instr[7],instr[30:25],instr[11:8]} {
			bins val[] = {[-2048:2047]};
		}
		cruceB: cross rs1_cp, rs2_cp, inm_cp;
	endgroup;
	
	covergroup U_type @(posedge CLOCK); 
		rd_cp: coverpoint instr[11:7] {
			bins val[] = {[0:31]};
		}
		inm_cp: coverpoint {instr[31:12]} {
			bins val[] = {[-524288:524287]};
		}
		cruceU: cross rd_cp, inm_cp;
	endgroup;
	*/

	//Declaracion de objetos
	instruccionRandom busInst = new;
	R_type veamosR = new;
	I_type veamosI = new;
	// carga_type veamos_carga = new;
	// S_type veamosS = new;
	// B_type veamosB = new;
	// U_type veamosU = new;
	
	
	//DEFINICION DEL CLOCK
	always
	begin
		#(T/2) CLOCK = ~CLOCK;
	end
	
	// TASK PARA INICIALIZAR REGISTROS (Evita valores 'X')
	task init_registros;
		begin
			for (int i = 0; i < 32; i++) begin
				duv.banco_registros_inst.registro[i] = $random;
			end
			duv.banco_registros_inst.registro[0] = 32'h0; // R0 siempre es 0
		end
	endtask
	
	assign registro = duv.banco_registros_inst.registro;
	
task R_instructions;
		// 1. DECLARACIÓN DE VARIABLES LOCALES (SIEMPRE ARRIBA DEL TODO)		
		begin
			// 2. INICIO DE LA LÓGICA
			busInst.R_format.constraint_mode(1);
			busInst.I_format.constraint_mode(0);

			// ... (otros constraints)

			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr; 
			
			// Lectura secuencial
			rs1 = registro[instr[19:15]];
			rs2 = registro[instr[24:20]];
			func3 = instr[14:12];
			
			// Cálculo ALU
			case(func3)
				 3'b000: begin
					  if(instr[31:25] == 7'b0000000)
							resultado_esperado = rs1 + rs2; 
					  else
							resultado_esperado = rs1 - rs2; 
				 end
				 3'b001: resultado_esperado = rs1 << rs2[4:0];
				 3'b010: resultado_esperado = ($signed(rs1) < $signed(rs2)) ? 32'd1 : 32'd0;
				 3'b011: resultado_esperado = (rs1 < rs2) ? 32'd1 : 32'd0; 
				 3'b100: resultado_esperado = rs1 ^ rs2;
				 3'b101: begin
					  if(instr[31:25] == 7'b0000000)
							resultado_esperado = rs1 >> rs2[4:0];
					  else
							resultado_esperado = $signed(rs1) >>> rs2[4:0];
				 end
				 3'b110:	resultado_esperado = rs1 | rs2;
				 3'b111: resultado_esperado = rs1 & rs2;
				 default: resultado_esperado = '0;
			endcase
			
			@(negedge CLOCK)
			assert (alu_out_ext == resultado_esperado) else $error("operacion tipo R mal realizada");

			veamosR.sample();
		end
	endtask
	
	task I_instructions;
		begin
			busInst.R_format.constraint_mode(0);
			busInst.I_format.constraint_mode(1);
			
			assert(busInst.randomize()) else $error("Falló randomize()");
			instr = busInst.instr;
			
			rs1 = registro[instr[19:15]];
			inm_orshamt = instr[31:20];
			func3 = instr[14:12];
			case(func3)
				 3'b000: resultado_esperado = rs1 + $signed(inm_orshamt); //addi
				 3'b001: resultado_esperado = rs1 << inm_orshamt[4:0];  //slli
				 3'b010: resultado_esperado = ($signed(rs1) < $signed(inm_orshamt)) ? 32'd1 : 32'd0; //slti
				 3'b011: resultado_esperado = (rs1 < inm_orshamt) ? 32'd1 : 32'd0; //sltiu
				 3'b100: resultado_esperado = rs1 ^ $signed(inm_orshamt); //xori
				 3'b101: begin
					  if(instr[31:25] == 7'b0000000)
							resultado_esperado = rs1 >> inm_orshamt[4:0]; //srli
					  else
							resultado_esperado = $signed(rs1) >>> inm_orshamt[4:0]; //srai
				 end
				 3'b110:	resultado_esperado = rs1 | $signed(inm_orshamt); //ori
				 3'b111: resultado_esperado = rs1 & $signed(inm_orshamt); //andi
				 default: resultado_esperado = '0;
			endcase
			
			@(negedge CLOCK)
			assert (alu_out_ext == resultado_esperado) else $error("operacion tipo I mal realizada");

			veamosI.sample();
			
		end
	endtask
	
	task reset;
		begin
			RST_n = 1'b0; // Activamos Reset
			
			instr = 32'h00000000; 
			datareg_wr = 32'b0; 
			// ----------------------------------------

			repeat(5) @(negedge CLOCK); // Esperamos unos ciclos con el Reset activo
			RST_n = 1'b1; // Soltamos Reset
		end
		endtask
			
	initial
	begin
		CLOCK = 0;
		// Inicializamos memoria		
		reset();
		
		@(negedge CLOCK);
		while (veamosR.cruceR.get_coverage() < 50)
			
			begin
				@(posedge CLOCK)
				init_registros();
				//@(posedge CLOCK)
				#2
				R_instructions;
			end

		@(negedge CLOCK);
		while (veamosI.cruceI.get_coverage() < 30)
			
			begin
				@(posedge CLOCK)
				init_registros();
				//@(posedge CLOCK)
				#2
				I_instructions;
			end
		$display("Test finished");
		$stop;	
	end
	
	
endmodule
