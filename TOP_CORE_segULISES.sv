module TOP_CORE_seg(instr, CLOCK, RST_n, dataram_rd, PC, ena_wr, ena_rd, alu_out_ext, dataram_wr);

input [31:0] instr;
input RST_n, CLOCK;
input  logic [31:0] dataram_rd;

output logic [31:0] PC;
output logic ena_wr, ena_rd; //entrada habilita ram lectura/escritura
output logic [31:0] alu_out_ext; //entrada ram
output logic [31:0] dataram_wr;

logic [31:0] datareg_wr; //salida mux memtoreg
logic MemtoReg_sig; //habilita mux de ram
logic [31:0] PC_siguiente;
logic [3:0] instruction_bits_sig;


logic [31:0] PC_ID, instr_ID, readData1_ID, readData2_ID, inm_out_ID;
logic        Branch_ID, MemRead_ID, MemWrite_ID, RegWrite_ID, AluSrc_ID, Jal_ID, Jalr_ID;
logic [1:0]  MemtoReg_ID, AluOp_ID, AuipcLui_ID;


logic        RegWrite_EX, Branch_EX, MemRead_EX, MemWrite_EX, AluSrc_EX, Jal_EX, zero_EX;
logic [1:0]  MemtoReg_EX, AuipcLui_EX, AluOp_EX;
logic [31:0] PC_EX, readData1_EX, readData2_EX, inm_out_EX, instr_EX, valor_A, valor_B, alu_out_ext_EX, PC_inm;


logic        RegWrite_MEM, Branch_MEM, MemRead_MEM, MemWrite_MEM, zero_MEM, Jal_MEM;
logic [1:0]  MemtoReg_MEM;
logic [31:0] alu_out_ext_MEM, readData2_MEM, PC_MEM, PC_inm_MEM, instr_MEM;


logic        RegWrite_WB;
logic [1:0]  MemtoReg_WB;
logic [31:0] alu_out_ext_WB, dataram_rd_WB, instr_WB;



always_ff @(posedge CLOCK or negedge RST_n)
	if (!RST_n)
		PC <= '0;
	else 
		PC <= PC_siguiente;

//assign PC_siguiente = PCSrc ? (PC + inm_out) : // para las señales Jal y Jalr; la señal Jal pone a 1 directamente el PCSrc
                      Jalr_sig  ? alu_out_ext :
                              (PC + 4);

//assign PC_siguiente = (PCSrc) ? (PC_inm_MEM) : Jalr_MEM ? alu_out_ext : (PC + 4); ******************REVISAR******************


//------------IF/ID------------
always_ff @(posedge CLOCK)
	begin
	PC_ID = PC;
	instr_ID = instr;
	end


banco_registros banco_registros_inst
(
	.CLK(CLOCK),						// input  CLK_sig
	.RST_n(RST_n),						// input  RST_n_sig
	.readReg1(instr_ID[19:15]),	// input [4:0] readReg1_sig
	.readReg2(instr_ID[24:20]),	// input [4:0] readReg2_sig
	.writeReg(instr_WB[11:7]),		// input [4:0] writeReg_sig
	.writeData(datareg_wr),			// salida mux MemtoReg						
	.readData1(readData1_ID),		// output [31:0] readData1_sig
	.readData2(readData2_ID),		// output [31:0] readData2_sig
	.RegWrite(RegWrite_sig) 		// input  RegWrite_sig
);


Inm_Gen Inm_Gen_inst
(
	.inst(instr_ID[31:0]) ,	// input [31:0] inst_sig
	.inm(inm_out_ID) 	// output [31:0] inm_sig
);


CONTROL CONTROL_inst
(
	.instruction(instr_ID),	// input [31:0] instruction_sig
	.Branch(Branch_ID),		// output  Branch_sig
	.MemRead(MemRead_ID),	// output  MemRead_sig
	.MemtoReg(MemtoReg_ID),	// output  MemtoReg_sig
	.ALUOp(AluOp_ID),			// output [1:0] ALUOp_sig
	.MemWrite(MemWrite_ID),	// output  MemWrite_sig
	.ALUSrc(AluSrc_ID),		// output  ALUSrc_sig
	.RegWrite(RegWrite_ID),	// output  RegWrite_sig
	.AuipcLui(AuipcLui_ID),	// output [1:0] AuipcLui_sig
	.Jal(Jal_ID),
	.Jalr(Jalr_ID) //******************REVISAR******************
);

//------------ID/EX------------
always_ff @(posedge CLOCK)
	begin
	RegWrite_EX = RegWrite_ID;
	MemtoReg_EX = MemtoReg_ID;
	Branch_EX = Branch_ID;
	MemRead_EX = MemRead_ID;
	MemWrite_EX = MemWrite_ID;
	AluOp_EX = AluOp_ID;
	AluSrc_EX = AluSrc_ID;
	AuipcLui_EX = AuipcLui_ID;
	Jal_EX = Jal_ID;
	
	PC_EX = PC_ID;
	
	readData1_EX = readData1_ID;
	readData2_EX = readData2_ID;
	
	inm_out_EX = inm_out_ID;
	
	instr_EX = instr_ID;
	end

	
//Mux 3 a 1 para entrada A de la ALU
    always_comb begin
        case (AuipcLui_EX)
            2'b00: valor_A = PC_EX;        
            2'b01: valor_A = 32'd0;     
            2'b10: valor_A = readData1_EX;   
            default: valor_A = readData1_EX;
        endcase
    end
	 
		
assign valor_B = (AluSrc_EX) ? inm_out_EX : readData2_EX; //mux que selecciona entrada B alu		


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


//------------EX/MEM------------
always_ff @(posedge CLOCK)
	begin
	RegWrite_MEM = RegWrite_EX;
	MemtoReg_MEM = MemtoReg_EX;
	Branch_MEM = Branch_EX;
	MemRead_MEM = MemRead_EX;
	MemWrite_MEM = MemWrite_EX;
	zero_MEM = zero_EX;
	alu_out_ext_MEM = alu_out_ext_EX;
	PC_MEM = PC_EX;
	Jal_MEM = Jal_EX;
	PC_inm_MEM = PC_siguiente;
	instr_MEM = instr_EX;
	readData2_MEM = readData2_EX;
	end

	
assign PCSrc = (zero_MEM & Branch_MEM) || Jal_MEM;
assign ena_wr = MemWrite_MEM;
assign ena_rd = MemRead_MEM;
assign dataram_wr = readData2_MEM;


//------------MEM/WB------------
always @(posedge CLOCK)
	begin
	instr_WB = instr_MEM;
	RegWrite_WB = RegWrite_MEM;
	MemtoReg_WB = MemtoReg_MEM;
	alu_out_ext_WB = alu_out_ext_MEM;
	dataram_rd_WB = dataram_rd;
	end


assign datareg_wr = (MemtoReg_WB == 2'b01) ? dataram_rd_WB : ((MemtoReg_WB == 2'b00) ? alu_out_ext_WB : PC + 4); //Write data en banco de registros

endmodule
