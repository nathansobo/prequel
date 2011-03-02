module Keep
  module ObjectExtensions
    def resolve_in_relations(*relations)
      self
    end

    def resolve_in_query(query)
      query.add_literal(self)
    end

    Object.send(:include, self)
  end

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

    def resolve_in_relations(*relations)
      relations.each do |relation|
        if column = relation.get_column(self)
          return column
        end
      end
    end

    def to_sql
      inspect
    end

    Symbol.send(:include, self)
  end
end
