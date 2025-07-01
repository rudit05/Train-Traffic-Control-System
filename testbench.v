`timescale 1ns/1ps

module tb_TrainTrafficControl;

  reg clk;
  reg reset;
  reg [3:0] train_request;
  reg train_done;
  wire [2:0] grant;

  TrainTrafficControl dut (
    .clk(clk),
    .reset(reset),
    .train_request(train_request),
    .train_done(train_done),
    .grant(grant)
  );

  // Clock: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    // Initialize
    reset = 1;
    train_request = 4'b0000;
    train_done = 0;

    #20;
    reset = 0;

    // ---------- Test IDLE ----------
    train_request = 4'b0000;  // no requests
    train_done = 0;
    #30;
    // Should stay in IDLE, grant = 000

    // ---------- Test GRANT_T1 ----------
    train_request = 4'b0001;  // T1 request
    train_done = 0;
    #10;
    // Should grant T1: grant = 001
    #30;
    train_done = 1;           // indicate T1 crossing done
    #10;
    train_done = 0;
    #20;
    // After done, no request -> IDLE

    // ---------- Test GRANT_T2 ----------
    train_request = 4'b0010;  // T2 request
    train_done = 0;
    #10;
    // Should grant T2: grant = 010
    #30;
    train_done = 1;           // T2 done
    #10;
    train_done = 0;
    #20;
    train_request = 4'b0000;  // no requests
    #20;

    // ---------- Test GRANT_T3 ----------
    train_request = 4'b0100;  // T3 request
    train_done = 0;
    #10;
    // Should grant T3: grant = 011
    #30;
    train_done = 1;           // T3 done
    #10;
    train_done = 0;
    #20;
    train_request = 4'b0000;
    #20;

    // ---------- Test GRANT_T4 ----------
    train_request = 4'b1000;  // T4 request
    train_done = 0;
    #10;
    // Should grant T4: grant = 100
    #30;
    train_done = 1;           // T4 done
    #10;
    train_done = 0;
    #20;
    train_request = 4'b0000;
    #20;

    // ---------- Test Timeout from GRANT_T1 ----------
    train_request = 4'b0001;  // T1 request
    train_done = 0;
    // Wait longer than TIMEOUT cycles (TIMEOUT=5, clock=10ns, so 50ns + margin)
    #70;
    // Should timeout to IDLE automatically

    // Finish simulation
    $finish;
  end

  initial begin
    $display("Time\treset\ttrain_req\ttrain_done\tgrant");
    $monitor("%0t\t%b\t%04b\t\t%b\t\t%03b", $time, reset, train_request, train_done, grant);
  end

endmodule
