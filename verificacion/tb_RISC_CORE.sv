class instruccionRandom;
  rand logic instruccion;
  constraint R_format {
	instruccion[6:0] == 7'b0110011;
	instruccion[31:25] == 7'b0000000 ||
	instruccion[31:25] == 7'b0100000 && instruccion[14:12] == 3'b000 ||
	instruccion[31:25] == 7'b0100000 && instruccion[14:12] == 3'b101;
	} //fijamos opcode, randomizamos funct7 entre 2 valores
  constraint I_format {
	instruccion[6:0] == 7'b0010011;
	instruccion[31:25] == 7'b0000000 && instruccion[14:12] == 3'b001 ||
	instruccion[31:25] == 7'b0000000 && instruccion[14:12] == 3'b101 ||
	instruccion[31:25] == 7'b0100000 && instruccion[14:12] == 3'b101;
	}
  constraint S_format {
	instruccion[6:0] == 7'b0100011;
	instruccion[14:12] == 3'b010;
	} //solo instruccion SW
  
  constraint B_format {
	instruccion[6:0] == 7'b1100011;
	}
	
	constraint U_format {
	instruccion[6:0] == 7'b0010111;
	}
	
	constraint J_format {
	instruccion[6:0] == 7'b1101111;
	}
endclass

//AÑADIR COVERGROUP PARA CAMPOS DE INSTRUCCION Y PARA INMEDIATOS HACER CROSS ENTRE RD RS1 FUN3 Y RS2

`timescale 1ns/1ps
	module tb_TOP_CORE();
	localparam T = 20;
	
	logic 		CLOCK, RST_n;
	logic [31:0] PC_addr, instr_rom, alu_result, datareg_wr_sig, dataram_wr_sig, dout_ram;
	logic MemtoReg_mux, ena_wr_sig, ena_rd_sig;
	
	
	TOP_CORE TOP_CORE_inst
	(
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
	
	
	covergroup R_type;    
	coverpoint rd;
	coverpoint rs1;
	coverpoint rs2;
	coverpoint funct3;
	cross rd, rs1, rs2, func3;
	endgroup;
	
	covergroup I_type;    
	coverpoint rd;
	coverpoint rs1;
	coverpoint funct3;
	cross rd, rs1, func3;
	endgroup;
	
	covergroup S_type;    
	coverpoint  rs1;
	coverpoint rs2;
	coverpoint inmediato;
	cross rs1, rs2, inmediato;
	endgroup;
	
	covergroup B_type;    
	coverpoint  X;
	coverpoint Y;
	cross X,Y;
	endgroup;
	
	covergroup U_type;    
	coverpoint  X;
	coverpoint Y;
	cross X,Y;
	endgroup;
	
	covergroup J_type;    
	coverpoint  X;
	coverpoint Y;
	cross X,Y;
	endgroup;
	
	
	 always
	 begin
	 #(T/2) CLOCK = ~CLOCK;
	 end
	
	//ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLTU, SLT
	task R_type;
		begin
			instruccion[6:0] = 6'b0110011;
			
			RST_n = 0;
			RegWrite = 1;
			wReg = 0;
			wData = 4'h00A1;
			rReg1 = 0;
			@(negedge CLOCK);
			RST_n = 1;
			assert (rData1 == 0) else $error("El primer valor del banco  de registros no es 0");
		end
	endtask
	
	
	task escritura_correcta;
		begin
			wReg  = 5'b01101;
			wData = 4'hA234;
			repeat(2) @(negedge CLOCK);
			rReg1 = 5'b01101;
			@(negedge CLOCK);
			assert (rData1 == 4'hA234) else $error("No escribe correctamente");
			
		end
	endtask

		
	task lectura_escritura_simultanea;
		begin
			RegWrite = 1;
			wReg = 5'b10000;
			wData = 4'h1234;
			@(negedge CLOCK);
			wReg = 5'b11000;
			wData = 4'h2345;
			@(negedge CLOCK);
			rReg1 = 5'b10000;
			rReg2 = 5'b11000;
			@(negedge CLOCK);
			assert (rData1 == 4'h1234 && rData2 == 4'h2345) else $error("La lectura no es simultanea");
		end
	endtask
			
			
	initial
	begin
	CLOCK = 0;
	RegWrite = 0;
    rReg1 = 0;
	rReg2 = 0;
	wReg = 0;
	wData = 0;
	@(negedge CLOCK);
	x0_a_cero();
	@(negedge CLOCK);
	escritura_correcta();
	@(negedge CLOCK);
	lectura_escritura_simultanea();
	@(negedge CLOCK);
	$display("Test finished");
   $stop;
	end
	
endmodule
