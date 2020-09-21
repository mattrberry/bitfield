abstract class BitField(T)
  macro inherited
    {% raise "Cannot create a BitField from a non-integer" unless T <= Int %}

    SIZE = [0] # stored in an array so that it can be mutated at compile-time
    FIELDS = [] of Tuple(String, Symbol, Int32) # name, type, size

    property value : T

    def initialize(@value : T)
      bits = sizeof(T) * 8
      raise "You must describe exactly #{bits} bits (#{SIZE[0]} bits have been described)" unless SIZE[0] == bits
    end

    macro finished
      build_methods
    end
  end

  macro num(name, size)
    {% FIELDS << {name, :num, size} %}
  end

  macro bool(name)
    {% FIELDS << {name, :bool, 1} %}
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

  macro build_methods
    {% pos = 0 %}
    {% FIELDS.map {|f| pos += f[2]} %}
    {% SIZE[0] = pos %}

    {% for field in FIELDS %}
      {% name = field[0].id %}
      {% bool = field[1] == :bool %}
      {% size = field[2] %}
      {% type = bool ? Bool : T %}

      {% pos -= size %}

      def {{name}} : {{type}}
        get_val({{size}}, {{pos}}) {% if bool %} > 0 {% end %}
      end

      def {{name}}=(val : {{type}}) : Nil
        {% if bool %} val = val ? 1 : 0 {% end %}
        set_val({{size}}, {{pos}})
      end
    {% end %}
  end
end
