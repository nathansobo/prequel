module Keep
  class CompositeTuple
    attr_reader :left, :right

    def initialize(left, right)
      @left, @right = left, right
    end

    def get_tuple(table_name)
      left.get_tuple(table_name) || right.get_tuple(table_name)
    end

    def field_values
      [left.field_values, right.field_values]
    end

    delegate :inspect, :to => :field_values

    alias_method :[], :get_tuple
  end
end