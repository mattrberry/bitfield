class BitField(T)
  property value : T

  def initialize(@value : T)
    {% raise "Cannot create a BitField from a non-integer" unless T <= Int %}
  end

  macro inherited
    POS = [8]

    macro finished
      \{% raise "You must describe exactly #{8} bits (#{8 - POS[0]} bits have been described)" unless POS[0] == 0 %}
    end
  end

  macro num(name, size)
    {% POS[0] -= size %}

    def {{name.id}} : T
      get_val({{size}}, {{POS[0]}})
    end

    def {{name.id}}=(val : T) : Nil
      set_val({{size}}, {{POS[0]}})
    end
  end

  macro bool(name)
    {% POS[0] -= 1 %}

    def {{name.id}} : Bool
      get_val(1, {{POS[0]}}) > 0
    end

    def {{name.id}}=(val : Bool) : Nil
      val = val ? 1 : 0
      set_val(1, {{POS[0]}})
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
