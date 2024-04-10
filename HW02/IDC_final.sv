module IDC(
    // Input signals
	clk,
	rst_n,
	in_valid,
    in_id,
    // Output signals
    out_valid,
    out_legal_id
);

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input clk, rst_n, in_valid;
input [5:0] in_id;

output logic out_valid;
output logic out_legal_id;

//---------------------------------------------------------------------
//   LOGIC DECLARATION
//---------------------------------------------------------------------

reg [3:0] index;
reg [3:0] check_digit;
reg [8:0] sum;
reg [3:0] remainder;

//---------------------------------------------------------------------
//   Your design                        
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin 
		index <= 0;
	end else if (in_valid && index < 10)begin
		index <= index + 1;
	end else if (index == 10)
		index <= 0;
end

always_comb begin
	case(index)
		0: sum <= in_id / 10 + in_id % 10 * 9;
		1: sum <= sum + in_id * 8; 
		2: sum <= sum + in_id * 7;
		3: sum <= sum + in_id * 6;
		4: sum <= sum + in_id * 5;
		5: sum <= sum + ((in_id + in_id) + (in_id + in_id));
		6: sum <= sum + (in_id + (in_id + in_id));
		7: sum <= sum + (in_id + in_id);
		8: sum <= sum + in_id;
		9: begin 
			remainder <= sum % 10;
			check_digit <= in_id; 
		end
	endcase
	if (index == 10)begin
		out_valid = 1;
		if (10 - remainder == check_digit)out_legal_id = 1;
		else if (remainder == 0 && check_digit == 0)out_legal_id = 1;
		else out_legal_id = 0;		
	end
	else begin
		out_legal_id = 0;
		out_valid = 0;
	end 
		
end

/*function [3:0] mod10;
    input [8:0] num;
    begin
        case (num)
            9'd1:   mod10 = 4'd1;
            9'd2:   mod10 = 4'd2;
            9'd3:   mod10 = 4'd3;
            9'd4:   mod10 = 4'd4;
            9'd5:   mod10 = 4'd5;
            9'd6:   mod10 = 4'd6;
            9'd7:   mod10 = 4'd7;
            9'd8:   mod10 = 4'd8;
            9'd9:   mod10 = 4'd9;
            9'd10:  mod10 = 4'd0;
            9'd11:  mod10 = 4'd1;
            9'd12:  mod10 = 4'd2;
            9'd13:  mod10 = 4'd3;
            9'd14:  mod10 = 4'd4;
            9'd15:  mod10 = 4'd5;
            9'd16:  mod10 = 4'd6;
            9'd17:  mod10 = 4'd7;
            9'd18:  mod10 = 4'd8;
            9'd19:  mod10 = 4'd9;
            9'd20:  mod10 = 4'd0;
            9'd21:  mod10 = 4'd1;
            9'd22:  mod10 = 4'd2;
            9'd23:  mod10 = 4'd3;
            9'd24:  mod10 = 4'd4;
            9'd25:  mod10 = 4'd5;
            9'd26:  mod10 = 4'd6;
            9'd27:  mod10 = 4'd7;
            9'd28:  mod10 = 4'd8;
            9'd29:  mod10 = 4'd9;
            9'd30:  mod10 = 4'd0;
            9'd31:  mod10 = 4'd1;
            9'd32:  mod10 = 4'd2;
            9'd33:  mod10 = 4'd3;
            9'd34:  mod10 = 4'd4;
            9'd35:  mod10 = 4'd5;
            9'd36:  mod10 = 4'd6;
            9'd37:  mod10 = 4'd7;
            9'd38:  mod10 = 4'd8;
            9'd39:  mod10 = 4'd9;
            9'd40:  mod10 = 4'd0;
            9'd41:  mod10 = 4'd1;
            9'd42:  mod10 = 4'd2;
            9'd43:  mod10 = 4'd3;
            9'd44:  mod10 = 4'd4;
            9'd45:  mod10 = 4'd5;
            9'd46:  mod10 = 4'd6;
            9'd47:  mod10 = 4'd7;
            9'd48:  mod10 = 4'd8;
            9'd49:  mod10 = 4'd9;
            9'd50:  mod10 = 4'd0;
            9'd51:  mod10 = 4'd1;
            9'd52:  mod10 = 4'd2;
            9'd53:  mod10 = 4'd3;
            9'd54:  mod10 = 4'd4;
            9'd55:  mod10 = 4'd5;
            9'd56:  mod10 = 4'd6;
            9'd57:  mod10 = 4'd7;
            9'd58:  mod10 = 4'd8;
            9'd59:  mod10 = 4'd9;
            9'd60:  mod10 = 4'd0;
            9'd61:  mod10 = 4'd1;
            9'd62:  mod10 = 4'd2;
            9'd63:  mod10 = 4'd3;
            9'd64:  mod10 = 4'd4;
            9'd65:  mod10 = 4'd5;
            9'd66:  mod10 = 4'd6;
            9'd67:  mod10 = 4'd7;
            9'd68:  mod10 = 4'd8;
            9'd69:  mod10 = 4'd9;
            9'd70:  mod10 = 4'd0;
            9'd71:  mod10 = 4'd1;
            9'd72:  mod10 = 4'd2;
            9'd73:  mod10 = 4'd3;
            9'd74:  mod10 = 4'd4;
            9'd75:  mod10 = 4'd5;
            9'd76:  mod10 = 4'd6;
            9'd77:  mod10 = 4'd7;
            9'd78:  mod10 = 4'd8;
            9'd79:  mod10 = 4'd9;
            9'd80:  mod10 = 4'd0;
            9'd81:  mod10 = 4'd1;
            9'd82:  mod10 = 4'd2;
            9'd83:  mod10 = 4'd3;
            9'd84:  mod10 = 4'd4;
            9'd85:  mod10 = 4'd5;
            9'd86:  mod10 = 4'd6;
            9'd87:  mod10 = 4'd7;
            9'd88:  mod10 = 4'd8;
            9'd89:  mod10 = 4'd9;
            9'd90:  mod10 = 4'd0;
            9'd91:  mod10 = 4'd1;
            9'd92:  mod10 = 4'd2;
            9'd93:  mod10 = 4'd3;
            9'd94:  mod10 = 4'd4;
            9'd95:  mod10 = 4'd5;
            9'd96:  mod10 = 4'd6;
            9'd97:  mod10 = 4'd7;
            9'd98:  mod10 = 4'd8;
            9'd99:  mod10 = 4'd9;
            9'd100: mod10 = 4'd0;
            9'd101: mod10 = 4'd1;
            9'd102: mod10 = 4'd2;
            9'd103: mod10 = 4'd3;
            9'd104: mod10 = 4'd4;
            9'd105: mod10 = 4'd5;
            9'd106: mod10 = 4'd6;
            9'd107: mod10 = 4'd7;
            9'd108: mod10 = 4'd8;
            9'd109: mod10 = 4'd9;
            9'd110: mod10 = 4'd0;
            9'd111: mod10 = 4'd1;
            9'd112: mod10 = 4'd2;
            9'd113: mod10 = 4'd3;
            9'd114: mod10 = 4'd4;
            9'd115: mod10 = 4'd5;
            9'd116: mod10 = 4'd6;
            9'd117: mod10 = 4'd7;
            9'd118: mod10 = 4'd8;
            9'd119: mod10 = 4'd9;
            9'd120: mod10 = 4'd0;
            9'd121: mod10 = 4'd1;
            9'd122: mod10 = 4'd2;
            9'd123: mod10 = 4'd3;
            9'd124: mod10 = 4'd4;
            9'd125: mod10 = 4'd5;
            9'd126: mod10 = 4'd6;
            9'd127: mod10 = 4'd7;
            9'd128: mod10 = 4'd8;
            9'd129: mod10 = 4'd9;
            9'd130: mod10 = 4'd0;
            9'd131: mod10 = 4'd1;
            9'd132: mod10 = 4'd2;
            9'd133: mod10 = 4'd3;
            9'd134: mod10 = 4'd4;
            9'd135: mod10 = 4'd5;
            9'd136: mod10 = 4'd6;
            9'd137: mod10 = 4'd7;
            9'd138: mod10 = 4'd8;
            9'd139: mod10 = 4'd9;
            9'd140: mod10 = 4'd0;
            9'd141: mod10 = 4'd1;
            9'd142: mod10 = 4'd2;
            9'd143: mod10 = 4'd3;
            9'd144: mod10 = 4'd4;
            9'd145: mod10 = 4'd5;
            9'd146: mod10 = 4'd6;
            9'd147: mod10 = 4'd7;
            9'd148: mod10 = 4'd8;
            9'd149: mod10 = 4'd9;
            9'd150: mod10 = 4'd0;
            9'd151: mod10 = 4'd1;
            9'd152: mod10 = 4'd2;
            9'd153: mod10 = 4'd3;
            9'd154: mod10 = 4'd4;
            9'd155: mod10 = 4'd5;
            9'd156: mod10 = 4'd6;
            9'd157: mod10 = 4'd7;
            9'd158: mod10 = 4'd8;
            9'd159: mod10 = 4'd9;
            9'd160: mod10 = 4'd0;
            9'd161: mod10 = 4'd1;
            9'd162: mod10 = 4'd2;
            9'd163: mod10 = 4'd3;
            9'd164: mod10 = 4'd4;
            9'd165: mod10 = 4'd5;
            9'd166: mod10 = 4'd6;
            9'd167: mod10 = 4'd7;
            9'd168: mod10 = 4'd8;
            9'd169: mod10 = 4'd9;
            9'd170: mod10 = 4'd0;
            9'd171: mod10 = 4'd1;
            9'd172: mod10 = 4'd2;
            9'd173: mod10 = 4'd3;
            9'd174: mod10 = 4'd4;
            9'd175: mod10 = 4'd5;
            9'd176: mod10 = 4'd6;
            9'd177: mod10 = 4'd7;
            9'd178: mod10 = 4'd8;
            9'd179: mod10 = 4'd9;
            9'd180: mod10 = 4'd0;
            9'd181: mod10 = 4'd1;
            9'd182: mod10 = 4'd2;
            9'd183: mod10 = 4'd3;
            9'd184: mod10 = 4'd4;
            9'd185: mod10 = 4'd5;
            9'd186: mod10 = 4'd6;
            9'd187: mod10 = 4'd7;
            9'd188: mod10 = 4'd8;
            9'd189: mod10 = 4'd9;
            9'd190: mod10 = 4'd0;
            9'd191: mod10 = 4'd1;
            9'd192: mod10 = 4'd2;
            9'd193: mod10 = 4'd3;
            9'd194: mod10 = 4'd4;
            9'd195: mod10 = 4'd5;
            9'd196: mod10 = 4'd6;
            9'd197: mod10 = 4'd7;
            9'd198: mod10 = 4'd8;
            9'd199: mod10 = 4'd9;
            9'd200: mod10 = 4'd0;
            9'd201: mod10 = 4'd1;
            9'd202: mod10 = 4'd2;
            9'd203: mod10 = 4'd3;
            9'd204: mod10 = 4'd4;
            9'd205: mod10 = 4'd5;
            9'd206: mod10 = 4'd6;
            9'd207: mod10 = 4'd7;
            9'd208: mod10 = 4'd8;
            9'd209: mod10 = 4'd9;
            9'd210: mod10 = 4'd0;
            9'd211: mod10 = 4'd1;
            9'd212: mod10 = 4'd2;
            9'd213: mod10 = 4'd3;
            9'd214: mod10 = 4'd4;
            9'd215: mod10 = 4'd5;
            9'd216: mod10 = 4'd6;
            9'd217: mod10 = 4'd7;
            9'd218: mod10 = 4'd8;
            9'd219: mod10 = 4'd9;
            9'd220: mod10 = 4'd0;
            9'd221: mod10 = 4'd1;
            9'd222: mod10 = 4'd2;
            9'd223: mod10 = 4'd3;
            9'd224: mod10 = 4'd4;
            9'd225: mod10 = 4'd5;
            9'd226: mod10 = 4'd6;
            9'd227: mod10 = 4'd7;
            9'd228: mod10 = 4'd8;
            9'd229: mod10 = 4'd9;
            9'd230: mod10 = 4'd0;
            9'd231: mod10 = 4'd1;
            9'd232: mod10 = 4'd2;
            9'd233: mod10 = 4'd3;
            9'd234: mod10 = 4'd4;
            9'd235: mod10 = 4'd5;
            9'd236: mod10 = 4'd6;
            9'd237: mod10 = 4'd7;
            9'd238: mod10 = 4'd8;
            9'd239: mod10 = 4'd9;
            9'd240: mod10 = 4'd0;
            9'd241: mod10 = 4'd1;
            9'd242: mod10 = 4'd2;
            9'd243: mod10 = 4'd3;
            9'd244: mod10 = 4'd4;
            9'd245: mod10 = 4'd5;
            9'd246: mod10 = 4'd6;
            9'd247: mod10 = 4'd7;
            9'd248: mod10 = 4'd8;
            9'd249: mod10 = 4'd9;
            9'd250: mod10 = 4'd0;
            9'd251: mod10 = 4'd1;
            9'd252: mod10 = 4'd2;
            9'd253: mod10 = 4'd3;
            9'd254: mod10 = 4'd4;
            9'd255: mod10 = 4'd5;
            9'd256: mod10 = 4'd6;
            9'd257: mod10 = 4'd7;
            9'd258: mod10 = 4'd8;
            9'd259: mod10 = 4'd9;
            9'd260: mod10 = 4'd0;
            9'd261: mod10 = 4'd1;
            9'd262: mod10 = 4'd2;
            9'd263: mod10 = 4'd3;
            9'd264: mod10 = 4'd4;
            9'd265: mod10 = 4'd5;
            9'd266: mod10 = 4'd6;
            9'd267: mod10 = 4'd7;
            9'd268: mod10 = 4'd8;
            9'd269: mod10 = 4'd9;
            9'd270: mod10 = 4'd0;
            9'd271: mod10 = 4'd1;
            9'd272: mod10 = 4'd2;
            9'd273: mod10 = 4'd3;
            9'd274: mod10 = 4'd4;
            9'd275: mod10 = 4'd5;
            9'd276: mod10 = 4'd6;
            9'd277: mod10 = 4'd7;
            9'd278: mod10 = 4'd8;
            9'd279: mod10 = 4'd9;
            9'd280: mod10 = 4'd0;
            9'd281: mod10 = 4'd1;
            9'd282: mod10 = 4'd2;
            9'd283: mod10 = 4'd3;
            9'd284: mod10 = 4'd4;
            9'd285: mod10 = 4'd5;
            9'd286: mod10 = 4'd6;
            9'd287: mod10 = 4'd7;
            9'd288: mod10 = 4'd8;
            9'd289: mod10 = 4'd9;
            9'd290: mod10 = 4'd0;
            9'd291: mod10 = 4'd1;
            9'd292: mod10 = 4'd2;
            9'd293: mod10 = 4'd3;
            9'd294: mod10 = 4'd4;
            9'd295: mod10 = 4'd5;
            9'd296: mod10 = 4'd6;
            9'd297: mod10 = 4'd7;
            9'd298: mod10 = 4'd8;
            9'd299: mod10 = 4'd9;
            9'd300: mod10 = 4'd0;
            9'd301: mod10 = 4'd1;
            9'd302: mod10 = 4'd2;
            9'd303: mod10 = 4'd3;
            9'd304: mod10 = 4'd4;
            9'd305: mod10 = 4'd5;
            9'd306: mod10 = 4'd6;
            9'd307: mod10 = 4'd7;
            9'd308: mod10 = 4'd8;
            9'd309: mod10 = 4'd9;
            9'd310: mod10 = 4'd0;
            9'd311: mod10 = 4'd1;
            9'd312: mod10 = 4'd2;
            9'd313: mod10 = 4'd3;
            9'd314: mod10 = 4'd4;
            9'd315: mod10 = 4'd5;
            9'd316: mod10 = 4'd6;
            9'd317: mod10 = 4'd7;
            9'd318: mod10 = 4'd8;
            9'd319: mod10 = 4'd9;
            9'd320: mod10 = 4'd0;
            9'd321: mod10 = 4'd1;
            9'd322: mod10 = 4'd2;
            9'd323: mod10 = 4'd3;
            9'd324: mod10 = 4'd4;
            9'd325: mod10 = 4'd5;
            9'd326: mod10 = 4'd6;
            9'd327: mod10 = 4'd7;
            9'd328: mod10 = 4'd8;
            9'd329: mod10 = 4'd9;
            9'd330: mod10 = 4'd0;
            9'd331: mod10 = 4'd1;
            9'd332: mod10 = 4'd2;
            9'd333: mod10 = 4'd3;
            9'd334: mod10 = 4'd4;
            9'd335: mod10 = 4'd5;
            9'd336: mod10 = 4'd6;
            9'd337: mod10 = 4'd7;
            9'd338: mod10 = 4'd8;
            9'd339: mod10 = 4'd9;
            9'd340: mod10 = 4'd0;
            9'd341: mod10 = 4'd1;
            9'd342: mod10 = 4'd2;
            9'd343: mod10 = 4'd3;
            9'd344: mod10 = 4'd4;
            default: mod10 = 4'dx; // x for unknown/invalid values
        endcase
    end
endfunction*/

endmodule