module banco_registros(CLK, readReg1, readReg2, writeReg, writeData, readData1, readData2, RegWrite)
input [4:0] readReg1, readReg2, writeReg;
input CLK, RegWrite; //RegWrite enable de escritura
input [31:0] writeData;
output [31:0] readData1, readData2;
logic [31:0][31:0]registro; //x0=registro[0],x1=registro[1], ect

assign registro[0]=0

always_ff @(posedge CLK)
	if(RegWrite)
		case(writeReg)
			5'b00000: writeData = registro[0];
			5'b00001: writeData = registro[1];
			5'b00010: writeData = registro[2];
			5'b00011: writeData = registro[3];
			5'b00100: writeData = registro[4];
			5'b00101: writeData = registro[5];
			5'b00110: writeData = registro[6];
			5'b00111: writeData = registro[7];
			5'b01000: writeData = registro[8];
			5'b01001: writeData = registro[9];
			5'b01010: writeData = registro[10];
			5'b01011: writeData = registro[11];
			5'b01100: writeData = registro[12];
			5'b01101: writeData = registro[13];
			5'b01110: writeData = registro[14];
			5'b01111: writeData = registro[15];
			5'b10000: writeData = registro[16];
			5'b10001: writeData = registro[17];
			5'b10010: writeData = registro[18];
			5'b10011: writeData = registro[19];
			5'b10100: writeData = registro[20];
			5'b10101: writeData = registro[21];
			5'b10110: writeData = registro[22];
			5'b10111: writeData = registro[23];
			5'b11000: writeData = registro[24];
			5'b11001: writeData = registro[25];
			5'b11010: writeData = registro[26];
			5'b11011: writeData = registro[27];
			5'b11100: writeData = registro[28];
			5'b11101: writeData = registro[29];
			5'b11110: writeData = registro[30];
			5'b11111: writeData = registro[31];

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

	
endmodule
