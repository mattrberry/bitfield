require "./spec_helper"

class TestField < BitField(UInt8)
  bool :bool_val, 0
  num :top_four, 4, 4
end

describe BitField do
  it "gets whole value" do
    bf = TestField.new 0xAF
    bf.value.should eq 0xAF
  end

  it "gets first four" do
    bf = TestField.new 0x9C
    bf.top_four.should eq 0x9
  end

  it "sets first four" do
    bf = TestField.new 0x34
    bf.top_four = 0x5
    bf.top_four.should eq 0x5
  end

  it "gets bool" do
    bf = TestField.new 0xFE
    bf.bool_val.should eq false
  end

  it "sets bool" do
    bf = TestField.new 0xFE
    bf.bool_val = true
    bf.bool_val.should eq true
  end
end
