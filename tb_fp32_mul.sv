`include "types.sv"
`include "const.sv"

`timescale 1ns / 1ps

module tb_fp32_mul;
  logic   clk = 0;
  Float32 a = `ZERO32;
  Float32 b = `ZERO32;
  Float32 result;

  fp32_mul uut (
      .clk(clk),
      .a(a),
      .b(b),
      .result(result)
  );

  // Генерация тактового сигнала
  always #5 clk = ~clk;

  task test_case(input Float32 in_a, input Float32 in_b);
    begin
      a = in_a;
      b = in_b;
      #10;
      $display("a = %h, b = %h -> result = %h", a, b, result);
    end
  endtask

  initial begin
    clk = 0;
    a   = 0;
    b   = 0;

    $dumpfile("out/wave.vcd");
    $dumpvars(0, tb_fp32_mul);

    // Тесты
    // Проверка: https://gregstoll.com/~gregstoll/floattohex/
    test_case(32'h3F800000, 32'h40000000);  // 1.0 * 2.0
    test_case(32'h40A00000, `ZERO32);  // 5.0 * 0.0
    test_case(`ZERO32, 32'h3F800000);  // 0.0 * 1.0
    test_case(`P_INF32, 32'h3F800000);  // inf * 1.0
    test_case(32'h3F800000, `P_INF32);  // 1.0 * inf
    test_case(`P_INF32, `ZERO32);  // inf * 0.0 = NaN
    test_case(`NAN32, 32'h3F800000);  // NaN * 1.0 = NaN
    test_case(32'h3F800000, `NAN32);  // 1.0 * NaN = NaN
    test_case(32'h4F000000, 32'h4F000000);  // 2^31 * 2^31 = overflow
    test_case(32'h00800000, 32'h00800000);  // denormal * denormal = underflow
    $finish;
  end
endmodule
