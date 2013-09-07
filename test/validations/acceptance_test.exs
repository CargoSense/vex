defrecord AcceptanceTestRecord, accepts_terms: false do
  use Vex.Record

  validates :accepts_terms, acceptance: true
end

defrecord CustomAcceptanceTestRecord, accepts_terms: false do
  use Vex.Record

  validates :accepts_terms, acceptance: [as: "yes"]
end


defmodule AcceptanceTest do
  use ExUnit.Case

  test "keyword list, provided basic acceptance validation" do
    assert  Vex.is_valid?([accepts_terms: true],       accepts_terms: [acceptance: true])
    assert  Vex.is_valid?([accepts_terms: "anything"], accepts_terms: [acceptance: true])    
    assert !Vex.is_valid?([accepts_terms: nil],        accepts_terms: [acceptance: true])
  end

  test "keyword list, included presence validation" do
    assert  Vex.is_valid?([accepts_terms: true,       _vex: [accepts_terms: [acceptance: true]]])
    assert  Vex.is_valid?([accepts_terms: "anything", _vex: [accepts_terms: [acceptance: true]]])    
    assert !Vex.is_valid?([accepts_terms: false,      _vex: [accepts_terms: [acceptance: true]]])
  end

  test "keyword list, provided custom acceptance validation" do
    assert  Vex.is_valid?([accepts_terms: "yes"], accepts_terms: [acceptance: [as: "yes"]])
    assert !Vex.is_valid?([accepts_terms: false], accepts_terms: [acceptance: [as: "yes"]])
    assert !Vex.is_valid?([accepts_terms: true],  accepts_terms: [acceptance: [as: "yes"]])
  end

  test "keyword list, included custom validation" do
    assert  Vex.is_valid?([accepts_terms: "yes", _vex: [accepts_terms: [acceptance: [as: "yes"]]]])
    assert !Vex.is_valid?([accepts_terms: false, _vex: [accepts_terms: [acceptance: [as: "yes"]]]])
    assert !Vex.is_valid?([accepts_terms: true,  _vex: [accepts_terms: [acceptance: [as: "yes"]]]])    
  end

  test "record, included basic presence validation" do
    assert Vex.is_valid?(AcceptanceTestRecord.new accepts_terms: "yes")
    assert Vex.is_valid?(AcceptanceTestRecord.new accepts_terms: true)
  end

  test "record, included custom presence validation" do
    assert  Vex.is_valid?(CustomAcceptanceTestRecord.new accepts_terms: "yes")
    assert !Vex.is_valid?(CustomAcceptanceTestRecord.new accepts_terms: true)
    assert !Vex.is_valid?(CustomAcceptanceTestRecord.new accepts_terms: false)
  end  

end
