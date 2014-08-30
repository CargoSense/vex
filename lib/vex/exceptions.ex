defmodule Vex.InvalidValidatorError do
  defexception [file: nil, line: nil, validator: nil, sources: []]

  def message(exception) do
    "#{Exception.format_file_line(exception.file, exception.line)}validator #{inspect exception.validator} from sources #{inspect exception.sources}"
  end
end
