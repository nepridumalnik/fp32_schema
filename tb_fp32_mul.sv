`timescale 1ns / 1ps

module tb_fp32_mul;
  logic [31:0] a, b, result;

  fp32_mul uut (
      .a(a),
      .b(b),
      .result(result)
  );

  task test_case(input [31:0] in_a, input [31:0] in_b);
    begin
      a = in_a;
      b = in_b;
      #10;
      $display("a = %h, b = %h -> result = %h", a, b, result);
    end
  endtask

  initial begin
    $dumpfile("out/wave.vcd");
    $dumpvars(0, tb_fp32_mul);

    // Примеры
    // https://gregstoll.com/~gregstoll/floattohex
    test_case(32'h3F800000, 32'h40000000);  // 1.0 * 2.0
    test_case(32'h40A00000, 32'h00000000);  // 5.0 * 0.0
    test_case(32'h00000000, 32'h3F800000);  // 0.0 * 1.0
    test_case(32'h7F800000, 32'h3F800000);  // inf * 1.0
    test_case(32'h3F800000, 32'h7F800000);  // 1.0 * inf
    test_case(32'h7F800000, 32'h00000000);  // inf * 0.0 = NaN
    test_case(32'h7FC00001, 32'h3F800000);  // NaN * 1.0
    test_case(32'h3F800000, 32'h7FC00001);  // 1.0 * NaN
    test_case(32'h4F000000, 32'h4F000000);  // 2^31 * 2^31 = overflow
    test_case(32'h00800000, 32'h00800000);  // denormal * denormal = underflow
    $finish;
  end
endmodule
