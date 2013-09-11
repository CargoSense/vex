# Vex

[![Build Status](https://travis-ci.org/bruce/vex.png)](https://travis-ci.org/bruce/vex)

An extensible data validation library for Elixir.

Ships with built-in validators to check for presence, inclusion, format, length, and by custom function. Easily extensible 

Inspired by
-----------

 * Rails ActiveModel Validations
 * Clojure's [Validateur](https://github.com/michaelklishin/validateur)

Roadmap
-------

See [the wiki](https://github.com/bruce/vex/wiki/Roadmap).

Install
-------

Add to your `mix.exs`

```elixir
defp deps do
  [
    {:vex, "~>0.2", github: "bruce/vex"}
  ]
end
```

Then install the dependency:

```
$ mix deps.get
```

Supported Validations
---------------------

Note the examples below use `Vex.is_valid?/2`, with the validations to
check explicitly provided as the second argument. For information on how
validation configuration can be provided as part of a single argument
(eg, packaged with the data to check passed to `Vex.is_valid?/1`) see
"Configuring Validations" below.

### Presence

Ensure a value is present:

```elixir
Vex.is_valid? post, title: [presence: true]
```

See the documentation on `Vex.Validators.Presence` for details on
available options.  

### Absence

Ensure a value is absent (blank)

```elixir
Vex.is_valid? post, byline: [absence: true]
```

See the documentation on `Vex.Validators.Absence` for details on
available options.

### Inclusion

Ensure a value is in a list of values:

```elixir
Vex.is_valid? post, category: [inclusion: ["politics", "food"]]
```

This validation can be skipped for `nil` or blank values by including `allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.Inclusion` for details on available options.  

### Exclusion

Ensure a value is _not_ in a list of values:

```elixir
Vex.is_valid? post, category: [exclusion: ["oped", "lifestyle"]]
```

See the documentation on `Vex.Validators.Exclusion` for details on available
options.

### Format

Ensure a value matches a regular expression:

```elixir
Vex.is_valid? widget, identifier: [format: %r(^id-)]
```

This validation can be skipped for `nil` or blank values by including
`allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.Format` for details on
available options.

### Length

Ensure a value's length is at least a given size:

```elixir
Vex.is_valid? user, username: [length: [min: 2]]
```

Ensure a value's length is at or below a given size:

```elixir
Vex.is_valid? user, username: [length: [max: 10]]
```

Ensure a value's length is within a range (inclusive):

```elixir
Vex.is_valid? user, username: [length: [in: 2..10]]
```

This validation can be skipped for `nil` or blank values by including
`allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.Length` for details on
available options.

### Acceptance

Ensure an attribute is set to a positive (or custom) value. For use
expecially with "acceptance of terms" checkboxes in web applications.

```elixir
Vex.is_valid?(user, accepts_terms: [acceptance: true])
```

To check for a specific value, use `:as`:

```elixir
Vex.is_valid?(user, accepts_terms: [acceptance: [as: "yes"]])
```

See the documentation on `Vex.Validators.Acceptance` for details on
available options.

### Confirmation

Ensure a value has a matching confirmation:

```elixir
Vex.is_valid? user, password: [confirmation: true]
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
Vex.is_valid?(user, password: fn (pass) -> byte_size(pass) > 4 end)
Vex.is_valid? user, password: &valid_password?/1
Vex.is_valid?(user, password: &(&1 != "god"))
```

Or explicitly using `:by`:

```elixir
Vex.is_valid?(user, age: [by: &(&1 > 18)])
```

This validation can be skipped for `nil` or blank values by including
`allow_nil: true` and/or `allow_blank: true`.

See the documentation on `Vex.Validators.By` for details on available options.

Configuring Validations
-----------------------

The examples above use `Vex.is_valid?/2`, passing both the data to
be validated and the validation settings. This is nice for ad hoc data
validation, but wouldn't it be nice to just:

```elixir
Vex.is_valid?(data)
```

... and have the data tell Vex which validations should be evaluated?

### In Records

In your `defrecord`, use `Vex.Record`:

```elixir
defrecord User, username: nil, password: nil, password_confirmation: nil do
  use Vex.Record

  validates :username, presence: true,
                       length: [min: 4],
                       format: %r/^[[:alpha:]][[:alnum:]]+$/
  validates :password, length: [min: 4],
                       confirmation: true
end
```

Note `validates` should only be used once per attribute.

Once configured, you can use `Vex.is_valid?/1`:

```elixir
user = User[username: "actualuser",
            password: "abcdefghi",
            password_confirmation: "abcdefghi"]

Vex.is_valid?(user)
```

You can also use `is_valid?` directly on the record:

```elixir
user.is_valid?
```

### In Keyword Lists

In your list, just include a `:_vex` entry and use `Vex.is_valid?/1`:

```elixir
user = [username: "actualuser",
        password: "abcdefghi",
        password_confirmation: "abcdefghi",
        _vex: [username: [presence: true,
                          length: [min: 4],
                          format: %r/^[[:alpha:]][[:alnum:]]+$/]],
               password: [length: [min: 4], confirmation: true]]
Vex.is_valid?(user)
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

In our `mix.exs`, we add some `vex` configuration to `project`,
declaring our new source before `Vex.Validators`, the source for
all the built-in validators that ship with Vex.

```elixir
def project do
  [ app: :yourapp,
    version: "0.0.1",
    elixir: "~> 0.10.2",
    vex: [sources: [[currency: App.CurrencyValidator], Vex.Validators]]
    deps: deps ]
end
```

Vex will consult the list of sources -- in order -- when looking for a
validator. By putting our new source before `Vex.Validators`, we make it 
possible to override the built-in validators.

Note: Without a `sources` configuration in `mix.exs`, Vex falls back to a default of `[Vex.Validators]`.

### Using Modules as Sources

If adding mappings to our keyword list source in `mix.exs` becomes
tiresome, we can make use of the fact there's a `Vex.Validator.Source`
implementation for `Atom`; we can provide a module name as a source instead
(just as Vex does with `Vex.Validators`).

```elixir
def project do
  [ app: :yourapp,
    version: "0.0.1",
    elixir: "~> 0.10.2",
    vex: [sources: [App.Validators, Vex.Validators]]
    deps: deps ]
end
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

Report bugs and request features via [Issues](https://github.com/bruce/vex/issues);
kudos if you do it from pull requests you submit that fix the bugs or add
the features. ;)

License
-------

Released under the [MIT License](http://www.opensource.org/licenses/MIT).

