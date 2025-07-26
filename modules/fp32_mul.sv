module fp32_mul (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result
);
  // Разбивка на компоненты
  logic [7:0] exp_a, exp_b;
  logic [22:0] frac_a, frac_b;
  logic [23:0] mant_a, mant_b;
  logic [47:0] mant_res;
  logic [7:0] exp_res;
  logic [9:0] exp_sum;

  // Особые случаи
  wire is_zero_a = (a[30:23] == 8'd0) && (a[22:0] == 0);
  wire is_zero_b = (b[30:23] == 8'd0) && (b[22:0] == 0);
  wire is_inf_a = (a[30:23] == 8'hFF) && (a[22:0] == 0);
  wire is_inf_b = (b[30:23] == 8'hFF) && (b[22:0] == 0);
  wire is_nan_a = (a[30:23] == 8'hFF) && (a[22:0] != 0);
  wire is_nan_b = (b[30:23] == 8'hFF) && (b[22:0] != 0);

  always_comb begin
    // Спец. случаи
    if (is_nan_a || is_nan_b) result = 32'h7FC00000;  // Quiet NaN
    else if ((is_inf_a && is_zero_b) || (is_inf_b && is_zero_a)) result = 32'h7FC00000;  // NaN
    else if (is_inf_a || is_inf_b) result = 32'h7F800000;  // +Inf
    else if (is_zero_a || is_zero_b) result = 32'h00000000;  // +0
    else begin
      // Извлечь экспоненты и мантиссы
      exp_a = a[30:23];
      exp_b = b[30:23];
      frac_a = a[22:0];
      frac_b = b[22:0];

      mant_a = {1'b1, frac_a};  // неявная 1
      mant_b = {1'b1, frac_b};
      mant_res = mant_a * mant_b;

      // Сложение экспонент и вычитание bias
      exp_sum = exp_a + exp_b - 127;

      // Нормализация
      if (mant_res[47]) begin
        mant_res = mant_res >> 1;
        exp_sum  = exp_sum + 1;
      end

      if (exp_sum >= 255) result = 32'h7F800000;  // overflow = inf
      else if (exp_sum <= 0) result = 32'h00000000;  // underflow = 0
      else begin
        exp_res = exp_sum[7:0];
        result  = {1'b0, exp_res, mant_res[46:24]};  // truncate
      end
    end
  end
endmodule
