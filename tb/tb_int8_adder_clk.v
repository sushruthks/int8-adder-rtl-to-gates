`timescale 1ns/1ps

module tb_int8_adder_clk;

  reg               clk;
  reg  signed [7:0] a, b;
  wire signed [8:0] result;
  integer expected;
  integer passed = 0;
  integer total  = 0;

  int8_adder_clk dut (.clk(clk), .a(a), .b(b), .result(result));

  // 10 ns clock (100 MHz): rising edges at 5, 15, 25 ... ns
  initial clk = 0;
  always #5 clk = ~clk;

  // Apply one test, then check after ONE rising edge (latency = 1)
  task check(input signed [7:0] ta, input signed [7:0] tb);
    begin
      @(negedge clk);          // change inputs on the FALLING edge
      a = ta;
      b = tb;
      expected = ta + tb;
      @(posedge clk);          // the one edge: result <= a + b
      #1;                      // give result 1 ns to update
      total = total + 1;
      if (result === expected[8:0]) begin
        passed = passed + 1;
        $display("t=%4d ns  A=%4d B=%4d RESULT=%4d (bits %b)  PASS",
                 $time, a, b, result, result);
      end else begin
        $display("t=%4d ns  A=%4d B=%4d RESULT=%4d (bits %b)  expected %4d  FAIL <--",
                 $time, a, b, result, result, expected);
      end
    end
  endtask

  initial begin
    $dumpfile("int8_adder_clk.vcd");
    $dumpvars(0, tb_int8_adder_clk);

    check(  10,   20);   // simple positive          -> 30
    check( 100,   27);   // exactly +127             -> 127
    check(-100,   20);   // negative + positive      -> -80
    check(-128, -128);   // smallest possible        -> -256
    check( 127,  127);   // largest possible         -> 254
    check(  -1,   -1);   // -1 + -1                  -> -2
    check(   5,   -5);   // answer zero              -> 0

    $display("%0d of %0d passed", passed, total);
    #20 $finish;
  end

endmodule

