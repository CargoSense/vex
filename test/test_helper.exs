defrecord RecordTest, name: nil, identifier: nil do
  use Vex.Record

  validates :name, presence: true
end

defrecord UserTest, username: nil, password: nil, password_confirmation: nil, age: nil do
  use Vex.Record

  validates :username, presence: true, length: [min: 4], format: %r(^[[:alpha:]][[:alnum:]]+$)
  validates :password, length: [min: 4], confirmation: true

end

ExUnit.start