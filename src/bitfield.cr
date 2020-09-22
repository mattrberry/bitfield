abstract class BitField(T)
  macro inherited
    {% raise "Cannot create a BitField from a non-integer" unless T <= Int %}

    FIELDS = [] of Tuple(String, Symbol, Int32) # name, type, size (types don't actually matter here..)

    macro finished
      build_methods

      property value : T

      def initialize(@value : T)
        bits = sizeof(T) * 8
        raise "You must describe exactly #{bits} bits (#{SIZE} bits have been described)" unless SIZE == bits
      end
    end
  end

  macro num(name, size)
    {% FIELDS << {name, :num, size} %}
  end

  macro bool(name)
    {% FIELDS << {name, :bool, 1} %}
  end

  macro build_methods
    {% pos = 0 %}
    {% FIELDS.map {|f| pos += f[2]} %}
    SIZE = {{pos}}

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
