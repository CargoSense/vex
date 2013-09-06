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

 * ~~Ad hoc validation~~
 * ~~Validation of preconfigured settings for keyword lists and records~~
 * Options for allowing `nil` and "blank" values
 * Support messages for failures
 * Limiting which validations are evaluated based on state (eg, "on create")
 * Deep attribute matching

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

Note: Vex uses the `Vex.Blank` protocol to determine "presence." Notably, empty strings and collections
are not considered present.

### Absence

Ensure a value is absent:

```elixir
Vex.is_valid? post, byline: [absence: true]
```

Note: Vex uses the `Vex.Blank` protocol to determine "absence." Notably, empty strings and collections
are considered absent.

### Inclusion

Ensure a value is in a list of values:

```elixir
Vex.is_valid? post, category: [inclusion: ["politics", "food"]]
```

You can also use the `in` keyword if you prefer:

```elixir
Vex.is_valid? post, category: [inclusion: [in: ["politics", "food"]]]
```

### Exclusion

Ensure a value is _not_ in a list of values:

```elixir
Vex.is_valid? post, category: [exclusion: ["oped", "lifestyle"]]
```

You can also use the `in` keyword if you prefer:

```elixir
Vex.is_valid? post, category: [exclusion: [in: ["oped", "lifestyle"]]]
```

### Format

Ensure a value matches a regular expression:

```elixir
Vex.is_valid? widget, identifier: [format: %r(^id-)]
```

You can also use the `with` keyword if you prefer:

```elixir
Vex.is_valid? widget, identifier: [format: [with: %r(^id-)]]
```

### Length

Ensure a value's length is at least a given size:

```elixir
Vex.is_valid? user, username: [length: [min: 2]]
```

Ensure a value's length is at or below a given size:

```elixir
Vex.is_valid? user, username: [length: [max: 10]]
```

Ensure a value's length in between two sizes (inclusive):

```elixir
Vex.is_valid? user, username: [length: [min: 2, max: 10]]
```

You can also use a range:

```elixir
Vex.is_valid? user, username: [length: 2..10]
```

### Acceptance

Ensure an attribute is set to a positive (or custom) value. For use
expecially with "acceptance of terms" checkboxes in web applications.

```elixer
Vex.is_valid?(user, accepts_terms: [acceptance: true])
```

To check for a specific value, use `accept`:

```elixer
Vex.is_valid?(user, accepts_terms: [acceptance: [accept: "yes"]])
```

### Confirmation

Ensure a value has a matching confirmation:

```elixer
Vex.is_valid? user, password: [confirmation: true]
```

The above would ensure the values of `password` and `password_confirmation` are equivalent.

### Custom Function

You can also provide a custom function for validation:

```elixer
Vex.is_valid?(user, password: fn (pass) -> byte_size(pass) > 4 end)
Vex.is_valid? user, password: &valid_password?/1
Vex.is_valid?(user, password: &(&1 != "god"))
```

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

Just implement the `Vex.Extract` protocol. Here's what it looks like to support keyword lists:

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

