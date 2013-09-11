# Complex combinations of validations
# For validation-specific tests see test/validations/**/*_test.exs
defmodule VexTest do

  use ExUnit.Case

  test "invalid validation name error is raised" do
    assert_raise Vex.InvalidValidatorError, fn ->
      Vex.is_valid?([name: "Foo"], name: [foobar: true])
    end
  end

  test "keyword list, provided multiple validations" do
    assert Vex.is_valid?([name: "Foo"], name: [presence: true,
                                               length: [min: 2, max: 10],
                                               format: %r(^Fo.$)])
  end

  test "record, included complex validation" do
    user = UserTest.new username: "actualuser", password: "abcdefghi", password_confirmation: "abcdefghi"
    assert Vex.is_valid?(user)
    assert length(Vex.results(user)) > 0
    assert length(Vex.errors(user)) == 0
    assert user.is_valid?
  end

  test "keyword list, included complex validation" do
    user = [username: "actualuser", password: "abcdefghi", password_confirmation: "abcdefghi",
            _vex: [username: [presence: true, length: [min: 4], format: %r(^[[:alpha:]][[:alnum:]]+$)],
                   password: [length: [min: 4], confirmation: true]]]
    assert Vex.is_valid?(user)
    assert length(Vex.results(user)) > 0
    assert length(Vex.errors(user)) == 0
  end

  test "keyword list, included complex validation with errors" do
    user = [username: "actualuser", password: "abc", password_confirmation: "abcdefghi",
            _vex: [username: [presence: true, length: [min: 4], format: %r(^[[:alpha:]][[:alnum:]]+$)],
                   password: [length: [min: 4], confirmation: true]]]
    assert !Vex.is_valid?(user)
    assert length(Vex.results(user)) > 0
    assert length(Vex.errors(user)) == 2
    IO.inspect Vex.errors(user)
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
