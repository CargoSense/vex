# Vex

[![Build Status](https://travis-ci.org/CargoSense/vex.svg)](https://travis-ci.org/CargoSense/vex)

An extensible data validation library for Elixir.

Can be used to check different data types for compliance with criteria.

Ships with built-in validators to check for attribute presence, absence,
inclusion, exclusion, format, length, acceptance, and by a custom function.
You can easily define new validators and override existing ones.

Inspired by
-----------

 * Rails ActiveModel Validations
 * Clojure's [Validateur](https://github.com/michaelklishin/validateur)

Supported Validations
---------------------

Note the examples below use `Vex.valid?/2`, with the validations to
check explicitly provided as the second argument. For information on how
validation configuration can be provided as part of a single argument
(eg, packaged with the data to check passed to `Vex.valid?/1`) see
"Configuring Validations" below.

Note all validations can be skipped based on `:if` and `:unless`
conditions given as options. See "Validation Conditions" further below for
more information.

### Presence

Ensure a value is present:

```elixir
Vex.valid? post, title: [presence: true]
```

See the documentation on `Vex.Validators.Presence` for details on
available options.

### Absence

Ensure a value is absent (blank)

```elixir
Vex.valid? post, byline: [absence: true]
```

See the documentation on `Vex.Validators.Absence` for details on
available options.

### Inclusion

Ensure a value is in a list of values:

```elixir
Vex.valid? post, category: [inclusion: ["politics", "food"]]
```

This validation can be skipped for `nil` or blank values by including
`allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.Inclusion` for details on available options.

### Exclusion

Ensure a value is _not_ in a list of values:

```elixir
Vex.valid? post, category: [exclusion: ["oped", "lifestyle"]]
```

See the documentation on `Vex.Validators.Exclusion` for details on available
options.

### Format

Ensure a value matches a regular expression:

```elixir
Vex.valid? widget, identifier: [format: ~r/(^id-)/]
```

This validation can be skipped for `nil` or blank values by including
`allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.Format` for details on
available options.

### Length

Ensure a value's length is at least a given size:

```elixir
Vex.valid? user, username: [length: [min: 2]]
```

Ensure a value's length is at or below a given size:

```elixir
Vex.valid? user, username: [length: [max: 10]]
```

Ensure a value's length is within a range (inclusive):

```elixir
Vex.valid? user, username: [length: [in: 2..10]]
```

This validation can be skipped for `nil` or blank values by including
`allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.Length` for details on
available options.

### Acceptance

Ensure an attribute is set to a positive (or custom) value. For use
expecially with "acceptance of terms" checkboxes in web applications.

```elixir
Vex.valid?(user, accepts_terms: [acceptance: true])
```

To check for a specific value, use `:as`:

```elixir
Vex.valid?(user, accepts_terms: [acceptance: [as: "yes"]])
```

See the documentation on `Vex.Validators.Acceptance` for details on
available options.

### Confirmation

Ensure a value has a matching confirmation:

```elixir
Vex.valid? user, password: [confirmation: true]
```

The above would ensure the values of `password` and
`password_confirmation` are equivalent.

This validation can be skipped for `nil` or blank values by
including `allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.confirmation` for details
on available options.

### Custom Function

You can also just provide a custom function for validation instead of
a validator name:

```elixir
Vex.valid?(user, password: fn (pass) -> byte_size(pass) > 4 end)
Vex.valid? user, password: &valid_password?/1
Vex.valid?(user, password: &(&1 != "god"))
```

Instead of returning a boolean the validate function may return `:ok`
on success, or `{:error, "a message"}` on error:

```elixir
Vex.valid?(user, password: fn (password) ->
  if valid_password?(password) do
    :ok
  else
    {:error, "#{password} isn't a valid password"}
  end
end)
```

Or explicitly using `:by`:

```elixir
Vex.valid?(user, age: [by: &(&1 > 18)])
```

This validation can be skipped for `nil` or blank values by including
`allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.By` for details on available options.

Validation Conditions
---------------------

A validation can be made applicable (or unapplicable) by using the `:if`,
`:if_any`, `:unless` and `:unless_any` options.

Note `Vex.results` will return tuples with `:not_applicable` for validations that
are skipped as a result of failing conditions.

### Based on another attribute's presence

Require a post to have a `body` of at least 200 bytes unless a non-blank
`reference_url` is provided.

```elixir
iex> Vex.valid?(post, body: [length: [min: 200, unless: :reference_url]])
```

### Based on other attributes' presence

Require a post to have a `body` of at least 200 bytes unless a non-blank
`reference_url`__and__ `category` are provided.

```elixir
iex> Vex.valid?(post, body: [length: [min: 200, unless: [:reference_url, :category]]])
```

Require a post to have a `body` of at least 200 bytes unless a non-blank
`reference_url` __or__ `category` is provided.

```elixir
iex> Vex.valid?(post, body: [length: [min: 200, unless_any: [:reference_url, :category]]])
```

### Based on another attribute's value

Only require a password if the `state` of a user is `:new`:

```elixir
iex> Vex.valid?(user, password: [presence: [if: [state: :new]]]
```

### Based on other attributes' value

Only require a password if the `state` of a user is `:new` __and__ she is not from Facebook:

```elixir
iex> Vex.valid?(user, password: [presence: [if: [state: :new, from_facebook: false]]]
```

Only require a password if the `state` of a user is `:new` __or__ she is not from Facebook:

```elixir
iex> Vex.valid?(user, password: [presence: [if_any: [state: :new, from_facebook: false]]]
```

### Based on a custom function

Don't require users from Facebook to provide an email address:

```elixir
iex> Vex.valid?(user, email: [presence: [unless: &User.from_facebook?/1]]
```

Require users less than 13 years of age to provide a parent's email address:

```elixir
iex> Vex.valid?(user, parent_email: [presence: [if: &(&1.age < 13)]]
```

Configuring Validations
-----------------------

The examples above use `Vex.valid?/2`, passing both the data to
be validated and the validation settings. This is nice for ad hoc data
validation, but wouldn't it be nice to just:

```elixir
Vex.valid?(data)
```

... and have the data tell Vex which validations should be evaluated?

### In Structs

In your struct module, use `Vex.Struct`:

```elixir
defmodule User do
  defstruct username: nil, password: nil, password_confirmation: nil
  use Vex.Struct

  validates :username, presence: true,
                       length: [min: 4],
                       format: ~r/^[[:alpha:]][[:alnum:]]+$/
  validates :password, length: [min: 4],
                       confirmation: true
end
```

Note `validates` should only be used once per attribute.

Once configured, you can use `Vex.valid?/1`:

```elixir
user = %User{username: "actualuser",
             password: "abcdefghi",
             password_confirmation: "abcdefghi"}

Vex.valid?(user)
```

You can also use `valid?` directly from the Module:

```elixir
user |> User.valid?
```

### In Keyword Lists

In your list, just include a `:_vex` entry and use `Vex.valid?/1`:

```elixir
user = [username: "actualuser",
        password: "abcdefghi",
        password_confirmation: "abcdefghi",
        _vex: [username: [presence: true,
                          length: [min: 4],
                          format: ~r/^[[:alpha:]][[:alnum:]]+$/]],
               password: [length: [min: 4], confirmation: true]]
Vex.valid?(user)
```

### Others

Just implement the `Vex.Extract` protocol. Here's what was done to
support keyword lists:

```elixir
defimpl Vex.Extract, for: List do
  def settings(data) do
    Keyword.get data, :_vex
  end
  def attribute(data, name) do
    Keyword.get data, name
  end
end
```

Querying Results
----------------

For validity, it's the old standard, `Vex.valid?/1`:

```elixir
iex> Vex.valid?(user)
true
```

(If you need to pass in the validations to use, do that as a second argument to
`Vex.valid?/2`)

You can access the raw validation results using `Vex.results/1`:

```elixir
iex> Vex.results(user)
[{:ok, :username, :presence},
 {:ok, :username, :length},
 {:ok, :username, :format}]
```

If you only want the errors, use `Vex.errors/1`:

```elixir
iex> Vex.errors(another_user)
[{:error, :password, :length, "must have a length of at least 4"},
 {:error, :password, :confirmation, "must match its confirmation"}]
 ```

Error Message Renderers
-----------------------

By default Vex uses `Vex.ErrorRenderers.EEx` as default renderer, also have
`Vex.ErrorRenderers.Parameterized`, and you have ability to define your own.

For example if we want to use [Linguist](https://github.com/chrismccord/linguist)
for internationalization, we can do the following:


```elixir
  defmodule I18nErrorRenderer do
    @behaviour Vex.ErrorRenderer
    use Linguist.Vocabulary

    locale "en", [
      foo: [
        too_short: "too short, min %{min} chars",
        must_start_with_f: "must start with an f",
      ],
    ]

    locale "kr", [
      foo: [
        too_short: "너무 짧으면, 최소 %{min} 개 문자",
        must_start_with_f: "f로 시작해야합니다",
      ],
    ]

    def message(options, _default, context \\ []) do
      message = options[:message] || raise "message is needed for proper i18n"
      locale = options[:locale] || "en"
      t!(locale, message, context)
    end
  end

  result = Vex.validate([name: "Foo"], name: [
    length: [
      min: 4,
      error_renderer: I18nErrorRenderer,
      message: "foo.too_short"
    ],
    format: [
      with: ~r/^f/,
      locale: "kr",
      error_renderer: I18nErrorRenderer,
      message: "foo.must_start_with_f",
    ]
  ])
  assert {:error, [
    {:error, :name, :length, "too short, min 4 chars"},
    {:error, :name, :format, "f로 시작해야합니다"}
  ]} = result
```

We can set error renderer globally:

```elixir
config :vex,
  error_renderer: Vex.ErrorRenderers.Parameterized
```

Validators declare a list of the available message fields and their
descriptions by setting the module attribute `@message_fields` (see
`Vex.Validator.ErrorMessage`), and the metadata is available for querying:

```elixir
iex> Vex.Validators.Length.__validator__(:message_fields)
[value: "Bad value", tokens: "Tokens from value", size: "Number of tokens",
 min: "Minimum acceptable value", max: "Maximum acceptable value"]
```

Custom EEx Error Renderer Messages
---------------------

Custom error messages can be requested by validations when providing the
`:message` option and can use EEx to insert fields specific to the validator, eg:

```elixir
validates :body, length: [min: 4,
                          tokenizer: &String.split/1,
                          message: "<%= length tokens %> words isn't enough"]
```

This could yield, in the case of a `:body` value `"hello my darling"`, the result:

```elixir
{:error, "3 words isn't enough"}
```

Adding and Overriding Validators
--------------------------------

Validators are simply modules that implement `validate/2` and return `:ok`
or a tuple with `:error` and a message. They usually use `Vex.Validator`
as well to get some common utilities for supporting `:allow_nil`, `:allow_blank`, and custom `:message` options:

```elixir
defmodule App.CurrencyValidator do

  use Vex.Validator

  def validate(value, options) do
    # Return :ok or {:error, "a message"}
  end

end
```

If you wanted to make this validator available to Vex as the `:currency`
validator so that you could do this:

```elixir
validates :amount, currency: true
```

You just need to add a validator _source_ so that Vex knows where to find it.

A source can be anything that implements the `Vex.Validator.Source` protocol.
We'll use a keyword list for this example. The implementation for `List`
allows us to provide a simple mapping.

Vex uses `Application.get_env(:vex, :sources)` to retrieve the
configuration of sources, defaulting to `[Vex.Validators]`. We can
set the configuration with
[Mix.Config](http://elixir-lang.org/docs/stable/mix/Mix.Config.html),
as in:

```elixir
config :vex,
  sources: [[currency: App.CurrencyValidator], Vex.Validators]
```

Vex will consult the list of sources -- in order -- when looking for a
validator. By putting our new source before `Vex.Validators`, we make it
possible to override the built-in validators.

Note: Without a `sources` configuration, Vex falls back to a default of `[Vex.Validators]`.

### Using Modules as Sources

If adding mappings to our keyword list source becomes
tiresome, we can make use of the fact there's a `Vex.Validator.Source`
implementation for `Atom`; we can provide a module name as a source instead
(just as Vex does with `Vex.Validators`).

```elixir
config :vex,
  sources: [App.Validators, Vex.Validators]
```

If given an atom, Vex will assume it refers to a module and try two
strategies to retrieve a validator:

 * If the module exports a `validator/1` function, it will call that
   function, passing the validator name (eg, `:currency`)
 * Otherwise, Vex will assume the validator module is the same as the
   source module _plus_ a dot and the camelized validator name (eg, given
   a source of `App.Validators`, it would look for a `:currency` validator at
   `App.Validators.Currency`)

In either case it will check the candidate validator for an exported
`validate/2` function.

In the event no validators can be found for a name, a
`Vex.InvalidValidatorError` will be raised.

### Checking Validator Lookup

To see what validator Vex finds for a given validator name, use `Vex.validator/1`:

```elixir
iex> Vex.validator(:currency)
App.Validators.Currency
```

Contributing
------------

Please fork and send pull requests (preferably from non-master branches), including tests (doctests or normal `ExUnit.Case` tests).

Report bugs and request features via [Issues](https://github.com/CargoSense/vex/issues);
kudos if you do it from pull requests you submit that fix the bugs or add
the features. ;)

License
-------

Released under the [MIT License](http://www.opensource.org/licenses/MIT).
