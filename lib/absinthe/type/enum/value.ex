defmodule Absinthe.Type.Enum.Value do

  @moduledoc """
  A possible value for an enum.

  See `Absinthe.Type.Enum` and `Absinthe.Schema.Notation.value/1`.
  """

  alias Absinthe.Type

  @typedoc """
  A defined enum value entry.

  Generally defined using `Absinthe.Schema.Notation.value/2` as
  part of a schema.

  * `:name` - The name of the value. This is also the incoming, external
    value that will be provided by query documents.
  * `:description` - A nice description for introspection.
  * `:value` - The raw, internal value that `:name` map to. This will be
    provided as the argument value to resolve functions.
    to `resolve` functions
  * `:deprecation` - Deprecation information for a value, usually
    set-up using the `Absinthe.Schema.Notation.deprecate/2` convenience
    function.
  """
  @type t :: %{name: binary, description: binary, value: any, deprecation: Type.Deprecation.t | nil, __reference__: Type.Reference.t}
  defstruct name: nil, description: nil, value: nil, deprecation: nil, __reference__: nil

  @spec build(Keyword.t) :: %{atom => Absinthe.Type.Enum.Value.t}
  def build(raw_values) when is_list(raw_values) do
    ast = for {value_name, value_attrs} <- normalize(raw_values) do
      name = value_name |> Atom.to_string
      value_data = [name: name] ++ Keyword.put_new(value_attrs, :value, value_name)
      value_ast = quote do: %Absinthe.Type.Enum.Value{unquote_splicing(value_data |> Absinthe.Type.Deprecation.from_attribute)}
      {value_name, value_ast}
    end
    quote do: %{unquote_splicing(ast)}
  end

  # Normalize shorthand lists of atoms to the keyword list that `values` expects
  @spec normalize([atom] | [{atom, Keyword.t}]) :: [{atom, Keyword.t}]
  defp normalize(raw) do
    if Keyword.keyword?(raw) do
      raw
    else
      raw |> Enum.map(&({&1, []}))
    end
  end

end
