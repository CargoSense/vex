# Vex

[![Build Status](https://travis-ci.org/bruce/vex.png)](https://travis-ci.org/bruce/vex)

A data validation library for Elixir.

Validate data by attribute presence, inclusion, format, length, and other operations.

Inspired by
-----------

 * Rails ActiveModel Validations
 * Clojure's [Validateur](https://github.com/michaelklishin/validateur)

Roadmap
-------

See [the wiki](https://github.com/bruce/vex/wiki/Roadmap).

Supported Validations
---------------------

Note the examples below use `Vex.is_valid?/2`, with the validations to check explicitly provided as
the second argument. For information on how validation configuration can be provided as part of a
single argument (eg, packaged with the data to check passed to `Vex.is_valid?/1`) see "Configuring Validations"
below.

### Presence

Ensure a value is present:

```elixir
Vex.is_valid? post, title: [presence: true]
```

See the documentation on `Vex.Validators.presence` for details on available options.  

### Absence

Ensure a value is absent (blank)

```elixir
Vex.is_valid? post, byline: [absence: true]
```

See the documentation on `Vex.Validators.absence` for details on available options.

### Inclusion

Ensure a value is in a list of values:

```elixir
Vex.is_valid? post, category: [inclusion: ["politics", "food"]]
```

See the documentation on `Vex.Validators.inclusion` for details on available options.  

### Exclusion

Ensure a value is _not_ in a list of values:

```elixir
Vex.is_valid? post, category: [exclusion: ["oped", "lifestyle"]]
```

See the documentation on `Vex.Validators.exclusion` for details on available options.

### Format

Ensure a value matches a regular expression:

```elixir
Vex.is_valid? widget, identifier: [format: %r(^id-)]
```

See the documentation on `Vex.Validators.format` for details on available options.

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

See the documentation on `Vex.Validators.length` for details on available options.

### Acceptance

Ensure an attribute is set to a positive (or custom) value. For use
expecially with "acceptance of terms" checkboxes in web applications.

```elixer
Vex.is_valid?(user, accepts_terms: [acceptance: true])
```

To check for a specific value, use `:as`:

```elixer
Vex.is_valid?(user, accepts_terms: [acceptance: [as: "yes"]])
```

See the documentation on `Vex.Validators.acceptance` for details on available options.

### Confirmation

Ensure a value has a matching confirmation:

```elixer
Vex.is_valid? user, password: [confirmation: true]
```

The above would ensure the values of `password` and `password_confirmation` are equivalent.

See the documentation on `Vex.Validators.confirmation` for details on available options.

### Custom Function

You can also just provide a custom function for validation instead of a validator name:

```elixer
Vex.is_valid?(user, password: fn (pass) -> byte_size(pass) > 4 end)
Vex.is_valid? user, password: &valid_password?/1
Vex.is_valid?(user, password: &(&1 != "god"))
```

Or explicitly using `:by`:

```elixir
Vex.is_valid?(user, age: [by: &(&1 > 18)])
```

See the documentation on `Vex.Validators.by` for details on available options.

Configuring Validations
-----------------------

The examples above use `Vex.is_valid?/2`, passing both the data to be validated and the validation settings.
This is nice for ad hoc data validation, but wouldn't it be nice to just:

```elixir
Vex.is_valid?(data)
```

... and have the data tell Vex which validations should be evaluated?

### In Records

In your `defrecord`, use `Vex.Record`:

```elixir
defrecord User, username: nil, password: nil, password_confirmation: nil do
  use Vex.Record

  validates :username, presence: true, length: [min: 4], format: %r/^[[:alpha:]][[:alnum:]]+$/
  validates :password, length: [min: 4], confirmation: true

end
```

Note `validates` should only be used once per attribute.

Once configured, you can use `Vex.is_valid?/1`:

```elixir
user = User[username: "actualuser", password: "abcdefghi", password_confirmation: "abcdefghi"]
Vex.is_valid?(user)
```

You can also use `is_valid?` directly on the record:

```elixir
user.is_valid?
```

### In Keyword Lists

In your list, just include a `:_vex` entry and use `Vex.is_valid?/1`:

```elixir
user = [username: "actualuser", password: "abcdefghi", password_confirmation: "abcdefghi",
        _vex: [username: [presence: true, length: [min: 4], format: %r/^[[:alpha:]][[:alnum:]]+$/]],
               password: [length: [min: 4], confirmation: true]]
Vex.is_valid?(user)
```

### Others

Just implement the `Vex.Extract` protocol. Here's what was done to support keyword lists:

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

