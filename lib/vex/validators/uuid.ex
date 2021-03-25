defmodule Vex.Validators.Uuid do
  @moduledoc """
  Ensure a value is a valid UUID string.

  ## Options

  At least one of the following must be provided:

  * `:format`: Required. An atom that defines the UUID format of the value:

    * `:default`: The value must be a string with format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx`.
    * `:hex`: The value must be a string with the format `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`.
    * `:urn`: The value must be a string with the format `urn:uuid:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxxx`.
    * `:any`: The value must be a string of any of the supported formats (`:default`, `:hex` or `:urn`).
    * `:not_any`: The value must not be a valid UUID string.

  *Note: `x` is a hex number.*

  Optional:

  * `:message`: A custom error message. May be in EEx format
    and use the fields described in [Custom Error Messages](#module-custom-error-messages).
  * `:allow_nil`: A boolean whether to skip this validation for `nil` values.
  * `:allow_blank`: A boolean whether to skip this validation for blank values.

  The value for `:format` can be provided instead of the options keyword list.
  Additionally, if the options is a boolean value, then:

  * `true`: Is the same as the `[format: :any]` options.
  * `false`: Is the same as the `[format: :not_any]` options.

  ## Examples

  When using the `:any` or `true` options:

      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", format: :any)
      :ok
      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a30", format: :any)
      {:error, "must be a valid UUID string"}

      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", true)
      :ok
      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a30", true)
      {:error, "must be a valid UUID string"}

  When using the `:not_any` or `false` options:

      iex> Vex.Validators.Uuid.validate("not_a_uuid", format: :not_any)
      :ok
      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", format: :not_any)
      {:error, "must not be a valid UUID string"}

      iex> Vex.Validators.Uuid.validate("not_a_uuid", false)
      :ok
      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", false)
      {:error, "must not be a valid UUID string"}

  When using the `:default` option:

      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", format: :default)
      :ok
      iex> Vex.Validators.Uuid.validate("02aa7f483ccd11e4b63e14109ff1a304", format: :default)
      {:error, "must be a valid UUID string in default format"}

  When using the `:hex` option:

      iex> Vex.Validators.Uuid.validate("02aa7f483ccd11e4b63e14109ff1a304", format: :hex)
      :ok
      iex> Vex.Validators.Uuid.validate("urn:uuid:02aa7f48-3ccd-11e4-b63e-14109ff1a304", format: :hex)
      {:error, "must be a valid UUID string in hex format"}

  When using the `:urn` option:

      iex> Vex.Validators.Uuid.validate("urn:uuid:02aa7f48-3ccd-11e4-b63e-14109ff1a304", format: :urn)
      :ok
      iex> Vex.Validators.Uuid.validate("02aa7f48-3ccd-11e4-b63e-14109ff1a304", format: :urn)
      {:error, "must be a valid UUID string in urn format"}

  ## Custom Error Messages

  Custom error messages (in EEx format), provided as `:message`, can use the following values:

      iex> Vex.Validators.Uuid.__validator__(:message_fields)
      [value: "Bad value", format: "The UUID format"]

  An example:

      iex> Vex.Validators.Uuid.validate("not_a_uuid", format: :any,
      ...>                                            message: "<%= value %> should be <%= format %> UUID")
      {:error, "not_a_uuid should be any UUID"}
  """

  use Vex.Validator

  @uuid_formats [:default, :hex, :urn]

  @formats [:any, :not_any] ++ @uuid_formats

  @urn_prefix "urn:uuid:"

  @message_fields [value: "Bad value", format: "The UUID format"]
  def validate(value, true), do: validate(value, format: :any)
  def validate(value, false), do: validate(value, format: :not_any)
  def validate(value, options) when options in @formats, do: validate(value, format: options)

  def validate(value, options) when is_list(options) do
    unless_skipping value, options do
      format = options[:format]

      case do_validate(value, format) do
        :ok -> :ok
        {:error, reason} -> {:error, message(options, reason, value: value, format: format)}
      end
    end
  end

  defp do_validate(<<_::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>>, :default) do
    :ok
  end

  defp do_validate(<<_::256>>, :hex) do
    :ok
  end

  defp do_validate(<<@urn_prefix, _::64, ?-, _::32, ?-, _::32, ?-, _::32, ?-, _::96>>, :urn) do
    :ok
  end

  defp do_validate(_, format) when format in @uuid_formats do
    {:error, "must be a valid UUID string in #{format} format"}
  end

  defp do_validate(value, :any) do
    error = {:error, "must be a valid UUID string"}

    Enum.reduce_while(@uuid_formats, error, fn format, _ ->
      case do_validate(value, format) do
        :ok -> {:halt, :ok}
        _ -> {:cont, error}
      end
    end)
  end

  defp do_validate(value, :not_any) do
    case do_validate(value, :any) do
      :ok -> {:error, "must not be a valid UUID string"}
      _ -> :ok
    end
  end

  defp do_validate(_, format) do
    raise "Invalid value #{inspect(format)} for option :format"
  end
end
