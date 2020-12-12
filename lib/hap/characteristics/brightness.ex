defmodule HAP.Characteristics.Brightness do
  @moduledoc """
  Factory for the `public.hap.characteristic.brightness` characteristic
  """

  def type, do: "8"
  def perms, do: ["pr", "pw", "ev"]
  def format, do: "int"
  def min_value, do: 0
  def max_value, do: 100
  def step_unit, do: 1
  def unit, do: "percentage"
end
