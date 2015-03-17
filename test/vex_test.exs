# Complex combinations of validations
# For validation-specific tests see test/validations/**/*_test.exs
defmodule VexTest do

  use ExUnit.Case

  test "invalid validation name error is raised" do
    assert_raise Vex.InvalidValidatorError, fn ->
      Vex.valid?([name: "Foo"], name: [foobar: true])
    end

    assert_raise Vex.InvalidValidatorError, fn ->
      Vex.validate([name: "Foo"], name: [foobar: true])
    end
  end

  test "keyword list, each validation" do
    assert  Vex.valid?([tags: ["a", "b"]], tags: [each: &is_binary/1])
    assert !Vex.valid?([tags: [1, "b"]], tags: [each: &is_binary/1])
  end

  test "keyword list, provided multiple validations" do
    assert Vex.valid?([name: "Foo"], name: [presence: true, length: [min: 2, max: 10], format: ~r(^Fo.$)])
    assert :ok == Vex.validate([name: "Foo"], name: [presence: true, length: [min: 2, max: 10], format: ~r(^Fo.$)])
  end

  test "record, included complex validation" do
    user = %UserTest{username: "actualuser", password: "abcdefghi", password_confirmation: "abcdefghi"}
    assert Vex.valid?(user)
    assert length(Vex.results(user)) > 0
    assert length(Vex.errors(user)) == 0
    assert UserTest.valid?(user)
  end

  test "keyword list, included complex validation" do
    user = [username: "actualuser", password: "abcdefghi", password_confirmation: "abcdefghi",
            _vex: [username: [presence: true, length: [min: 4], format: ~r(^[[:alpha:]][[:alnum:]]+$)],
                   password: [length: [min: 4], confirmation: true]]]
    assert Vex.valid?(user)
    assert length(Vex.results(user)) > 0
    assert length(Vex.errors(user)) == 0
  end

  test "keyword list, included complex validation with errors" do
    user = [username: "actualuser", password: "abc", password_confirmation: "abcdefghi",
            _vex: [username: [presence: true, length: [min: 4], format: ~r(^[[:alpha:]][[:alnum:]]+$)],
                   password: [length: [min: 4], confirmation: true]]]
    assert !Vex.valid?(user)
    assert length(Vex.results(user)) > 0
    assert length(Vex.errors(user)) == 2

    {:error, errors} = Vex.validate(user)
    assert length(errors) == length(Vex.errors(user))
  end

  test "keyword list, included complex validation with non-applicable validations" do
    user = [username: "actualuser", password: "abcd", password_confirmation: "abcdefghi",
            state: :persisted,
            _vex: [username: [presence: true, length: [min: 4], format: ~r(^[[:alpha:]][[:alnum:]]+$)],
                   password: [length: [min: 4, if: [state: :new]], confirmation: [if: [state: :new]]]]]
    assert Vex.valid?(user)
  end

  test "validator lookup by structure" do
    validator = Vex.validator(:criteria, [TestValidatorSourceByStructure])
    assert validator == TestValidatorSourceByStructure.Criteria
  end

  test "validator lookup by function" do
    validator = Vex.validator(:criteria, [TestValidatorSourceByFunction])
    assert validator == TestValidatorSourceByFunctionResult
  end

end
