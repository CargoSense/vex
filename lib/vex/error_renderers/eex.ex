defmodule Vex.ErrorRenderers.EEx do
  @behaviour Vex.ErrorRenderer

  @doc """

  ## Examples

      iex> Vex.ErrorRenderers.EEx.message(nil, "default")
      "default"
      iex> Vex.ErrorRenderers.EEx.message([message: "override"], "default")
      "override"
      iex> Vex.ErrorRenderers.EEx.message([message: "Context #<%= value %>"], "default", value: 2)
      "Context #2"
  """
  def message(options, default, context \\ []) do
    message = Vex.ErrorRenderer.get_message(options, default)
    message |> EEx.eval_string(context)
  end
end
