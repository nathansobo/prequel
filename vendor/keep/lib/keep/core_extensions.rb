module Keep
  module HashExtensions
    def to_predicate
      raise NotImplementedError unless size == 1
      keys.first.eq(values.first)
    end

    Hash.send(:include, self)
  end

  module SymbolExtensions
    def eq(other)
      Expressions::Equal.new(self, other)
    end

    Symbol.send(:include, self)
  end

  module NumericExtensions
    def to_sql(query)
      query.add_literal(self).inspect
    end

    Numeric.send(:include, self)
  end
end
