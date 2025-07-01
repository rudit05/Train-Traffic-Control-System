module TrainTrafficControl #(
    parameter TIMEOUT = 5 // Timeout cycles before forcing clearance
)(
    input clk,                    // Clock
    input reset,                  // Reset
    input [3:0] train_request,     // Train requests: T1 [0], T2 [1], T3 [2], T4 [3]
    input train_done,              // Indicates train has completed crossing
    output reg [2:0] grant         // 3-bit encoded grant signal
);

// State encoding
localparam IDLE     = 3'd0,
           GRANT_T1 = 3'd1,
           GRANT_T2 = 3'd2,
           GRANT_T3 = 3'd3,
           GRANT_T4 = 3'd4;

reg [2:0] state, next_state;  // Current and next state
reg [3:0] timer;              // Timeout counter

// Sequential logic: state and timer update
always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        timer <= 0;
        grant <= 3'b000; // IDLE
    end else begin
        state <= next_state;

        // Timer logic
        if (state != IDLE && timer < TIMEOUT)
            timer <= timer + 1;
        else if (state == IDLE)
            timer <= 0;

        // Grant logic
        case (next_state)
            GRANT_T1: grant <= 3'b001;
            GRANT_T2: grant <= 3'b010;
            GRANT_T3: grant <= 3'b011;
            GRANT_T4: grant <= 3'b100;
            default:  grant <= 3'b000; // IDLE
        endcase
    end
end

// Combinational next-state logic
always @(*) begin
    next_state = state;

    case (state)
        IDLE: begin
            // Priority encoder: T1 > T2 > T3 > T4
            if (train_request[0])       next_state = GRANT_T1;
            else if (train_request[1])  next_state = GRANT_T2;
            else if (train_request[2])  next_state = GRANT_T3;
            else if (train_request[3])  next_state = GRANT_T4;
            else                        next_state = IDLE;
        end

        // Grant states: wait for done or timeout, then move on
        GRANT_T1, GRANT_T2, GRANT_T3, GRANT_T4: begin
            if (train_done) begin
                // Safe to check for next request
                if (train_request[0])       next_state = GRANT_T1;
                else if (train_request[1])  next_state = GRANT_T2;
                else if (train_request[2])  next_state = GRANT_T3;
                else if (train_request[3])  next_state = GRANT_T4;
                else                        next_state = IDLE;
            end else if (timer >= TIMEOUT) begin
                // Timeout: go to safe state
                next_state = IDLE;
            end
        end

        default: next_state = IDLE;
    endcase
end

endmodule
