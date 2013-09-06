defexception Vex.InvalidValidationTypeError, [file: nil, line: nil, validation: nil] do
  def message(exception) do
    "#{Exception.format_file_line(exception.file, exception.line)}#{exception.validation}"
  end
end