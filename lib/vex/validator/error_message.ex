defmodule Vex.Validator.ErrorMessage do

  @doc """
  Extract the error message from validator options or return a default
  """
  def message(options, default) do
    if Keyword.keyword?(options) do
      Keyword.get(options, :message, default)
    else
      default
    end
  end
 
end