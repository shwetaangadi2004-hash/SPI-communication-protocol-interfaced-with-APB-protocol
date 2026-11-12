// baud generator

module baud_generator(
		input PCLK,PRESET_n,spiswai,cpol,cphase,ss,
		input [2:0] sppr,spr,
		input [1:0] spi_mode,
		output reg sclk,miso_receive_sclk_pos,miso_receive_sclk_neg,mosi_send_sclk_pos,mosi_send_sclk_neg,
		output [11:0] baudratedivisior);
		
	parameter RUN = 2'b00,
				WAIT = 2'b01,
				STOP = 2'b10;
				
	reg [11:0] count;
	wire pre_sclk;
	
	assign baudratedivisior = (sppr + 1) * 2**(spr +1);
	assign pre_sclk = cpol ? 1'b1 : 1'b0 ;
	
	
	always@(posedge PCLK or negedge PRESET_n)
		begin
			if(!PRESET_n)
				begin
					count<=12'b0;
					sclk<=pre_sclk;
				end
			else if((~ss) &&(spi_mode==RUN ||(spi_mode==WAIT &&(~spiswai))))
				begin
					if(count==(baudratedivisior/2-1'b1))
						begin
							count<=12'b0;
							sclk<=~sclk;
						end
					else
						count<=count+1'b1;
				end
			else
				begin
					sclk<=pre_sclk;
					count<=12'b0;
				end
		end
	
	
	always@(posedge PCLK or negedge PRESET_n)
		begin
			if(!PRESET_n)
			begin
				miso_receive_sclk_neg <= 1'b0;
				miso_receive_sclk_pos <= 1'b0;
			end
			
			else if ((!cpol && cphase) || (cpol && !cphase))
			begin
				if(sclk)
				begin
					if(count == ((baudratedivisior/2) - 1'b1))
						miso_receive_sclk_neg <= 1'b1;
					else
						miso_receive_sclk_neg <= 1'b0;
				end
				
				else 
				miso_receive_sclk_neg <= 1'b0;
			end
			
			else if ((!cpol && !cphase) || (cpol && cphase))
			begin 
				if(!sclk)
				begin
					if(count == ((baudratedivisior/2) - 1'b1))
					miso_receive_sclk_pos <= 1'b1;
					else
					miso_receive_sclk_pos <= 1'b0;
				end
				else
						miso_receive_sclk_pos<=1'b0;
				
			end
		end
			
	//logic for miso_send_sclk_neg and miso_send_sclk_pos
	always@(posedge PCLK or negedge PRESET_n)
	begin
		if(!PRESET_n)
			begin
				mosi_send_sclk_pos<=1'b0;
				mosi_send_sclk_neg<=1'b0;
			end
		else
			begin
				if((!cphase && cpol)||(cphase && ~cpol))
					begin
						if(sclk)
							if(count==(baudratedivisior/2-2'b10))
							mosi_send_sclk_neg<=1'b1;
							else
							mosi_send_sclk_neg<=1'b0;
						else
						mosi_send_sclk_neg<=1'b0;
					end
				else
					begin
						if(~sclk)
							if(count==(baudratedivisior/2-2'b10))
								mosi_send_sclk_pos<=1'b1;
							else
								mosi_send_sclk_pos<=1'b0;
						else
						mosi_send_sclk_pos<=1'b0;
					end
			end
	end
	
	endmodule
