module TTCS(input clk, rst, req_valid,
            input [3:0] train_req, 
            output [2:0] approved_train,
            output req_accepted);
  
    parameter [2:0] time_out = 5;
    parameter [2:0] IDLE = 0, T1 = 1, T2 = 2, T3 = 3, T4 = 4;
    reg [2:0] ps, ns;
    reg [2:0] counter;
  
    always @(posedge clk) begin
        if(rst) begin
            ps <= IDLE;
            counter <= 0;
        end
        else begin
            if (((counter >= time_out) || (counter == 0)) && req_valid) begin
                ps <= ns;
                counter <= 1;
            end
            else if (ps != IDLE || req_valid) begin
                counter <= counter + 1;
            end
            else counter <= 0;
        end
    end
  
    always @(*) begin
        if (counter == 0 || counter == 5)begin 
   	    case (ps)
    	   IDLE : begin
                casex (train_req)
	               4'b0000 : ns = IDLE;
    	           4'b0001 : ns = T1;
        	       4'b001x : ns = T2;
    	           4'b01xx : ns = T3;
             	   4'b1xxx : ns = T4;
        	       default : ns = IDLE;
        	   endcase
     	      end
           T4 : begin
        	   casex (train_req[2:0])
   	 	          3'b000 : ns = IDLE;
        	      3'b001 : ns = T1;
    	          3'b01x : ns = T2;
         	      3'b1xx : ns = T3;
      	       endcase
    	      end
   		   T3 : begin
              casex (train_req[1:0])
                 2'b00 : ns = IDLE;
                 2'b01 : ns = T1;
                 2'b1x : ns = T2;
              endcase
            end
           T2 : begin
             casex (train_req[0])
               1'b0 : ns = IDLE;
               1'b1 : ns = T1;
             endcase
           end
           T1 : ns = IDLE;
           endcase
        end
    end
    
    
    assign approved_train = ps;
    assign req_accepted = (ps != IDLE) && (ns == IDLE);
  
endmodule
