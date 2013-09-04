# Vex

A data validation library for Elixir.

Goals
-----

Inspired by
-----------

 * Rails ActiveModel Validations
 * Clojure's [Validateur](https://github.com/michaelklishin/validateur)

Supported Validations
---------------------

Many conventional validations are supported, but more advanced options are not. Future development
will see options for allowing `nil` and "blank" values, and limiting which validations are evaluated
based on state.

Note the examples below use `Vex.is_valid?/2`, with the validations to check explicitly provided as
the second argument. For information on how validation configuration can be provided as part of a
single argument (eg, packaged with the data to check passed to `Vex.is_valid?/1`) see "Configuring Validations"
below.

### presence

Options:

Ensure a value is present:

```elixir
Vex.is_valid? post, title: [presence: true]
```

Ensure a value _isn't_ present:

```elixir
Vex.is_valid? post, byline: [presence: false]
```

### inclusion

Ensure a value is in a list of values:

```elixir
Vex.is_valid? post, category: [inclusion: ["politics", "food"]]
```

You can also use the `in` keyword if you prefer:

```elixir
Vex.is_valid? post, category: [inclusion: [in: ["politics", "food"]]]
```

### exclusion

Ensure a value is _not_ in a list of values:

```elixir
Vex.is_valid? post, category: [exclusion: ["oped", "lifestyle"]]
```

You can also use the `in` keyword if you prefer:

```elixir
Vex.is_valid? post, category: [exclusion: [in: ["oped", "lifestyle"]]]
```

### format

Ensure a value matches a regular expression:

```elixir
Vex.is_valid? widget, identifier: [format: %r(^id-)]
```

You can also use the `with` keyword if you prefer:

```elixir
Vex.is_valid? widget, identifier: [format: [with: %r(^id-)]]
```

### length

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

### confirmation

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

... and have the data tell Vex whick validations should be evaluated?

TODO

