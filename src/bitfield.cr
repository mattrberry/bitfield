class BitField(T)
  property value : T

  def initialize(@value : T)
    {% raise "Cannot create a BitField from a non-integer" unless T <= Int %}
  end

  macro num(name, start, size)
    def {{name.id}} : T
      get_val({{start}}, {{size}})
    end

    def {{name.id}}=(val : T) : Nil
      set_val({{start}}, {{size}})
    end
  end

  macro bool(name, start)
    def {{name.id}} : Bool
      get_val({{start}}, 1) > 0
    end

    def {{name.id}}=(val : Bool) : Nil
      val = val ? 1 : 0
      set_val({{start}}, 1)
    end
  end

  macro get_val(start, size)
    (@value >> {{start}} & mask({{size}}))
  end

  macro set_val(start, size)
    (@value = @value & ~shifted_mask({{size}}, {{start}}) | (val & mask({{size}})) << {{start}})
  end

  macro mask(size)
    ((1 << {{size}}) - 1)
  end

  macro shifted_mask(size, start)
    (mask({{size}}) << {{start}})
  end
end
