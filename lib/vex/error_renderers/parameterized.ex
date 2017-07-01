defmodule Vex.ErrorRenderers.Parameterized do
  @behaviour Vex.ErrorRenderer

  @doc """

  ## Examples

      iex> Vex.ErrorRenderers.Parameterized.message(nil, "default")
      [message: "default", context: []]
      iex> Vex.ErrorRenderers.Parameterized.message([message: "override"], "default")
      [message: "override", context: []]
      iex> Vex.ErrorRenderers.Parameterized.message([message: "Context #<%= value %>"], "default", value: 2)
      [message: "Context #<%= value %>", context: [value: 2]]
  """
  def message(options, default, context \\ []) do
    message = Vex.ErrorRenderer.get_message(options, default)
    [message: message, context: context]
  end
end
