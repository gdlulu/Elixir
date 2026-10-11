defmodule HelloElixir.CalcPi do

  def subtract({numerator1, denominator1}, {numerator2, denominator2}) do
    {
      numerator1 * denominator2 - numerator2 * denominator1,
      denominator1 * denominator2
    }
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

end
