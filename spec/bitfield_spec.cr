require "./spec_helper"

class TestField < BitField(UInt8)
  num four, 4
  bool bool
  num three, 3
end

class Test32 < BitField(UInt32)
  bool one
  bool two
  bool three
  bool four
  num rest, 28
end

describe BitField do
  it "gets whole value" do
    bf = TestField.new 0xAF
    bf.value.should eq 0xAF
  end

  it "sets whole value" do
    bf = TestField.new 0xAF
    bf.value = 0xFA
    bf.value.should eq 0xFA
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

  it "works on u32" do
    bf = Test32.new 0x5F0000F5
    bf.one.should eq false
    bf.two.should eq true
    bf.three.should eq false
    bf.four.should eq true
    bf.rest.should eq 0xF0000F5
    bf.value.should eq 0x5F0000F5
  end
end
