module Keep
  class CompositeTuple
    attr_reader :left, :right

    def initialize(left, right)
      @left, @right = left, right
    end

    def [](name)
      get_tuple(name) || get_field_value(name)
    end

    def get_tuple(table_name)
      left.get_tuple(table_name) || right.get_tuple(table_name)
    end

    def get_field_value(name)
      left.get_field_value(name) || right.get_field_value(name)
    end

    def field_values
      [left.field_values, right.field_values]
    end

    delegate :inspect, :to => :field_values
  end
end