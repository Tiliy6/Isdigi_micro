module banco_registros(CLK, readReg1, readReg2, writeReg, writeData, readData1, readData2, RegWrite)
input [4:0] readReg1, readReg2, writeReg;
input CLK, RegWrite; //RegWrite enable de escritura
input [31:0] writeData;
output [31:0] readData1, readData2;
logic [31:0][31:0]registro; //x0=registro[0],x1=registro[1], ect

assign registro[0]=0

always_ff @(CLK)

always_comb
	case(readReg1)
	3'b00000: readData1 = registro[0]
	3'b00001: readData1 = registro[1]
	3'b00010: readData1 = registro[2]
	3'b00011: readData1 = registro[3]
	3'b00100: readData1 = registro[4]
	3'b00101: readData1 = registro[5]
	3'b00110: readData1 = registro[6]
	3'b00111: readData1 = registro[7]
	3'b01000: readData1 = registro[8]
	3'b01001: readData1 = registro[9]
	3'b01010: readData1 = registro[10]
	3'b01011: readData1 = registro[11]
	3'b01100: readData1 = registro[12]
	3'b01101: readData1 = registro[13]
	3'b01110: readData1 = registro[14]
	3'b01111: readData1 = registro[15]
	3'b10000: readData1 = registro[16]
	3'b10001: readData1 = registro[17]
	3'b10010: readData1 = registro[18]
	3'b10011: readData1 = registro[19]
	3'b10100: readData1 = registro[20]
	3'b10101: readData1 = registro[21]
	3'b10110: readData1 = registro[22]
	3'b10111: readData1 = registro[23]
	3'b11000: readData1 = registro[24]
	3'b11001: readData1 = registro[25]
	3'b11010: readData1 = registro[26]
	3'b11011: readData1 = registro[27]
	3'b11100: readData1 = registro[28]
	3'b11101: readData1 = registro[29]
	3'b11110: readData1 = registro[30]
	3'b11111: readData1 = registro[31]
	
always_comb
	case(readReg2)
	3'b00000: readData2 = registro[0]
	3'b00001: readData2 = registro[1]
	3'b00010: readData2 = registro[2]
	3'b00011: readData2 = registro[3]
	3'b00100: readData2 = registro[4]
	3'b00101: readData2 = registro[5]
	3'b00110: readData2 = registro[6]
	3'b00111: readData2 = registro[7]
	3'b01000: readData2 = registro[8]
	3'b01001: readData2 = registro[9]
	3'b01010: readData2 = registro[10]
	3'b01011: readData2 = registro[11]
	3'b01100: readData2 = registro[12]
	3'b01101: readData2 = registro[13]
	3'b01110: readData2 = registro[14]
	3'b01111: readData2 = registro[15]
	3'b10000: readData2 = registro[16]
	3'b10001: readData2 = registro[17]
	3'b10010: readData2 = registro[18]
	3'b10011: readData2 = registro[19]
	3'b10100: readData2 = registro[20]
	3'b10101: readData2 = registro[21]
	3'b10110: readData2 = registro[22]
	3'b10111: readData2 = registro[23]
	3'b11000: readData2 = registro[24]
	3'b11001: readData2 = registro[25]
	3'b11010: readData2 = registro[26]
	3'b11011: readData2 = registro[27]
	3'b11100: readData2 = registro[28]
	3'b11101: readData2 = registro[29]
	3'b11110: readData2 = registro[30]
	3'b11111: readData2 = registro[31]

	
endmodule
