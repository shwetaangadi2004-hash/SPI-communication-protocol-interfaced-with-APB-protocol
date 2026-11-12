module baud_generator_tb;

		reg PCLK,PRESET_n,spiswai,cpol,cphase,ss;
		reg [2:0] sppr,spr;
		reg [1:0] spi_mode;
		wire sclk,miso_receive_sclk_pos,miso_receive_sclk_neg,mosi_send_sclk_pos,mosi_send_sclk_neg;
		wire [11:0] baudratedivisior;

baud_generator dut (                    .PCLK(PCLK),
                                        .PRESET_n(PRESET_n),
						.spiswai(spiswai),
						.cpol(cpol),
						.cphase(cphase),
                                        .ss(ss),
						.sppr(sppr),
						.spr(spr),
						.spi_mode(spi_mode),
						.sclk(sclk),
						.miso_receive_sclk_pos(miso_receive_sclk_pos),
						.miso_receive_sclk_neg(miso_receive_sclk_neg),
						.mosi_send_sclk_pos(mosi_send_sclk_pos),
						.mosi_send_sclk_neg(mosi_send_sclk_neg),
						.baudratedivisior(baudratedivisior));
						
//generate PCLK
initial 
	begin
		PCLK = 1'b0;
		forever #5 PCLK = ~PCLK;
	end
	
//set PRESET_n
task reset;
	begin	
		@(negedge PCLK)
		PRESET_n = 1'b0;
		@(negedge PCLK)
		PRESET_n = 1'b1;
	end
endtask

//initialize the input signals
task initialize;
	begin
		PCLK = 1'b0;
		PRESET_n = 1'b0;
		spi_mode = 2'b00;
		spr = 3'b000;
		sppr = 3'b000;
		spiswai = 1'b0;
		cpol = 1'b0;
		cphase = 1'b0;
		ss = 1'b1;
	end
endtask

//generate the stimulus
task stimulus(input [2:0]i, input [2:0]j, input x,y);
	begin
		spi_mode = 2'b01;
		spr = i;
		sppr = j;
		spiswai = 1'b0;
		cpol = x;
		cphase = y;
		ss = 1'b0;
	end
endtask

//call the task
initial 
	begin
		initialize;
		reset;
		stimulus (3'b001,3'b001,1,1);
		#200;
		stimulus (3'b001,3'b001,0,1);
		#200;
		spiswai=1'b1;
        #4000;
        $finish();
	end
endmodule
