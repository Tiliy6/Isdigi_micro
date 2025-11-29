`timescale 1ns/1ps

interface test_if(
// constants
// general purpose registers
input bit reloj, //CLK
input bit reset); //RESET
logic [31:0] PC_addr, instr_rom, alu_result, datareg_wr_sig, dataram_wr_sig, dout_ram;
logic MemtoReg_mux, ena_wr_sig, ena_rd_sig;

  clocking md @(posedge reloj);
   input #1ns PC_addr;
   input #1ns instr_rom;
   input #1ns alu_result;
   input #1ns datareg_wr_sig;
   input #1ns dataram_wr_sig;
   input #1ns dout_ram;
   input #1ns MemtoReg_mux;
   input #1ns ena_wr_sig;
   input #1ns ena_rd_sig;
  endclocking:md;

  clocking sd @(posedge reloj);
	input #2ns PC_addr;
   input #2ns instr_rom;
   input #2ns alu_result;
   input #2ns datareg_wr_sig;
   input #2ns dataram_wr_sig;
   input #2ns dout_ram;
   input #2ns MemtoReg_mux;
   input #2ns ena_wr_sig;
   input #2ns ena_rd_sig;
  endclocking:sd;
  
  modport monitor (clocking md);
  modport test (clocking sd);
  modport duv (
	input  reloj,
   input  reset,
   output PC_addr,
   output instr_rom,
   output alu_result,
   output datareg_wr_sig,
   output dataram_wr_sig,
   output dout_ram,
   output MemtoReg_mux,
   output ena_wr_sig,
   output ena_rd_sig
		);

endinterface
