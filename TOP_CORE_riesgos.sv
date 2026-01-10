module TOP_CORE_riesgos(instr, CLOCK, RST_n, dataram_rd, PC, ena_wr, ena_rd, alu_out_ext, dataram_wr);

input [31:0] instr;
input RST_n, CLOCK;
input  logic [31:0] dataram_rd;

output logic [31:0] PC;
output logic ena_wr, ena_rd; //entrada habilita ram lectura/escritura
output logic [31:0] alu_out_ext; //entrada ram
output logic [31:0] dataram_wr;

logic [31:0] datareg_wr; //salida mux memtoreg
logic [31:0] PC_siguiente;
logic [3:0] instruction_bits_sig, ALU_operation;
logic PCSrc;

//ID
logic [31:0] PC_ID, instr_ID, readData1_ID, readData2_ID, inm_out_ID;
logic        Branch_ID, MemRead_ID, MemWrite_ID, RegWrite_ID, AluSrc_ID, Jal_ID, Jalr_ID;
logic [2:0]  AluOp_ID;
logic [1:0]  MemtoReg_ID, AuipcLui_ID;

//EX
logic        RegWrite_EX, Branch_EX, MemRead_EX, MemWrite_EX, AluSrc_EX, Jal_EX, Jalr_EX, zero_EX;
logic [1:0]  MemtoReg_EX, AuipcLui_EX;
logic [2:0]  AluOp_EX;
logic [31:0] PC_EX, PC4, readData1_EX, readData2_EX, inm_out_EX, instr_EX, valor_A, valor_B, alu_out_ext_EX, PC_inm;

//MEM
logic        RegWrite_MEM, Branch_MEM, MemRead_MEM, MemWrite_MEM, zero_MEM, Jal_MEM, Jalr_MEM;
logic [1:0]  MemtoReg_MEM;
logic [31:0] PC4_MEM, alu_out_ext_MEM, readData2_MEM, PC_inm_MEM, instr_MEM;

//WB
logic        RegWrite_WB;
logic [1:0]  MemtoReg_WB;
logic [31:0] PC4_WB ,alu_out_ext_WB, dataram_rd_WB, instr_WB;

//FORWARDING UNIT
logic [1:0] ForwardA, ForwardB;
logic [4:0] sourceA_EX, sourceB_EX, destino_MEM, destino_WB;
logic [31:0] readData2_EX_fwd, A_fwd, bypass_MEM;

//HAZARD UNIT
logic stall, PCWrite, IFIDWrite, usa_source2_ID;
logic [4:0] source1_ID, source2_ID, destino_EX;
logic [6:0] opcode_ID;

//FLUSH
logic flush_IFID, flush_IDEX, ctrl_taken, flush_EXMEM;

logic branch_taken_MEM;
logic [2:0] funct3_MEM;



always_ff @(posedge CLOCK or negedge RST_n)
	begin
	if (!RST_n)
		PC <= '0;
	else  if (PCWrite) //podemos congelar PC con PCWrite
		PC <= PC_siguiente;
	end

assign PC_siguiente = Jalr_MEM ? alu_out_ext_MEM : PCSrc ? PC_inm_MEM : (PC + 4); // para las señales Jal y Jalr; la señal Jal pone a 1 directamente el PCSrc

assign ctrl_taken = PCSrc || Jalr_MEM;
assign flush_IFID = ctrl_taken;
assign flush_IDEX = ctrl_taken;
assign flush_EXMEM  = ctrl_taken;


//------------IF/ID + RST------------
always_ff @(posedge CLOCK or negedge RST_n)
	begin
	if (!RST_n)
		begin
		PC_ID <= '0;
		instr_ID <= '0;
		end
	else if (flush_IFID) begin
		PC_ID    <= '0;
		instr_ID <= 32'b0;
		end
	else if (IFIDWrite) //podemos congelar el registro con IFIDWrite
		begin
		PC_ID    <= PC;
      instr_ID <= instr;
		end
	end


banco_registros banco_registros_inst
(
	.CLK(CLOCK),						// input  CLK
	.RST_n(RST_n),						// input  RST_n
	.readReg1(instr_ID[19:15]),	// input [4:0] readReg1
	.readReg2(instr_ID[24:20]),	// input [4:0] readReg2
	.writeReg(instr_WB[11:7]),		// input [4:0] writeReg
	.writeData(datareg_wr),			// salida mux MemtoReg						
	.readData1(readData1_ID),		// output [31:0] readData1
	.readData2(readData2_ID),		// output [31:0] readData2
	.RegWrite(RegWrite_WB) 		// input  RegWrite
);


Inm_Gen Inm_Gen_inst
(
	.inst(instr_ID[31:0]) ,	// input [31:0] inst
	.inm(inm_out_ID) 	// output [31:0] inm
);


CONTROL CONTROL_inst
(
	.instruction(instr_ID),	// input [31:0] instruction
	.Branch(Branch_ID),		// output  Branch
	.MemRead(MemRead_ID),	// output  MemRead
	.MemtoReg(MemtoReg_ID),	// output  MemtoReg
	.ALUOp(AluOp_ID),			// output [2:0] ALUOp
	.MemWrite(MemWrite_ID),	// output  MemWrite
	.ALUSrc(AluSrc_ID),		// output  ALUSrc
	.RegWrite(RegWrite_ID),	// output  RegWrite
	.AuipcLui(AuipcLui_ID),	// output [1:0] AuipcLui
	.Jal(Jal_ID),
	.Jalr(Jalr_ID)
);

//HAZARD DETECTION
assign source1_ID = instr_ID[19:15];
assign source2_ID = instr_ID[24:20];
assign destino_EX = instr_EX[11:7];
assign opcode_ID = instr_ID[6:0];

assign usa_source2_ID = (opcode_ID == 7'b0110011) || //Tipo R
							(opcode_ID == 7'b0100011) || //Tipo S
							(opcode_ID == 7'b1100011); //Tipo B
							
assign stall = MemRead_EX && (destino_EX != 5'd0) && ((destino_EX == source1_ID) || (usa_source2_ID && (destino_EX == source2_ID)));

assign PCWrite   = ctrl_taken ? 1'b1 : !stall;
assign IFIDWrite = !stall;


//------------ID/EX + RST------------
always_ff @(posedge CLOCK or negedge RST_n)
begin
	if (!RST_n)
	begin
		RegWrite_EX <= 0;
		MemtoReg_EX <= 0;
		Branch_EX <= 0;
		MemRead_EX <= 0;
		MemWrite_EX <= 0;
		AluOp_EX <= 0;
		AluSrc_EX <= 0;
		AuipcLui_EX <= 0;
		Jal_EX <= 0;
		Jalr_EX <= 0;
		PC_EX <= 0;
		readData1_EX <= 0;
		readData2_EX <= 0;
		inm_out_EX <= 0;
		instr_EX <= 0;
	end
	else if (flush_IDEX) begin
		RegWrite_EX <= 0;
		MemtoReg_EX <= 0;
		Branch_EX <= 0;
		MemRead_EX <= 0;
		MemWrite_EX <= 0;
		AluOp_EX <= 0;
		AluSrc_EX <= 0;
		AuipcLui_EX <= 0;
		Jal_EX <= 0;
		Jalr_EX <= 0;
		PC_EX <= 0;
		readData1_EX <= 0;
		readData2_EX <= 0;
		inm_out_EX <= 0;
		instr_EX <= 0;
	end
	else if (stall) //NOP
	begin
		RegWrite_EX <= 0;
		MemtoReg_EX <= 0;
		Branch_EX <= 0;
		MemRead_EX <= 0;
		MemWrite_EX <= 0;
		AluOp_EX <= 0;
		AluSrc_EX <= 0;
		AuipcLui_EX <= 0;
		Jal_EX <= 0;
		Jalr_EX <= 0;
		PC_EX <= 0;
		readData1_EX <= 0;
		readData2_EX <= 0;
		inm_out_EX <= 0;
		instr_EX <= 0;
	end
	else
	begin
		RegWrite_EX <= RegWrite_ID;
		MemtoReg_EX <= MemtoReg_ID;
		Branch_EX <= Branch_ID;
		MemRead_EX <= MemRead_ID;
		MemWrite_EX <= MemWrite_ID;
		AluOp_EX <= AluOp_ID;
		AluSrc_EX <= AluSrc_ID;
		AuipcLui_EX <= AuipcLui_ID;
		Jal_EX <= Jal_ID;
		Jalr_EX <= Jalr_ID;
	
		PC_EX <= PC_ID;
	
		readData1_EX <= readData1_ID;
		readData2_EX <= readData2_ID;
	
		inm_out_EX <= inm_out_ID;
	
		instr_EX <= instr_ID;
	end
end

assign PC4 = PC_EX + 4;

//FORWARDING UNIT
assign sourceA_EX = instr_EX[19:15];
assign sourceB_EX = instr_EX[24:20];
assign destino_MEM = instr_MEM[11:7];
assign destino_WB  = instr_WB[11:7];

always_comb begin
    if (RegWrite_MEM && (destino_MEM != 5'd0) && (destino_MEM == sourceA_EX))
        ForwardA = 2'b10;
    else if (RegWrite_WB && (destino_WB != 5'd0) && (destino_WB == sourceA_EX))
        ForwardA = 2'b01;
    else
        ForwardA = 2'b00;
end

always_comb begin
    if (RegWrite_MEM && (destino_MEM != 5'd0) && (destino_MEM == sourceB_EX))
        ForwardB = 2'b10;
    else if (RegWrite_WB && (destino_WB != 5'd0) && (destino_WB == sourceB_EX))
        ForwardB = 2'b01;
    else
        ForwardB = 2'b00;
end


assign bypass_MEM = MemRead_MEM ? dataram_rd : alu_out_ext_MEM;
assign readData2_EX_fwd = (ForwardB == 2'b10) ? bypass_MEM : (ForwardB == 2'b01) ? datareg_wr : readData2_EX; //para obtener readData2 con forwarding (store forwarding)


//Mux 3 a 1 para entrada A de la ALU

	 assign A_fwd = (ForwardA == 2'b10) ? bypass_MEM : (ForwardA == 2'b01) ? datareg_wr : readData1_EX;
	 
    always_comb begin
        case (AuipcLui_EX)
            2'b00: valor_A = PC_EX;        
            2'b01: valor_A = 32'd0; 
            default: valor_A = A_fwd;
        endcase
    end


assign valor_B = AluSrc_EX ? inm_out_EX : readData2_EX_fwd; //mux que selecciona entrada B alu		


ALU ALU_inst
(
	.A(valor_A),	// mux 3 a 1 
	.B(valor_B),	// mux indica si ReadData2 o immGen, seleccion=ALUSrc
	.ALU_control(ALU_operation),	// controlado por modulo alu control
	.ALU_result(alu_out_ext_EX),	// decision del salto
	.zero(zero_EX) 	// output  zero_sig
);


assign instruction_bits_sig = {instr_EX[30],instr_EX[14:12]};


ALU_CONTROL ALU_CONTROL_inst
(
	.ALUOp(AluOp_EX),
	.instruction_bits(instruction_bits_sig),
	.ALU_control(ALU_operation)
);


assign PC_inm = PC_EX + inm_out_EX;


//------------EX/MEM + RST------------
always_ff @(posedge CLOCK or negedge RST_n)
begin
	if (!RST_n)
	begin
		PC4_MEM <= 0;
		RegWrite_MEM <= 0;
		MemtoReg_MEM <= 0;
		Branch_MEM <= 0;
		MemRead_MEM <= 0;
		MemWrite_MEM <= 0;
		zero_MEM <= 0;
		alu_out_ext_MEM <= 0;
		Jal_MEM <= 0;
		Jalr_MEM <= 0;
		PC_inm_MEM <= 0;
		readData2_MEM <= 0;
		instr_MEM <= 0;
	end
	else if (flush_EXMEM)
	begin
		PC4_MEM <= 0;
		RegWrite_MEM <= 0;
		MemtoReg_MEM <= 0;
		Branch_MEM <= 0;
		MemRead_MEM <= 0;
		MemWrite_MEM <= 0;
		zero_MEM <= 0;
		alu_out_ext_MEM <= 0;
		Jal_MEM <= 0;
		Jalr_MEM <= 0;
		PC_inm_MEM <= 0;
		readData2_MEM <= 0;
		instr_MEM <= 0;
	end
	else
	begin
		PC4_MEM <= PC4;
		RegWrite_MEM <= RegWrite_EX;
		MemtoReg_MEM <= MemtoReg_EX;
		Branch_MEM <= Branch_EX;
		MemRead_MEM <= MemRead_EX;
		MemWrite_MEM <= MemWrite_EX;
		zero_MEM <= zero_EX;
		alu_out_ext_MEM <= alu_out_ext_EX;
		Jal_MEM <= Jal_EX;
		Jalr_MEM <= Jalr_EX;
		PC_inm_MEM <= PC_inm;
		instr_MEM <= instr_EX;
		readData2_MEM <= readData2_EX_fwd;
	end
end

assign funct3_MEM = instr_MEM[14:12];


always_comb begin
	branch_taken_MEM = 1'b0;
	if (Branch_MEM) begin
		case (funct3_MEM)
			3'b000: branch_taken_MEM = zero_MEM;
			3'b001: branch_taken_MEM = zero_MEM;
			3'b100: branch_taken_MEM = alu_out_ext_MEM[0];
			3'b110: branch_taken_MEM = alu_out_ext_MEM[0];
			3'b101: branch_taken_MEM = !alu_out_ext_MEM[0];
			3'b111: branch_taken_MEM = !alu_out_ext_MEM[0];
			default: branch_taken_MEM = 1'b0;
		endcase
	end
end

	
assign PCSrc = branch_taken_MEM || Jal_MEM;
assign ena_wr = MemWrite_MEM;
assign ena_rd = MemRead_MEM;
assign dataram_wr = (MemWrite_MEM && RegWrite_WB && (destino_WB != 5'd0) && (destino_WB == instr_MEM[24:20])) ? datareg_wr : readData2_MEM;



//------------MEM/WB + RST------------
always_ff @(posedge CLOCK or negedge RST_n)
begin
	if (!RST_n)
	begin
		PC4_WB <= 0;
		instr_WB <= 0;
		RegWrite_WB <= 0;
		MemtoReg_WB <= 0;
		alu_out_ext_WB <= 0;
		dataram_rd_WB <= 0;
	end
	else
	begin
		PC4_WB <= PC4_MEM;
		instr_WB <= instr_MEM;
		RegWrite_WB <= RegWrite_MEM;
		MemtoReg_WB <= MemtoReg_MEM;
		alu_out_ext_WB <= alu_out_ext_MEM;
		dataram_rd_WB <= dataram_rd;
	end
end


assign datareg_wr = (MemtoReg_WB == 2'b01) ? dataram_rd_WB : ((MemtoReg_WB == 2'b00) ? alu_out_ext_WB : PC4_WB); //Write data en banco de registros
assign alu_out_ext = alu_out_ext_MEM;

endmodule
