module banco_registros(CLK, readReg1, readReg2, writeReg, writeData, readData1, readData2, RegWrite);
input [4:0] readReg1, readReg2, writeReg;
input CLK, RegWrite; //RegWrite enable de escritura
input [31:0] writeData;
output [31:0] readData1, readData2;
logic [31:0][31:0]registro; //x0=registro[0],x1=registro[1], ect



always_ff @(posedge CLK)
	if(RegWrite)
		case(writeReg)
			5'b00000: registro[0] = 0;
			5'b00001: registro[1] = writeData;
			5'b00010: registro[2] = writeData;
			5'b00011: registro[3] = writeData;
			5'b00100: registro[4] = writeData;
			5'b00101: registro[5] = writeData;
			5'b00110: registro[6] = writeData;
			5'b00111: registro[7] = writeData;
			5'b01000: registro[8] = writeData;
			5'b01001: registro[9] = writeData;
			5'b01010: registro[10] = writeData;
			5'b01011: registro[11] = writeData;
			5'b01100: registro[12] = writeData;
			5'b01101: registro[13] = writeData;
			5'b01110: registro[14] = writeData;
			5'b01111: registro[15] = writeData;
			5'b10000: registro[16] = writeData;
			5'b10001: registro[17] = writeData;
			5'b10010: registro[18] = writeData;
			5'b10011: registro[19] = writeData;
			5'b10100: registro[20] = writeData;
			5'b10101: registro[21] = writeData;
			5'b10110: registro[22] = writeData;
			5'b10111: registro[23] = writeData;
			5'b11000: registro[24] = writeData;
			5'b11001: registro[25] = writeData;
			5'b11010: registro[26] = writeData;
			5'b11011: registro[27] = writeData;
			5'b11100: registro[28] = writeData;
			5'b11101: registro[29] = writeData;
			5'b11110: registro[30] = writeData;
			5'b11111: registro[31] = writeData;
			default registro = 0;
			endcase
			
always_comb
	case(readReg1)
	5'b00000: readData1 = registro[0];
	5'b00001: readData1 = registro[1];
	5'b00010: readData1 = registro[2];
	5'b00011: readData1 = registro[3];
	5'b00100: readData1 = registro[4];
	5'b00101: readData1 = registro[5];
	5'b00110: readData1 = registro[6];
	5'b00111: readData1 = registro[7];
	5'b01000: readData1 = registro[8];
	5'b01001: readData1 = registro[9];
	5'b01010: readData1 = registro[10];
	5'b01011: readData1 = registro[11];
	5'b01100: readData1 = registro[12];
	5'b01101: readData1 = registro[13];
	5'b01110: readData1 = registro[14];
	5'b01111: readData1 = registro[15];
	5'b10000: readData1 = registro[16];
	5'b10001: readData1 = registro[17];
	5'b10010: readData1 = registro[18];
	5'b10011: readData1 = registro[19];
	5'b10100: readData1 = registro[20];
	5'b10101: readData1 = registro[21];
	5'b10110: readData1 = registro[22];
	5'b10111: readData1 = registro[23];
	5'b11000: readData1 = registro[24];
	5'b11001: readData1 = registro[25];
	5'b11010: readData1 = registro[26];
	5'b11011: readData1 = registro[27];
	5'b11100: readData1 = registro[28];
	5'b11101: readData1 = registro[29];
	5'b11110: readData1 = registro[30];
	5'b11111: readData1 = registro[31];
	default readData1 = 0;
	endcase
	
always_comb
	case(readReg2)
	5'b00000: readData2 = registro[0];
	5'b00001: readData2 = registro[1];
	5'b00010: readData2 = registro[2];
	5'b00011: readData2 = registro[3];
	5'b00100: readData2 = registro[4];
	5'b00101: readData2 = registro[5];
	5'b00110: readData2 = registro[6];
	5'b00111: readData2 = registro[7];
	5'b01000: readData2 = registro[8];
	5'b01001: readData2 = registro[9];
	5'b01010: readData2 = registro[10];
	5'b01011: readData2 = registro[11];
	5'b01100: readData2 = registro[12];
	5'b01101: readData2 = registro[13];
	5'b01110: readData2 = registro[14];
	5'b01111: readData2 = registro[15];
	5'b10000: readData2 = registro[16];
	5'b10001: readData2 = registro[17];
	5'b10010: readData2 = registro[18];
	5'b10011: readData2 = registro[19];
	5'b10100: readData2 = registro[20];
	5'b10101: readData2 = registro[21];
	5'b10110: readData2 = registro[22];
	5'b10111: readData2 = registro[23];
	5'b11000: readData2 = registro[24];
	5'b11001: readData2 = registro[25];
	5'b11010: readData2 = registro[26];
	5'b11011: readData2 = registro[27];
	5'b11100: readData2 = registro[28];
	5'b11101: readData2 = registro[29];
	5'b11110: readData2 = registro[30];
	5'b11111: readData2 = registro[31];
	default readData2 = 0;
	endcase

	
endmodule
