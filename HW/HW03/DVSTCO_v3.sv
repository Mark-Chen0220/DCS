module DCSTCO(
    // Input signals
	clk,
	rst_n,
    in_valid,
	target_product,
    // Output signals
    out_valid,
	ten,
	five,
	one,
	run_out_ing,
	// AHB-interconnect input signals
	ready_refri,
	ready_kitch,
	// AHB-interconnect output signals
	valid_refri,
	valid_kitch,
	product_out,
	number_out
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input        clk, rst_n ;
input        in_valid ;
input        [11:0] target_product ;
input        ready_refri ;
input        ready_kitch ;
output logic out_valid ;
output logic [3:0] ten ;
output logic five ;
output logic [2:0] one ;
output logic run_out_ing ;
output logic valid_refri ;
output logic valid_kitch ;
output logic product_out ;
output logic [5:0] number_out ; 

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------
enum logic [1:0]{IDLE, ENOUGH, LACK, FILL} state, next;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic [11:0] data_in_reg,data1;
logic [6:0]	total_price;
logic product_out_reg;
logic [5:0] number_out_reg;
logic nugget,fried_rice,apple,peach;
logic [3:0] ten_reg;
logic [2:0] one_reg;
logic five_reg;
logic [2:0] cnt,cnt_next;
logic [6:0] nugget_next, fried_next;
logic [6:0] apple_next, peach_next;
logic out_valid_reg, run_out_ing_reg, in_valid_reg;
//---------------------------------------------------------------------
//   DON'T MODIFIED THE REGISTER'S NAME (PRODUCT REGISTER)
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop, fried_rice_in_shop ;
logic [6:0] apple_in_shop , peach_in_shop ;
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
always_comb begin								//valid_kitch
	valid_kitch = 0;
	if((state == LACK) && (nugget_in_shop<data1[11:9]))
		valid_kitch = 1;
	else if((state == LACK) &&apple_in_shop>=data1[5:3]&&(fried_rice_in_shop<data1[8:6]))
		valid_kitch = 1;
end
always_comb begin								//valid_refri
	valid_refri = 0;
	if((state == LACK) && (nugget_in_shop>=data1[11:9])&&(apple_in_shop<data1[5:3]))
		valid_refri=1;
	else if((state == LACK)&&nugget_in_shop>=data1[11:9]&&(fried_rice_in_shop>=data1[8:6])
		&&(apple_in_shop>=data1[5:3])&&peach_in_shop<data1[2:0])
		valid_refri = 1;
end
always_ff @(posedge clk,negedge rst_n) begin								//state
	if(!rst_n)
		state <=IDLE;
	else
		state<=next;
end
always_comb begin															//FSM
	case(state)	
	IDLE: begin
		if(in_valid_reg)
			if((nugget_in_shop>=data1[11:9]) &&(fried_rice_in_shop>=data1[8:6]) 
						&&(apple_in_shop>=data1[5:3]) &&(peach_in_shop>=data1[2:0]))
				next = ENOUGH;
			else
				next = LACK;
		else
			next = IDLE;
	end
	ENOUGH: begin
		next=IDLE;
	end
	LACK:begin
		if(ready_kitch&&valid_kitch)
			next=FILL;
		else if(ready_refri&&valid_refri)
			next=FILL;
		else
			next=LACK;
	end
	FILL:begin
		if(nugget_in_shop<data1[11:9])
			next = LACK;
		else if(apple_in_shop<data1[5:3])
			next = LACK;
		else if(fried_rice_in_shop<data1[8:6])
			next = LACK;
		else if(peach_in_shop<data1[2:0])
			next = LACK;
		else
			next=IDLE;
	end
	endcase
end
//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
assign nugget=(nugget_in_shop<data1[11:9])?1:0;
assign fried_rice=(fried_rice_in_shop<data1[8:6])?1:0;
assign apple=(apple_in_shop<data1[5:3])?1:0;
assign peach=(peach_in_shop<data1[2:0])?1:0;
always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		nugget_in_shop <=0;
		fried_rice_in_shop<=0;
		apple_in_shop<=0;
		peach_in_shop<=0;
	end
	else begin
		nugget_in_shop <=nugget_next;
		fried_rice_in_shop<=fried_next;
		apple_in_shop<=apple_next;
		peach_in_shop<=peach_next;
	end
end
always_comb begin
	cnt_next=0;
	if(next==LACK)
		cnt_next=nugget+fried_rice+apple+peach;
end									
always_ff @(posedge clk or negedge rst_n) begin	
	if(~rst_n)
		cnt<=0;
	else 
		cnt<=cnt_next;
end
always_ff @(posedge clk or negedge rst_n) begin								//data1
	if(!rst_n) 
		data1 <= 0;
	else 
		data1 <= data_in_reg;
end
always_comb
	data_in_reg = in_valid ? target_product : data1;
always_comb begin															//ten,five,one,out_valid
	total_price=0;
	ten_reg=0;
	five_reg=0;
	one_reg=0;															
	if(next==ENOUGH) begin
		total_price=data1[11:9]*3+data1[8:6]*5+data1[5:3]*2+data1[2:0]*4;
		ten_reg=total_price/10;
		five_reg=(total_price-ten_reg*10)>= 5;
		one_reg=total_price-ten_reg*10-5*five_reg;	
	end
end
always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		in_valid_reg <= 0;
		out_valid <= 0;
		run_out_ing <= 0;
		ten <= 0;
		five <= 0;
		one <= 0;
	end
	else begin
		in_valid_reg <= in_valid;
		out_valid <= out_valid_reg;
		run_out_ing <= run_out_ing_reg;
		ten <= ten_reg;
		five <= five_reg;
		one <= one_reg;
	end
end	
always_comb begin		
	if(next==ENOUGH) begin
		out_valid_reg=1;
		run_out_ing_reg = 0;
	end
	else if (cnt==1&&state==LACK && next == FILL)begin
			out_valid_reg=1;
			run_out_ing_reg = 1;
	end
	else begin
		out_valid_reg=0;
		run_out_ing_reg = 0;
	end
end
always_comb begin															//product_out_reg		
	number_out=0;
	if(nugget_in_shop<data1[11:9])
		number_out=50-nugget_in_shop;
	else if(apple_in_shop<data1[5:3])
		number_out=50-apple_in_shop;
	else if(fried_rice_in_shop<data1[8:6])
		number_out=50-fried_rice_in_shop;
	else if(peach_in_shop<data1[2:0])
		number_out=50-peach_in_shop;
end
always_comb begin															//number_out_reg
	if(nugget_in_shop<data1[11:9]||apple_in_shop<data1[5:3])
			product_out=1;
	else
			product_out=0;
end
always_comb  begin
		nugget_next=nugget_in_shop;
		fried_next=fried_rice_in_shop;
		apple_next=apple_in_shop;
		peach_next=peach_in_shop;			//in_shop
		if(state==ENOUGH)begin
		nugget_next=nugget_in_shop-data1[11:9];
		fried_next=fried_rice_in_shop-data1[8:6];
		apple_next=apple_in_shop-data1[5:3];
		peach_next=peach_in_shop-data1[2:0];
		end
		else if(ready_kitch&&valid_kitch) begin
			if(nugget_in_shop<data1[11:9])
				nugget_next=50;
			else 
				fried_next=50;
		end
		else if(ready_refri&&valid_refri) begin
			if(apple_in_shop<data1[5:3])
				apple_next=50;
			else
				peach_next=50;
		end
end
endmodule