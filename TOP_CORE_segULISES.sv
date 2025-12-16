module TOP_CORE(instr_IF, datareg_wr, CLOCK, RST_n, PC_IF, ena_wr, ena_rd, alu_out_ext, MemtoReg_sig, dataram_wr);

input [31:0] instr_IF;
input [31:0] datareg_wr; //salida mux memtoreg
input RST_n, CLOCK;

output logic [31:0] PC_IF;
output logic ena_wr, ena_rd; //entrada habilita ram lectura/escritura
output logic MemtoReg_sig; //habilita mux de ram
output logic [31:0] alu_out_ext; //entrada ram
output logic [31:0] dataram_wr;

logic [31:0] PC_siguiente;
logic [31:0] regis_A, regis_B, valor_A, valor_B, inm_out;
logic ALUSrc_sig, Branch_sig, PCSrc, zero_sig, RegWrite_sig, MemRead_sig, MemWrite_sig, Jal_sig;
logic [1:0] AuipcLui_sig;
logic [2:0] ALUOp_sig;
logic [3:0] instruction_bits_sig, ALU_operation;

always_ff @(posedge CLOCK or negedge RST_n)
	if (!RST_n)
		PC_IF <= '0;
	else 
		PC_IF <= PC_siguiente;


//IF/ID
always @(posedge CLK)		
	PC_ID = PC_IF;
	instr_ID = instr_IF;


banco_registros banco_registros_inst
(
	.CLK(CLOCK),	// input  CLK_sig
	.RST_n(RST_n),	// input  RST_n_sig
	.readReg1(instr_ID[19:15]),	// input [4:0] readReg1_sig
	.readReg2(instr_ID[24:20]),	// input [4:0] readReg2_sig
	.writeReg(instr_ID[11:7]),	// input [4:0] writeReg_sig
	.writeData(datareg_wr),	// salida mux MemtoReg						
	.readData1(regis_A),	// output [31:0] readData1_sig
	.readData2(regis_B),	// output [31:0] readData2_sig
	.RegWrite(RegWrite_sig) 	// input  RegWrite_sig
);


Inm_Gen Inm_Gen_inst
(
	.inst(instr_ID[31:0]) ,	// input [31:0] inst_sig
	.inm(inm_out_ID) 	// output [31:0] inm_sig
);


CONTROL CONTROL_inst
(
	.instruction(instr_ID),	// input [31:0] instruction_sig
	.Branch(Branch_ID),	// output  Branch_sig
	.MemRead(MemRead_ID),	// output  MemRead_sig
	.MemtoReg(MemtoReg_ID),	// output  MemtoReg_sig
	.ALUOp(AluOp_ID),	// output [1:0] ALUOp_sig
	.MemWrite(MemWrite_ID),	// output  MemWrite_sig
	.ALUSrc(AluSrc_ID),	// output  ALUSrc_sig
	.RegWrite(RegWrite_ID), 	// output  RegWrite_sig
	.AuipcLui(AuipcLui_ID),
	.Jal(Jal_ID)
);

//ID/EX
always @(posedge CLK)
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
	readData1_EX = readData2_ID;
	
	inm_out_EX = inm_out_ID;
	
	instr_EX = instr_ID;


// Mux 3 a 1 para entrada A de la ALU
    always_comb begin
        case (AuipcLui_sig)
            2'b00: valor_A = PC_IF;        
            2'b01: valor_A = 32'd0;     
            2'b10: valor_A = regis_A;   
            default: valor_A = regis_A;
        endcase
    end
		
		
ALU ALU_inst
(
	.A(valor_A),	// mux 3 a 1 
	.B(valor_B),	// mux indica si ReadData2 o immGen, seleccion=ALUSrc
	.ALU_control(ALU_operation),	// controlado por modulo alu control
	.ALU_result(alu_out_ext),	// decision del salto
	.zero(zero_sig) 	// output  zero_sig
);


ALU_CONTROL ALU_CONTROL_inst
(
	.ALUOp(ALUOp_sig),
	.instruction_bits(instruction_bits_sig),
	.ALU_control(ALU_operation)
);


assign PCSrc = (zero_sig & Branch_sig) || Jal_sig; // Esta puerta AND es de 3 entradas zero_sig,  Branch_sig y Jal, si el jal esta activado activa el mux para que pase el PC_IF+4
// La señal Jal y Jal R salen de Alu Control, hay que cambiar ese modulo para que genere esas señales. 
assign PC_siguiente = (PCSrc) ? (PC_IF + inm_out) : (PC_IF + 4);
assign valor_B = (ALUSrc_sig) ? inm_out : regis_B; //mux que selecciona entrada B alu
assign ena_wr = MemWrite_sig;
assign ena_rd = MemRead_sig;
assign instruction_bits_sig = {instr_IF[30],instr_IF[14:12]};
assign dataram_wr = regis_B;
endmodule
