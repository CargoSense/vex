defrecord RecordTest, name: nil, identifier: nil do
  use Vex.Record

  validates :name, presence: true
end

defrecord UserTest, username: nil, password: nil, password_confirmation: nil, age: nil do
  use Vex.Record

  validates :username, presence: true, length: [min: 4], format: %r(^[[:alpha:]][[:alnum:]]+$)
  validates :password, length: [min: 4], confirmation: true

end

defmodule TestValidatorSourceByStructure.Criteria do
  
  def validate(_value, _options) do
  end

end

defmodule TestValidatorSourceByFunctionResult do

  def validate(_value, _options) do
  end

end

defmodule TestValidatorSourceByFunction do
  
  def validator(_name) do
    TestValidatorSourceByFunctionResult # always; stub
  end

end


defmodule TestValidatorSourceByFunction.Criteria do
  # Should be ignored
end


ExUnit.start