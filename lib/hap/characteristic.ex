defmodule HAP.Characteristic do
  @moduledoc """
  Functions to aid in the manipulation of characteristics tuples
  """

  @typedoc """
  Represents a single characteristic consisting of a static definition and a value source
  """
  @type t :: {module(), value_source()}

  @typedoc """
  Represents a source for a characteristic value. May be either a static literal or 
  a `{mod, opts}` tuple which is consulted when reading / writing a characteristic
  """
  @type value_source :: value() | {HAP.ValueStore.t(), value_opts: HAP.ValueStore.opts()}

  @typedoc """
  The resolved value of a characteristic
  """
  @type value :: any()

  @doc false
  def get_type({characteristic_definition, _value_source}) do
    characteristic_definition.type()
  end

  @doc false
  def get_perms({characteristic_definition, _value_source}) do
    characteristic_definition.perms()
  end

  @doc false
  def get_format({characteristic_definition, _value_source}) do
    characteristic_definition.format()
  end

  @doc false
  def get_meta({characteristic_definition, _value_source}) do
    [
      {:format, :format},
      {:minValue, :min_value},
      {:maxValue, :max_value},
      {:minStep, :step_value},
      {:unit, :unit},
      {:maxLength, :max_length}
    ]
    |> Enum.reduce(%{}, fn {return_key, call_key}, acc ->
      if function_exported?(characteristic_definition, call_key, 0) do
        Map.put(acc, return_key, apply(characteristic_definition, call_key, []))
      else
        acc
      end
    end)
  end

  @doc false
  def get_value({characteristic_definition, value_source}, :pr) do
    if "pr" in characteristic_definition.perms() do
      if function_exported?(characteristic_definition, :event_only, 0) && characteristic_definition.event_only() do
        {:ok, nil}
      else
        get_value_from_source(value_source)
      end
    else
      {:error, -70_405}
    end
  end

  def get_value({characteristic_definition, value_source}, :ev) do
    if "ev" in characteristic_definition.perms() do
      get_value_from_source(value_source)
    else
      {:error, -70_405}
    end
  end

  @doc false
  def get_value!(characteristic, disposition) do
    {:ok, value} = get_value(characteristic, disposition)
    value
  end

  @doc false
  def put_value({characteristic_definition, value_source}, value) do
    if "pw" in characteristic_definition.perms() do
      put_value_to_source(value_source, value)
    else
      {:error, -70_404}
    end
  end

  @doc false

  def set_change_token({_characteristic_definition, {mod, opts}}, token) do
    if function_exported?(mod, :set_change_token, 2) do
      mod.set_change_token(token, opts)
    else
      {:error, -70_406}
    end
  end

  def set_change_token({_characteristic_definition, _value_source}, _token) do
    raise "Cannot set change token on a statically defined characteristic"
  end

  defp get_value_from_source({mod, opts}) do
    mod.get_value(opts)
  end

  defp get_value_from_source(value) do
    {:ok, value}
  end

  defp put_value_to_source({mod, opts}, value) do
    mod.put_value(value, opts)
  end

  defp put_value_to_source(_value, _new_value) do
    raise "Cannot write to a statically defined characteristic"
  end
end
