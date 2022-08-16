abstract class BitField(T)
  def inspect(io : IO) : Nil
    to_s io
  end

  macro inherited
    {% raise "Cannot create a BitField from a non-integer" unless T <= Int %}

    FIELDS = [] of Tuple(String, Symbol, Int32, Bool) # name, type, size, lock (types don't actually matter here..)

    macro finished
      build_methods
      def_to_s

      def initialize(@value : T)
        bits = sizeof(T) * 8
        raise "You must describe exactly #{bits} bits (#{SIZE} bits have been described)" unless SIZE == bits
      end

      def_equals_and_hash @value
    end
  end

  macro num(name, size, read_only = false, write_only = false)
    add_field({{name}}, :num, {{size}}, {{read_only}}, {{write_only}})
  end

  macro bool(name, read_only = false, write_only = false)
    add_field({{name}}, :bool, 1, {{read_only}}, {{write_only}})
  end

  # Exists as a general way to add fields to the FIELD list. Guarantees that
  # the correct number of parameters are passed, at least.
  macro add_field(name, type, size, read_only, write_only)
    {% raise "Cannot mark a field as both read_only and write_only" if read_only && write_only %}
    {% FIELDS << {name, type, size, read_only, write_only} %}
  end

  macro build_methods
    {% pos = 0 %}
    {% FIELDS.map { |f| pos += f[2] } %}
    SIZE = {{pos}}
    {% read_only_mask = 0 %}
    {% write_only_mask = 0 %}

    {% for field in FIELDS %}
      {% name = field[0].id %}
      {% bool = field[1] == :bool %}
      {% size = field[2] %}
      {% read_only = field[3] %}
      {% write_only = field[4] %}
      {% type = bool ? Bool : T %}

      {% pos -= size %}

      {% if read_only %}
        {% for i in (0...size) %}
          {% read_only_mask = read_only_mask | 1 << (pos + i) %}
        {% end %}
      {% end %}

      {% if write_only %}
        {% for i in (0...size) %}
          {% write_only_mask = write_only_mask | 1 << (pos + i) %}
        {% end %}
      {% end %}

      def {{name}} : {{type}}
        get_val({{size}}, {{pos}}) {% if bool %} > 0 {% end %}
      end

      def {{name}}=(val : {{type}}) : Nil
        {% if bool %} val = val ? 1 : 0 {% end %}
        set_val({{size}}, {{pos}})
      end
    {% end %}

    def value : T
      @value & ~{{write_only_mask}}
    end

    def value=(value : T)
      @value = (@value & {{read_only_mask}}) | (value & ~{{read_only_mask}})
    end
  end

  macro def_to_s
    def to_s(io : IO) : Nil
      io << self.class
      io << "("
      io << "0x"
      io << @value.to_s(16).rjust(sizeof(T) * 2, '0').upcase
      io << "; "
      {% for field, idx in FIELDS %}
        {% name = field[0].id %}
        io << "{{name}}: "
        io << self.{{name}}
        {% if idx < FIELDS.size - 1 %}
          io << ", "
        {% end %}
      {% end %}
      io << ")"
    end
  end

  macro get_val(size, start)
    (@value >> {{start}} & mask({{size}}))
  end

  macro set_val(size, start)
    (@value = @value & ~shifted_mask({{size}}, {{start}}) | (val & mask({{size}})) << {{start}})
  end

  macro mask(size)
    ((1 << {{size}}) - 1)
  end

  macro shifted_mask(size, start)
    (mask({{size}}) << {{start}})
  end
end
