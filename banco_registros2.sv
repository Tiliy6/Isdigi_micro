module banco_registros2(CLK, readReg1, readReg2, writeReg, writeData, readData1, readData2, RegWrite);
input [4:0] readReg1, readReg2, writeReg;
input CLK, RegWrite; //RegWrite enable de escritura
input [31:0] writeData;
output [31:0] readData1, readData2;
logic [31:0][31:0]registro; //x0=registro[0],x1=registro[1], ect


always_ff @(posedge CLK)
	begin
		registro[0] <= 0;
		if(RegWrite && (writeReg != 5'd0))
			registro[writeReg] <= writeData;
	end
	
always_comb
	readData1 = registro[readReg1];
	
always_comb
	readData2 = registro[readReg2];

	
endmodule
