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
parameter NUGGET_PRICE = 3;
parameter FRIED_RICE_PRICE = 5;
parameter APPLE_PRICE = 2;
parameter PEACH_PRICE = 4;
parameter NUGGET_ADDR = 1'b1;
parameter FRIED_RICE_ADDR = 1'b0;
parameter APPLE_ADDR = 1'b1;
parameter PEACH_ADDR = 1'b0;
parameter PRODUCT_REGISTER_INIT = 7'd50;
//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------
logic out_valid_temp;
logic in_valid_temp;
//---------------------------------------------------------------------
//   STOCK 
//---------------------------------------------------------------------
logic [11:0] target_product_temp ;
logic [6:0] nugget_in_shop_temp, fried_rice_in_shop_temp, apple_in_shop_temp, peach_in_shop_temp;

//---------------------------------------------------------------------
//   PRODUCT SOLD 
//---------------------------------------------------------------------
logic [15:0] cost;
logic [3:0] ten_temp;
logic five_temp;
logic [2:0] one_temp;

//---------------------------------------------------------------------
//   NOT ENOUGH PRODUCT
//---------------------------------------------------------------------
logic [2:0] nugget_need, fried_rice_need, apple_need, peach_need;
logic nugget_needs_refill, fried_rice_needs_refill, apple_needs_refill, peach_needs_refill, refill_required;
logic [5:0] nugget_refill, fried_rice_refill, apple_refill, peach_refill;
logic run_out_ing_temp;

logic [2:0]refill_count;

logic not_enough;

//---------------------------------------------------------------------
//   DON'T MODIFIED THE REGISTER'S NAME (PRODUCT REGISTER)
//---------------------------------------------------------------------
logic [6:0] nugget_in_shop, fried_rice_in_shop;
logic [6:0] apple_in_shop , peach_in_shop;
//---------------------------------------------------------------------

//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
enum logic [3:0] {IDLE, PROCESS, REFILL, NUGGET, FRIED_RICE, APPLE, PEACH} state, next_state;

assign refill_count = nugget_needs_refill + fried_rice_needs_refill + apple_needs_refill + peach_needs_refill;
assign not_enough = target_product[11:9] > nugget_in_shop || target_product[8:6] > fried_rice_in_shop || target_product[5:3] > apple_in_shop || target_product[2:0] > peach_in_shop;

always_comb begin
	case(state)
	IDLE: begin
		if(in_valid)
			if(not_enough)begin
				if (target_product[11:9] > nugget_in_shop) next_state = NUGGET;
				else if (target_product[5:3] > apple_in_shop) next_state = APPLE;
				else if (target_product[8:6] > fried_rice_in_shop) next_state = FRIED_RICE;
				else if (target_product[2:0] > peach_in_shop) next_state = PEACH;
			end
			else
				next_state = IDLE;
		else
			next_state = IDLE;
	end
	PROCESS: begin
		next_state = IDLE;
	end
	
	REFILL: begin
		if (nugget_needs_refill) next_state = NUGGET;
		else if (apple_needs_refill) next_state = APPLE;
		else if (fried_rice_needs_refill) next_state = FRIED_RICE;
		else if (peach_needs_refill) next_state = PEACH;
		else next_state = IDLE;
	end
	NUGGET: begin
		if (nugget_needs_refill) next_state = state;
		else if (apple_needs_refill) next_state = APPLE;
		else if (fried_rice_needs_refill) next_state = FRIED_RICE;
		else if (peach_needs_refill) next_state = PEACH;
		else next_state = IDLE;
	end
	APPLE: begin
		if (apple_needs_refill) next_state = state;
		else if (fried_rice_needs_refill) next_state = FRIED_RICE;
		else if (peach_needs_refill) next_state = PEACH;
		else next_state = IDLE;
	end
	FRIED_RICE: begin
		if (fried_rice_needs_refill) next_state = state;
		else if (peach_needs_refill) next_state = PEACH;
		else next_state = IDLE;
	end
	PEACH: begin
		if (peach_needs_refill) next_state = state;
		else next_state = IDLE;
	end
	default: next_state = IDLE;
	endcase
end

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) state <= IDLE;
	else state <= next_state;
end

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------


always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) in_valid_temp <= 0;
	else in_valid_temp <= in_valid;
end	

//---------------------------------------------------------------------
//   Fetch product need                      
//---------------------------------------------------------------------

always_comb begin
	if (in_valid) target_product_temp = target_product;
	else target_product_temp = {nugget_need, fried_rice_need, apple_need, peach_need};
end

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n) {nugget_need, fried_rice_need, apple_need, peach_need} <= 0;
	else {nugget_need, fried_rice_need, apple_need, peach_need} <= target_product_temp;
end

//---------------------------------------------------------------------
//   Determine whether product is enough                        
//---------------------------------------------------------------------


always_comb begin
	if (nugget_need > nugget_in_shop)begin
		nugget_refill = 50 - nugget_in_shop;
		nugget_needs_refill = 1;
	end else begin
		nugget_refill = 0;
		nugget_needs_refill = 0;
	end
end	
			
always_comb begin
	if (fried_rice_need > fried_rice_in_shop) begin
		fried_rice_refill = 50 - fried_rice_in_shop;
		fried_rice_needs_refill = 1;
	end else begin
		fried_rice_refill = 0;
		fried_rice_needs_refill = 0;
	end
end	
		
always_comb begin
	if (apple_need > apple_in_shop) begin
		apple_refill = 50 - apple_in_shop;
		apple_needs_refill = 1;
	end else begin
		apple_refill = 0;
		apple_needs_refill = 0;
	end
end	

always_comb begin
	if (peach_need > peach_in_shop) begin			
		peach_refill = 50 - peach_in_shop;
		peach_needs_refill = 1;
	end else begin
		peach_refill = 0;
		peach_needs_refill = 0;
	end
end	

always_comb begin
	if (nugget_needs_refill || fried_rice_needs_refill ||
		apple_needs_refill || peach_needs_refill)
		refill_required = 1;
	else refill_required = 0;
end
			
//---------------------------------------------------------------------
//   Calculate cost when product is enough                        
//---------------------------------------------------------------------

always_ff@(posedge clk or negedge rst_n)begin
	if(!rst_n) out_valid <= 0;
	else out_valid <= out_valid_temp;
end

always_comb begin
	cost = 0;
	ten_temp = 0;
	five_temp = 0;		
	one_temp = 0;
	if(in_valid && !not_enough) begin
		cost = NUGGET_PRICE * target_product[11:9] 
		+ FRIED_RICE_PRICE * target_product[8:6] 
		+ APPLE_PRICE * target_product[5:3] 
		+ PEACH_PRICE * target_product[2:0]; 
		ten_temp = cost / 10;
		cost = cost % 10;
		five_temp = cost / 5;
		one_temp = cost % 5;
		out_valid_temp = 1;
	end
	else if (refill_count == 1 && ((ready_refri && valid_refri) || (ready_kitch && valid_kitch))) begin
		out_valid_temp = 1;
	end
	else begin
		out_valid_temp = 0;
	end
end

always_ff@(posedge clk or negedge rst_n)begin
	if (!rst_n)begin
		ten <= 0;
		five <= 0;
		one <= 0;
	end else begin
		ten <= ten_temp;
		five <= five_temp;
		one <= one_temp;
	end
end

//---------------------------------------------------------------------
//   Deduct sold product from shop                    
//---------------------------------------------------------------------

always_comb begin
	{nugget_in_shop_temp, fried_rice_in_shop_temp, apple_in_shop_temp, peach_in_shop_temp} = {nugget_in_shop, fried_rice_in_shop, apple_in_shop, peach_in_shop}; 
	case(state)
		IDLE: begin
			if (in_valid && !not_enough) begin
				nugget_in_shop_temp = nugget_in_shop - target_product[11:9] ;
				fried_rice_in_shop_temp = fried_rice_in_shop - target_product[8:6] ;
				apple_in_shop_temp = apple_in_shop - target_product[5:3] ;
				peach_in_shop_temp = peach_in_shop - target_product[2:0] ;
			end
		end
		NUGGET: if (ready_kitch && valid_kitch && nugget_needs_refill) nugget_in_shop_temp = PRODUCT_REGISTER_INIT;
		FRIED_RICE: if (ready_kitch && valid_kitch && fried_rice_needs_refill) fried_rice_in_shop_temp = PRODUCT_REGISTER_INIT;
		APPLE: if (ready_refri && valid_refri && apple_needs_refill) apple_in_shop_temp = PRODUCT_REGISTER_INIT;
		PEACH: if (ready_refri && valid_refri && peach_needs_refill) peach_in_shop_temp = PRODUCT_REGISTER_INIT;
		default: {nugget_in_shop_temp, fried_rice_in_shop_temp, apple_in_shop_temp, peach_in_shop_temp} = {nugget_in_shop, fried_rice_in_shop, apple_in_shop, peach_in_shop}; 
	endcase
end

always_ff@(posedge clk or negedge rst_n) begin
	if (!rst_n)	{nugget_in_shop, fried_rice_in_shop, apple_in_shop, peach_in_shop} <= 0;
	else {nugget_in_shop, fried_rice_in_shop, apple_in_shop, peach_in_shop} 
	<= {nugget_in_shop_temp, fried_rice_in_shop_temp, apple_in_shop_temp, peach_in_shop_temp};
end

//---------------------------------------------------------------------
//   Handshake with food_store.sv                       
//---------------------------------------------------------------------

always_comb begin
	case(state) 
		NUGGET: {valid_refri,valid_kitch, product_out, number_out} = {1'b0,1'b1, NUGGET_ADDR,nugget_refill};
		FRIED_RICE: {valid_refri,valid_kitch, product_out, number_out} = {1'b0,1'b1, FRIED_RICE_ADDR,fried_rice_refill};
		APPLE: {valid_refri,valid_kitch, product_out, number_out} = {1'b1,1'b0, APPLE_ADDR,apple_refill};
		PEACH: {valid_refri,valid_kitch, product_out, number_out} = {1'b1,1'b0, PEACH_ADDR,peach_refill};
		default:  {valid_refri,valid_kitch, product_out, number_out} = 0;
	endcase
end

always_ff@(posedge clk or negedge rst_n)begin
	if (!rst_n) run_out_ing <= 0;
	else run_out_ing <= run_out_ing_temp;
end

always_comb begin
	if (refill_count == 1 && ((ready_refri && valid_refri) || (ready_kitch && valid_kitch))) run_out_ing_temp = 1;
	else run_out_ing_temp = 0;
end

endmodule