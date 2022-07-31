# BitField - Fixed Length Bitfields in Crystal Lang

[![Build Status](https://travis-ci.org/mattrberry/bitfield.svg?branch=master)](https://travis-ci.org/mattrberry/bitfield)


The goal that BitField strives to accomplish is to allow for the creation of minimal-effort bitfields in Crystal. The intention is not intended to interop with C bitfields.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     bitfield:
       github: mattrberry/bitfield
   ```

2. Run `shards install`

## Usage

```crystal
require "bitfield"
```

### Standard Definition

You can define both numeric and boolean fields. When defining a numeric field, its type is that of the class' generic type. Additionally, the entire value of the bitfield is accessible though the #value method. An example bitfield might look something like this

```crystal
class Test8 < BitField(UInt8)
  num four, 4
  bool bool
  num three, 3
end
```

Upon creating this object, you can get and set the fields as you'd expect

```crystal
bf = Test8.new 0x9C
bf.four # => 0x9
bf.bool # => true
bf.three # => 0x4
bf.bool = false
bf.value # => 0x94
```

### Locking Values

Since I've primarily developed this shard for use in my emulator projects where bitfields are typically used to define IO registers, it's typical to have a register where fields may need to be locked in place in a bitfield. That is achievable by simply providing a `lock: true` argument with the field you want to lock.

```crystal
class TestLock < BitField(UInt8)
  num top, 3
  num mid, 2, lock: true
  num bot, 3
end
```

The effect of locking a field is that it will not change when writing to bitfield's #value method. If it needs to be mutated after initialization, it will need to be through the field's specific setter method.

```crystal
bf = TestLock.new 0x00
bf.top # => 0x0
bf.mid # => 0x0
bf.bot # => 0x0
bf.value = 0xFF
bf.top # => 0x7
bf.mid # => 0x0
bf.bot # => 0x7
bf.value # => 0xE7
bf.mid = 0x3
bf.value # => 0xFF
```

### Errors

The full number of bits must be specified. For example, if you define your bitfield over a UInt8, you must specify exactly 8 bits in the field. If you fail to do so, you will get a message like this at runtime.

```
You must describe exactly 8 bits (7 bits have been described)
```

I'd love to make this a compile-time check, but unfortunately, the size of the generic type can't be determined at compile-time.

### Printing Bitfields

A `.to_s` method is automatically generated for each bitfield object. It includes the bitfield's name, its value as a hex string, and each of its fields.

```crystal
bf = Test8.new(0xAF)
puts bf # => Test8(0xAF; four: 10, bool: true, three: 7)
```

## Contributing

1. Fork it (<https://github.com/mattrberry/bitfield/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Matthew Berry](https://github.com/mattrberry) - creator and maintainer
