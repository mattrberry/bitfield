require "./spec_helper"

class TestField < BitField(UInt8)
  num four, 4
  bool bool
  num three, 3
end

describe BitField do
  it "gets whole value" do
    bf = TestField.new 0xAF
    bf.value.should eq 0xAF
  end

  it "gets upper four" do
    bf = TestField.new 0x9C
    bf.four.should eq 0x9
    bf.value.should eq 0x9C
  end

  it "sets upper four" do
    bf = TestField.new 0x9C
    bf.four = 0x5
    bf.four.should eq 0x5
    bf.value.should eq 0x5C
  end

  it "gets bool" do
    bf = TestField.new 0xF7
    bf.bool.should eq false
    bf.value.should eq 0xF7
  end

  it "sets bool" do
    bf = TestField.new 0xF7
    bf.bool = true
    bf.bool.should eq true
    bf.value.should eq 0xFF
  end

  it "gets lower three" do
    bf = TestField.new 0x0F
    bf.three.should eq 0x07
    bf.value.should eq 0x0F
  end

  it "sets lower three" do
    bf = TestField.new 0x0F
    bf.three = 0x5
    bf.three.should eq 0x5
    bf.value.should eq 0x0D
  end
end
