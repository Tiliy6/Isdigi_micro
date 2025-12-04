class instruccionRandom;
	rand logic [31:0] instruccion;
	logic [4:0] rs1, rs2, rd;
	logic [2:0] funct3;
	logic [11:0] inmediato;
	
	constraint R_format {
		instruccion[6:0] == 7'b0110011;
		instruccion[31:25] == 7'b0000000 ||
		instruccion[31:25] == 7'b0100000 && instruccion[14:12] == 3'b000 ||
		instruccion[31:25] == 7'b0100000 && instruccion[14:12] == 3'b101;
		} //fijamos opcode, acotamos funct7 entre 2 valores
	/*constraint I_format {
		instruccion[6:0] == 7'b0010011;
		instruccion[31:25] == 7'b0000000 && instruccion[14:12] == 3'b001 ||
		instruccion[31:25] == 7'b0000000 && instruccion[14:12] == 3'b101 ||
		instruccion[31:25] == 7'b0100000 && instruccion[14:12] == 3'b101;
		} //fijamos opcode, acotamos los ultimos bits segun el valor de funct3
	constraint carga_format {
		instruccion[6:0] == 7'b0000011;
		instruccion[14:12] == 3'b010;
		} //solo instruccion LW
	constraint S_format {
		instruccion[6:0] == 7'b0100011;
		instruccion[14:12] == 3'b010;
		} //solo instruccion SW
	  
	constraint B_format {
		instruccion[6:0] == 7'b1100011;
		} //fijamos opcode
		
	constraint U_format {
		instruccion[6:0] == 7'b0010111;
		} //fijamos opcode
		
	/* No incluimos el J_format porque la operacion JAL no es de la fase 2
	constraint J_format {
		instruccion[6:0] == 7'b1101111;
		} //fijamos opcode
	*/
	
	function void partes_instruccion(); //funcion para asignar los bits de la instruccion a su parte correspondiente tras randomizar
		rs1 = instruccion [19:15];
		rs2 = instruccion [24:20];
		rd = instruccion [11:7];
		funct3 = instruccion [14:12];
		case (instruccion[6:0])
			7'b0010011: inmediato = instruccion [31:20]; //I_format
			7'b0000011:	inmediato = instruccion [31:20]; //carga_format
			7'b0100011:	inmediato = {instruccion [31:25], instruccion [11:7]}; //S_format 
			7'b1100011: inmediato = { instruccion [31], instruccion [7], instruccion [30:25], instruccion [11:8] }; //B_format
			7'b0010111:	inmediato = instruccion [31:12]; //U_format
			//7'b0110111: inmediato = instruccion[31:12]; //J_format
			default: inmediato = '0;
		endcase
	endfunction
	
endclass


`timescale 1ns/1ps
	module tb_TOP_CORE();
	localparam T = 20;
	
	logic CLOCK, RST_n;
	logic [31:0] PC_addr, instr_rom, alu_result, datareg_wr_sig, dataram_wr_sig, dout_ram;
	logic MemtoReg_mux, ena_wr_sig, ena_rd_sig;
	
	logic [31:0] [31:0] registro;
	instruccionRandom instr;
	
	
	TOP_CORE duv (
	.instr(instr_sig) ,	// input [31:0] instr_sig
	.datareg_wr(datareg_wr_sig) ,	// input [31:0] datareg_wr_sig
	.CLOCK(CLOCK_sig) ,	// input  CLOCK_sig
	.RST_n(RST_n_sig) ,	// input  RST_n_sig
	.PC(PC_sig) ,	// output [31:0] PC_sig
	.ena_wr(ena_wr_sig) ,	// output  ena_wr_sig
	.ena_rd(ena_rd_sig) ,	// output  ena_rd_sig
	.alu_out_ext(alu_out_ext_sig) ,	// output [31:0] alu_out_ext_sig
	.MemtoReg_sig(MemtoReg_sig_sig) ,	// output  MemtoReg_sig_sig
	.dataram_wr(dataram_wr_sig) 	// output [31:0] dataram_wr_sig
	);

	
	//COVERGROUPS
	covergroup R_type;    
	coverpoint instr.rd;
	coverpoint instr.rs1;
	coverpoint instr.rs2;
	coverpoint instr.funct3;
	cross instr.rd, instr.rs1, instr.rs2, instr.funct3;
	endgroup;
	
	/*covergroup I_type;    
	coverpoint rd;
	coverpoint rs1;
	coverpoint funct3;
	cross rd, rs1, funct3;
	endgroup;
	
	covergroup carga_type;    
	coverpoint rd;
	coverpoint rs1;
	coverpoint inmediato;
	cross rd, rs1, inmediato;
	endgroup;
	
	covergroup S_type;    
	coverpoint rs1;
	coverpoint rs2;
	coverpoint inmediato;
	cross rs1, rs2, inmediato;
	endgroup;
	
	covergroup B_type;    
	coverpoint rs1;
	coverpoint rs2;
	coverpoint funct3;
	coverpoint inmediato;
	cross rs1, rs2, funct3, inmediato;
	endgroup;
	
	covergroup U_type;
	coverpoint rd;    
	coverpoint inmediato;
	cross rd,inmediato;
	endgroup;
	
	/* No incluimos el J_format porque la operacion JAL no es de la fase 2
	covergroup J_type;    
	coverpoint rd;    
	coverpoint inmediato;
	cross rd,inmediato;
	endgroup;
	*/
	
	
	//DEFINICION DEL CLOCK
	always
	begin
	#(T/2) CLOCK = ~CLOCK;
	end
	
	
	//INSTRUCCIONES A COMPROBAR
	//(ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND) R
	//(ADDi, SLTi, SLTiU, XORi, ORi, ANDi, SLLi, SRLi, SRAi) I
	//(LW) carga
	//(SW) S
	//(BEQ, BNE, BGE) B
	//(LUI, AUIPC) U
	
	task automatic R_instructions;
		reg [31:0] valor_rs1 = registro[instr.rs1];
		reg [31:0] valor_rs2 = registro[instr.rs2];
		reg [31:0] resultado_esperado;
		R_type R_cov = new();
		while (R_cov.get_coverage()<80)
			begin
				//desactivamos todas
				instr.R_format.constraint_mode(0);
				/*I_format.constraint_mode(0);
				carga_format.constraint_mode(0);
				S_format.constraint_mode(0);
				B_format.constraint_mode(0);
				U_format.constraint_mode(0);*/
				//activamos constraint
				instr.R_format.constraint_mode(1);
				
				//randomizamos
				instr = new();
				assert (instr.randomize()) else $fatal("randomization failed");
				instr.partes_instruccion();
				
				case(instr.funct3)
					3'b000: if(instr.instruccion [31:25] == 7'b0000000)
									resultado_esperado = valor_rs1 + valor_rs2; //ADD
							  else
									resultado_esperado = valor_rs1 - valor_rs2; //SUB
					3'b001: resultado_esperado = valor_rs1 << valor_rs2 [4:0]; //SLL
					3'b010: resultado_esperado = ($signed(valor_rs1) < $signed(valor_rs2)) ? 32'd1 : 32'd0; //SLT
					3'b011: resultado_esperado = (valor_rs1 < valor_rs2) ? 32'd1 : 32'd0; //SLTU
					3'b100: resultado_esperado = valor_rs1 ^ valor_rs2; //XOR
					3'b101: if(instr.instruccion [31:25] == 7'b0000000)
									resultado_esperado = valor_rs1 >> valor_rs2 [4:0]; //SRL
								else
									resultado_esperado = $signed(valor_rs1) >>> valor_rs2 [4:0]; //SRA
					3'b110:	resultado_esperado = valor_rs1 | valor_rs2; //OR
					3'b111: resultado_esperado = valor_rs1 & valor_rs2; //AND
					default: resultado_esperado = '0;
				endcase
				assert (alu_out_ext_sig==resultado_esperado) else $error("operacion tipo R mal realizada");
				R_cov.sample();
			end
	endtask
	
			
	initial
	begin
	CLOCK = 0;
	RST_n = 0;
	@(negedge CLOCK);
	RST_n = 1;
	@(negedge CLOCK);
	R_instructions;
	$display("Test finished");
   $stop;
	end
	
endmodule
