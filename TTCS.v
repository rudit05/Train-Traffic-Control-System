module TrainTrafficControl #(
    parameter TIMEOUT = 5
)(
    input clk,           
    input reset,            
    input [3:0] train_request,  
    input train_done,          
    output reg [2:0] grant      
);

    localparam IDLE     = 3'd0,
               GRANT_T1 = 3'd1,
               GRANT_T2 = 3'd2,
               GRANT_T3 = 3'd3,
               GRANT_T4 = 3'd4;

    reg [2:0] state, next_state;
    reg [3:0] timer;

    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if      (train_request[0]) next_state = GRANT_T1;
                else if (train_request[1]) next_state = GRANT_T2;
                else if (train_request[2]) next_state = GRANT_T3;
                else if (train_request[3]) next_state = GRANT_T4;
                else                       next_state = IDLE;
            end

            GRANT_T1, GRANT_T2, GRANT_T3, GRANT_T4: begin
                if (train_done) begin
                    if      (train_request[0]) next_state = GRANT_T1;
                    else if (train_request[1]) next_state = GRANT_T2;
                    else if (train_request[2]) next_state = GRANT_T3;
                    else if (train_request[3]) next_state = GRANT_T4;
                    else                       next_state = IDLE;
                end else if (timer >= TIMEOUT) begin
                    next_state = IDLE;
                end
            end

            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= IDLE;
            timer  <= 0;
            grant  <= 3'b000;
        end else begin
            state <= next_state;

            if (state != IDLE && timer < TIMEOUT)
                timer <= timer + 1;
            else
                timer <= 0;

          case (next_state)
            GRANT_T1: grant <= 3'b001;
            GRANT_T2: grant <= 3'b010;
            GRANT_T3: grant <= 3'b011;
            GRANT_T4: grant <= 3'b100;
            default:  grant <= 3'b000;
        endcase

        end
    end


endmodule
