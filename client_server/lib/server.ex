defmodule Server do
  
  def start do
    next()
  end

  defp next() do
    receive do
      { :circle, radius, c } -> send c, { :result, 3.14159 * radius * radius }
      { :square, side, c } -> send c, { :result, side * side }
    end
    next()
  end

end
