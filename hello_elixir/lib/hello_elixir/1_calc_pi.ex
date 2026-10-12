defmodule HelloElixir.CalcPi do

  def calc_fraction({_numerator1, 0}, {_numerator2, _}, _) do
    raise ArgumentError, "denominator1 cannot be zero"
  end
  def calc_fraction({_numerator1, _}, {_numerator2, 0}, _) do
    raise ArgumentError, "denominator2 cannot be zero"
  end
  def calc_fraction({numerator1, denominator1}, {numerator2, denominator2}, mod) do
    case mod do
      :add ->
        simplify({
          numerator1 * denominator2 + numerator2 * denominator1,
          denominator1 * denominator2
        })
      :sub ->
        simplify({
          numerator1 * denominator2 - numerator2 * denominator1,
          denominator1 * denominator2
        })
      _ ->
        raise ArgumentError, "invalid operation: #{mod}"
    end
  end

  def simplify({_numerator, 0}) do
    raise ArgumentError, "denominator cannot be zero"
  end
  def simplify({numerator, denominator}) do
      gcd = Integer.gcd(numerator, denominator)
      sign = if denominator < 0, do: -1, else: 1
      {
        div(numerator, gcd) * sign,
        div(denominator, gcd) * sign
      }
  end

  def arctan(_, n) when n <= 0, do: {0, 1}
  ## 计算 arctan(1/denominator) 的值，使用泰勒级数展开
  def arctan(denominator, n) do
    Enum.reduce(0..(n-1), {0, 1}, fn n0 , acc ->
      arctan_term = arctan_term(denominator, n0)
      calc_fraction(acc, arctan_term, :add)
    end)
  end

  def arctan_term(denominator0, n) do
    numerator = Integer.pow(-1, n)
    denominator = (2 * n + 1) * Integer.pow(denominator0, 2 * n + 1)
    {numerator, denominator}
  end

  def calc_pi(digits) when not is_integer(digits) or digits <= 0  do
    raise ArgumentError, "digits must be a positive integer"
  end
  def calc_pi(digits) do
    integer = calc_pi_loop(0, digits, {0, 1}, {0, 1})
    |> fraction_to_scaled_integer(digits)
    str1 = Integer.to_string(integer)
    str2 = String.pad_leading(str1, digits + 1, "0")
    {integer_part_str, decimal_part_str} = String.split_at(str2, String.length(str2) - digits)
    integer_part_str <> "." <> decimal_part_str
  end

  defp calc_pi_loop(n, digits, acc_a, acc_b) do
    frac1 = arctan_term(5, n)
    frac2 = arctan_term(239, n)
    {numerator1, denominator1} = new_acc_a = calc_fraction(acc_a, frac1, :add)
    {numerator2, denominator2} = new_acc_b = calc_fraction(acc_b, frac2, :add)
    pi_fraction  =  calc_fraction({16 * numerator1, denominator1}, {4 * numerator2, denominator2}, :sub)
    ## 前 n 项之和的误差小于等于第 n+1 项的绝对值
    {numerator3, denominator3} = arctan_term(5, n + 1)
    {numerator4, denominator4} = arctan_term(239, n + 1)
    error_fraction = calc_fraction(
      {16 * abs(numerator3), denominator3},
      {4 * abs(numerator4), denominator4},
      :add
    )
    left = calc_fraction(pi_fraction, error_fraction, :sub)
    right = calc_fraction(pi_fraction, error_fraction, :add)
    if fraction_to_scaled_integer(left, digits) == fraction_to_scaled_integer(right, digits) do
      pi_fraction
    else
      calc_pi_loop(n + 1, digits, new_acc_a, new_acc_b)
    end
  end

  ## 计算 numerator/denominator 的值，保留 digits 位小数
  def fraction_to_scaled_integer({_numerator, 0}, _digits) do
    raise ArgumentError, "denominator cannot be zero"
  end
  def fraction_to_scaled_integer({numerator, denominator}, digits) do
    div(numerator * Integer.pow(10, digits), denominator)
  end

end
