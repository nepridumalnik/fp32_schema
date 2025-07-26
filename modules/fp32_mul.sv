`include "types.sv"
`include "const.sv"

module fp32_mul (
    input  logic   clk,
    input  Float32 a,
    input  Float32 b,
    output Float32 result
);
  // Шины
  logic [7:0] exp_a, exp_b;
  logic [22:0] frac_a, frac_b;
  logic [23:0] mant_a, mant_b;
  logic [47:0] mant_res;
  logic [9:0] exp_sum;
  logic [7:0] exp_res;
  logic [31:0] res_next;

  // Флаги
  logic is_zero_a;
  logic is_zero_b;
  logic is_inf_a;
  logic is_inf_b;
  logic is_nan_a;
  logic is_nan_b;

  // Комбинаторная логика
  always_comb begin
    exp_a    = a[30:23];
    exp_b    = b[30:23];
    frac_a   = a[22:0];
    frac_b   = b[22:0];

    is_zero_a = (exp_a == 8'd0) && (frac_a == 23'd0);
    is_zero_b = (exp_b == 8'd0) && (frac_b == 23'd0);
    is_inf_a  = (exp_a == 8'hFF) && (frac_a == 23'd0);
    is_inf_b  = (exp_b == 8'hFF) && (frac_b == 23'd0);
    is_nan_a  = (exp_a == 8'hFF) && (frac_a != 23'd0);
    is_nan_b  = (exp_b == 8'hFF) && (frac_b != 23'd0);
  end

  // Основная логика
  always_comb begin
    if (is_nan_a || is_nan_b) res_next = `NAN32;
    else if ((is_inf_a && is_zero_b) || (is_inf_b && is_zero_a)) res_next = `NAN32;
    else if (is_inf_a || is_inf_b) res_next = `P_INF32;
    else if (is_zero_a || is_zero_b) res_next = `ZERO32;
    else begin
      mant_a   = {1'b1, frac_a};
      mant_b   = {1'b1, frac_b};
      mant_res = (mant_a * mant_b);
      exp_sum  = (exp_a + exp_b - 127);

      if (mant_res[47]) begin
        mant_res = mant_res >> 1;
        exp_sum  = exp_sum + 1;
      end

      if (exp_sum >= 255) res_next = `P_INF32;
      else if (exp_sum <= 0) res_next = `ZERO32;
      else begin
        exp_res  = exp_sum[7:0];
        res_next = {1'b0, exp_res, mant_res[46:24]};
      end
    end
  end

  // Синхронная обработка
  always_ff @(posedge clk) begin
    result <= res_next;
  end

endmodule
