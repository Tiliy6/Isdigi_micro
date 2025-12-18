module TOP_CORE_SEG(
  input  logic        CLOCK,
  input  logic        RST_n, 

  // Desde IMEM externa (combinacional, direccionada por PC)
  input  logic [31:0] instr,

  // Desde RAM/GP10 externa (dato leído en etapa MEM)
  input  logic [31:0] dataram_rd,

  // Entradas de habilitación y clear
  input 	logic 		 clear_IFID, EN_IFID,
  input  logic 		   clear_IDEX, EN_IDEX,
  input  logic			 clear_EXMEM, EN_EXMEM,
  
  // Salidas hacia el "exterior"
  output logic [31:0] PC,
  output logic        ena_wr,
  output logic        ena_rd,
  output logic [1:0]  MemtoReg_sig,   // debug: MemtoReg en etapa WB
  output logic [31:0] alu_out_ext,    // dirección/result ALU hacia RAM (etapa MEM)
  output logic [31:0] dataram_wr      // datos a escribir en RAM (etapa MEM)
);

  // ============================================================================
  // 0) PC (IF)  -- versión simple: PC se actualiza con lo que decida EX
  //    (sin flush => habrá control hazard con branches/jal)
  // ============================================================================
  logic [31:0] PC_next;
  always_ff @(posedge CLOCK or negedge RST_n) begin
    if (!RST_n) PC <= '0;
    else        PC <= PC_next;
  end

  // ============================================================================
  // 1) IF/ID pipeline register
  // ============================================================================
  logic [31:0] IFID_instr;
  logic [31:0] IFID_PC;
  
  
// Aladir las señales de entrada clear_IFID, EN_IFID
  always_ff @(posedge CLOCK or negedge RST_n) begin
    if (!RST_n) begin
      IFID_instr <= 32'h0000_0013; // NOP (addi x0,x0,0)
      IFID_PC    <= 32'd0;
    end else if (!clear_IFID)begin
          IFID_instr <= 32'h0000_0013; // NOP (addi x0,x0,0)
          IFID_PC    <= 32'd0;
    end else if (EN_IFID) begin
      IFID_instr <= instr;   // instrucción leída en IF
      IFID_PC    <= PC;      // PC asociado a esa instrucción
    end
  end

  // Campos ID
  logic [4:0] rs1_ID, rs2_ID, rd_ID;
  logic [2:0] funct3_ID;
  logic [6:0] funct7_ID;

  assign rs1_ID   = IFID_instr[19:15];
  assign rs2_ID   = IFID_instr[24:20];
  assign rd_ID    = IFID_instr[11:7];
  assign funct3_ID= IFID_instr[14:12];
  assign funct7_ID= IFID_instr[31:25];

  // ============================================================================
  // 2) ID stage: CONTROL + REGFILE read + IMM_GEN
  // ============================================================================
  logic [31:0] regis_A_ID, regis_B_ID, inm_out_ID;

  logic        ALUSrc_ID, Branch_ID, RegWrite_ID, MemRead_ID, MemWrite_ID, Jal_ID;
  logic [1:0]  MemtoReg_ID;
  logic [1:0]  AuipcLui_ID;
  logic [2:0]  ALUOp_ID;

  CONTROL CONTROL_inst (
    .instruction (IFID_instr),
    .Branch      (Branch_ID),
    .MemRead     (MemRead_ID),
    .MemtoReg    (MemtoReg_ID),
    .ALUOp       (ALUOp_ID),
    .MemWrite    (MemWrite_ID),
    .ALUSrc      (ALUSrc_ID),
    .RegWrite    (RegWrite_ID),
    .AuipcLui    (AuipcLui_ID),
    .Jal         (Jal_ID)
  );

  // WB señales (vienen de MEM/WB)
  logic        RegWrite_WB;
  logic [4:0]  rd_WB;
  logic [31:0] writeData_WB;

  banco_registros banco_registros_inst (
    .CLK       (CLOCK),
    .RST_n     (RST_n),
    .readReg1  (rs1_ID),
    .readReg2  (rs2_ID),
    .writeReg  (rd_WB),
    .writeData (writeData_WB),
    .readData1 (regis_A_ID),
    .readData2 (regis_B_ID),
    .RegWrite  (RegWrite_WB)
  );

  Inm_Gen Inm_Gen_inst (
    .inst (IFID_instr),
    .inm  (inm_out_ID)
  );

  // ============================================================================
  // 3) ID/EX pipeline register (pasa datos + control a EX)
  // ============================================================================
  logic [31:0] IDEX_PC, IDEX_A, IDEX_B, IDEX_imm;
  logic [4:0]  IDEX_rd;
  logic [2:0]  IDEX_funct3;
  logic [6:0]  IDEX_funct7;

  logic        IDEX_ALUSrc, IDEX_Branch, IDEX_RegWrite, IDEX_MemRead, IDEX_MemWrite, IDEX_Jal;
  logic [1:0]  IDEX_MemtoReg;
  logic [1:0]  IDEX_AuipcLui;
  logic [2:0]  IDEX_ALUOp;

  always_ff @(posedge CLOCK or negedge RST_n) begin
    if (!RST_n) begin
      IDEX_PC       <= 32'd0;
      IDEX_A        <= 32'd0;
      IDEX_B        <= 32'd0;
      IDEX_imm      <= 32'd0;
      IDEX_rd       <= 5'd0;
      IDEX_funct3   <= 3'd0;
      IDEX_funct7   <= 7'd0;

      IDEX_ALUSrc   <= 1'b0;
      IDEX_Branch   <= 1'b0;
      IDEX_RegWrite <= 1'b0;
      IDEX_MemRead  <= 1'b0;
      IDEX_MemWrite <= 1'b0;
      IDEX_MemtoReg <= 2'b00;
      IDEX_Jal      <= 1'b0;
      IDEX_AuipcLui <= 2'b00;
      IDEX_ALUOp    <= 3'b000;
    end else if (!clear_IDEX)begin
      IDEX_PC       <= 32'd0;
      IDEX_A        <= 32'd0;
      IDEX_B        <= 32'd0;
      IDEX_imm      <= 32'd0;
      IDEX_rd       <= 5'd0;
      IDEX_funct3   <= 3'd0;
      IDEX_funct7   <= 7'd0;

      IDEX_ALUSrc   <= 1'b0;
      IDEX_Branch   <= 1'b0;
      IDEX_RegWrite <= 1'b0;
      IDEX_MemRead  <= 1'b0;
      IDEX_MemWrite <= 1'b0;
      IDEX_MemtoReg <= 2'b00;
      IDEX_Jal      <= 1'b0;
      IDEX_AuipcLui <= 2'b00;
      IDEX_ALUOp    <= 3'b000;
    end else if (EN_IDEX) begin
      IDEX_PC       <= IFID_PC;
      IDEX_A        <= regis_A_ID;
      IDEX_B        <= regis_B_ID;
      IDEX_imm      <= inm_out_ID;
      IDEX_rd       <= rd_ID;
      IDEX_funct3   <= funct3_ID;
      IDEX_funct7   <= funct7_ID;

      IDEX_ALUSrc   <= ALUSrc_ID;
      IDEX_Branch   <= Branch_ID;
      IDEX_RegWrite <= RegWrite_ID;
      IDEX_MemRead  <= MemRead_ID;
      IDEX_MemWrite <= MemWrite_ID;
      IDEX_MemtoReg <= MemtoReg_ID;
      IDEX_Jal      <= Jal_ID;
      IDEX_AuipcLui <= AuipcLui_ID;
      IDEX_ALUOp    <= ALUOp_ID;
    end
  end

  // ============================================================================
  // 4) EX stage: ALU_CONTROL + ALU + PCSrc (simple)
  // ============================================================================
  logic [31:0] valor_A_EX, valor_B_EX;
  logic [3:0]  instruction_bits_EX;
  logic [3:0]  ALU_operation_EX;
  logic [31:0] alu_out_EX;
  logic        zero_EX;

  // instruction_bits = {instr[30], instr[14:12]} equivalente
  assign instruction_bits_EX = {IDEX_funct7[5], IDEX_funct3};

  ALU_CONTROL ALU_CONTROL_inst (
    .ALUOp           (IDEX_ALUOp),
    .instruction_bits(instruction_bits_EX),
    .ALU_control     (ALU_operation_EX)
  );

  // Mux 3 a 1 para entrada A (auipc/lui/normal), pero con PC de ESA instrucción
  always_comb begin
    case (IDEX_AuipcLui)
      2'b00: valor_A_EX = IDEX_PC;    // AUIPC: usa PC
      2'b01: valor_A_EX = 32'd0;      // LUI: usa 0 (para pasar imm)
      2'b10: valor_A_EX = IDEX_A;     // normal: registro rs1
      default: valor_A_EX = IDEX_A;
    endcase
  end

  // Mux B ALU
  assign valor_B_EX = (IDEX_ALUSrc) ? IDEX_imm : IDEX_B;

  ALU ALU_inst (
    .A          (valor_A_EX),
    .B          (valor_B_EX),
    .ALU_control(ALU_operation_EX),
    .ALU_result (alu_out_EX),
    .zero       (zero_EX)
  );

  // PCSrc (sin flush -> control hazard, pero lo dejamos tal cual)
  logic PCSrc_EX;
  assign PCSrc_EX = (zero_EX & IDEX_Branch) || IDEX_Jal;

  // PC_next (ojo: branch/jal se decide “tarde” en EX, pero aceptamos eso)
  assign PC_next = (PCSrc_EX) ? (IDEX_PC + IDEX_imm) : (PC + 32'd4);

  // ============================================================================
  // 5) EX/MEM pipeline register (control de MEM + datos para RAM)
  // ============================================================================
  logic [31:0] EXMEM_alu;
  logic [31:0] EXMEM_storeData;
  logic [4:0]  EXMEM_rd;

  logic        EXMEM_MemRead, EXMEM_MemWrite, EXMEM_RegWrite;
  logic [1:0]	EXMEM_MemtoReg;
  logic [31:0] EXMEM_PC;

  always_ff @(posedge CLOCK or negedge RST_n) begin
    if (!RST_n) begin
      EXMEM_alu       <= 32'd0;
      EXMEM_storeData <= 32'd0;
      EXMEM_rd        <= 5'd0;
		EXMEM_PC			 <= 32'd0;

      EXMEM_MemRead   <= 1'b0;
      EXMEM_MemWrite  <= 1'b0;
      EXMEM_RegWrite  <= 1'b0;
      EXMEM_MemtoReg  <= 2'b00;
    end else if (!clear_EXMEM) begin
      EXMEM_alu       <= 32'd0;
      EXMEM_storeData <= 32'd0;
      EXMEM_rd        <= 5'd0;
		EXMEM_PC			 <= 32'd0;

      EXMEM_MemRead   <= 1'b0;
      EXMEM_MemWrite  <= 1'b0;
      EXMEM_RegWrite  <= 1'b0;
      EXMEM_MemtoReg  <= 2'b00;
    end else if (EN_EXMEM) begin 
    
      EXMEM_alu       <= alu_out_EX;
      EXMEM_storeData <= IDEX_B;      // dato rs2 para SW
      EXMEM_rd        <= IDEX_rd;
		EXMEM_PC			 <= IDEX_PC;

      EXMEM_MemRead   <= IDEX_MemRead;
      EXMEM_MemWrite  <= IDEX_MemWrite;
      EXMEM_RegWrite  <= IDEX_RegWrite;
      EXMEM_MemtoReg  <= IDEX_MemtoReg;
    end
  end

  // Salidas hacia RAM (en etapa MEM)
  assign alu_out_ext = EXMEM_alu;
  assign dataram_wr  = EXMEM_storeData;
  assign ena_wr      = EXMEM_MemWrite;
  assign ena_rd      = EXMEM_MemRead;

  // ============================================================================
  // 6) MEM/WB pipeline register (captura dato leído + alu + rd + WB control)
  // ============================================================================
  logic [31:0] MEMWB_memdata;
  logic [31:0] MEMWB_alu;
  logic [4:0]  MEMWB_rd;
  logic [31:0] MEMWB_PC;

  logic        MEMWB_RegWrite;
  logic [1:0]	MEMWB_MemtoReg;

  always_ff @(posedge CLOCK or negedge RST_n) begin
    if (!RST_n) begin
      MEMWB_memdata  <= 32'd0;
      MEMWB_alu      <= 32'd0;
      MEMWB_rd       <= 5'd0;
      MEMWB_RegWrite <= 1'b0;
      MEMWB_MemtoReg <= 2'b00;
		MEMWB_PC			<= 32'd0;
    end else begin
      MEMWB_memdata  <= dataram_rd;    // viene de RAM/GP10
      MEMWB_alu      <= EXMEM_alu;
      MEMWB_rd       <= EXMEM_rd;
      MEMWB_RegWrite <= EXMEM_RegWrite;
      MEMWB_MemtoReg <= EXMEM_MemtoReg;
		MEMWB_PC			<= EXMEM_PC;
    end
  end

  // ============================================================================
  // 7) WB stage (mux MemtoReg + write regfile)
  // ============================================================================
  assign MemtoReg_sig = MEMWB_MemtoReg; // debug
  
  always_comb begin
		case (MEMWB_MemtoReg)
		2'b00: writeData_WB = MEMWB_alu;	//ALU
		2'b01: writeData_WB = MEMWB_memdata;	//LW
		2'b10: writeData_WB = MEMWB_PC + 32'd4;
		default: writeData_WB = MEMWB_alu;
		endcase
	end
  assign rd_WB        = MEMWB_rd;
  assign RegWrite_WB  = MEMWB_RegWrite;

endmodule

