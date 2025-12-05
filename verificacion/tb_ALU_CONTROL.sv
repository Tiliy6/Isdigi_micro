`timescale 1ns/1ps

module tb_ALU_CONTROL;

  // Entradas del DUT
  logic [2:0] ALUOp;
  logic [3:0] instruction_bits;

  // Salida del DUT
  logic [3:0] ALU_control;

  // Instancia del DUT
  ALU_CONTROL dut (
    .ALUOp           (ALUOp),
    .instruction_bits(instruction_bits),
    .ALU_control     (ALU_control)
  );

  integer op;
  integer bits;

  // ============================================================
  // FUNCIÓN QUE DEVUELVE EL NOMBRE DE LA OPERACIÓN COMO STRING
  // ============================================================
  function string op_name(input logic [2:0] op,
                          input logic [3:0] bits);

    logic       funct7  = bits[3];
    logic [2:0] funct3  = bits[2:0];

    begin
      case (op)

        // ========================= R-TYPE ===========================
        3'b000: begin
          case (funct3)
            3'b000:   op_name = funct7 ? "SUB"  : "ADD";
            3'b001:   op_name = "SLL";
            3'b010:   op_name = "SLT";
            3'b011:   op_name = "SLTU";
            3'b100:   op_name = "XOR";
            3'b101:   op_name = "SRL";
            3'b110:   op_name = funct7 ? "SRA" : "OR";
            3'b111:   op_name = "AND";
            default:  op_name = "UNKNOWN_R";
          endcase
        end

        // ======================= LOAD / STORE =======================
        3'b010: begin
          op_name = "ADD (LW/SW)";
        end

        // ========================== BRANCHES ========================
        3'b001: begin
          case (funct3)
            3'b000: op_name = "BEQ";
            3'b001: op_name = "BNE";
            3'b100: op_name = "BLT";
            3'b101: op_name = "BGE";
            3'b110: op_name = "BLTU";
            3'b111: op_name = "BGEU";
            default: op_name = "UNKNOWN_BRANCH";
          endcase
        end

        // ========================= I - TYPE ALU =====================
        3'b011: begin
          case (funct3)
            3'b000: op_name = "ADDI";
            3'b001: op_name = "SLLI";
            3'b010: op_name = "SLTI";
            3'b011: op_name = "SLTIU";
            3'b100: op_name = "XORI";
            3'b101: op_name = funct7 ? "SRAI" : "SRLI";
            3'b110: op_name = "ORI";
            3'b111: op_name = "ANDI";
            default: op_name = "UNKNOWN_I";
          endcase
        end

        // ========================= LUI / AUIPC ======================
        3'b100: op_name = "LUI/AUIPC (ADD)";

        default: op_name = "INVALID_ALUOp";

      endcase
    end
  endfunction

  // ============================================================
  // TEST: RECORRE TODAS LAS COMBINACIONES Y MUESTRA NOMBRE
  // ============================================================
  initial begin
    $display("\n=== Testbench ALU_CONTROL (con nombres) ===\n");

    for (op = 0; op <= 4; op = op + 1) begin
      for (bits = 0; bits < 16; bits = bits + 1) begin

        ALUOp            = op[2:0];
        instruction_bits = bits[3:0];

        #1; // deja que se propague la lógica

        $display("ALUOp=%b  instr_bits=%b  ->  ALU_control=%b    (%s)",
                 ALUOp, instruction_bits, ALU_control,
                 op_name(ALUOp, instruction_bits));
      end
    end

    $display("\n=== Fin de simulación ===\n");
    $finish;
  end

endmodule

