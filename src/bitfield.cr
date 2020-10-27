abstract class BitField(T)
  macro inherited
    {% raise "Cannot create a BitField from a non-integer" unless T <= Int %}

    FIELDS = [] of Tuple(String, Symbol, Int32, Bool) # name, type, size, lock (types don't actually matter here..)

    macro finished
      build_methods

      getter value : T

      def initialize(@value : T)
        bits = sizeof(T) * 8
        raise "You must describe exactly #{bits} bits (#{SIZE} bits have been described)" unless SIZE == bits
      end

      def_equals_and_hash @value
    end
  end

  macro num(name, size, lock = false)
    {% FIELDS << {name, :num, size, lock} %}
  end

  macro bool(name, lock = false)
    {% FIELDS << {name, :bool, 1, lock} %}
  end

  macro build_methods
    {% pos = 0 %}
    {% FIELDS.map { |f| pos += f[2] } %}
    SIZE = {{pos}}
    {% mask = 0 %}

    {% for field in FIELDS %}
      {% name = field[0].id %}
      {% bool = field[1] == :bool %}
      {% size = field[2] %}
      {% lock = field[3] %}
      {% type = bool ? Bool : T %}

      {% pos -= size %}

      {% if lock %}
        {% for i in (0...size) %}
          {% mask = mask | 1 << (pos + i) %}
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

    def value=(value : T)
      @value = (@value & {{mask}}) | (value & ~{{mask}})
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
