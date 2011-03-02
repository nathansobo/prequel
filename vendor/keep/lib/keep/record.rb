module Keep
  class Record
    class_attribute :relation

    class << self
      delegate :all, :rows, :[], :columns, :delete, :join, :to => :relation

      def table
        relation
      end

      def to_relation
        relation
      end

      def inherited(klass)
        table_name = klass.name.demodulize.underscore.pluralize.to_sym
        klass.relation = Relations::Table.new(table_name, klass)
      end

      def def_field_accessor(name)
        define_method(name) do
          get_field_value(name)
        end
        define_method("#{name}=") do |value|
          set_field_value(name, value)
        end
      end

      def column(name, type)
        relation.def_column(name, type)
        def_field_accessor(name)
      end
    end

    delegate :columns, :to => :relation

    def initialize(values = {})
      initialize_fields
      soft_update_fields(values)
    end

    def table
      relation
    end

    def soft_update_fields(values)
      values.each do |name, value|
        set_field_value(name, value)
      end
    end

    def get_field_value(name)
      fields_by_name[name].value
    end

    def set_field_value(name, value)
      fields_by_name[name].value = value
    end

    def field_values
      fields_by_name.inject({}) do |h, (name, field)|
        h[name] = field.value
        h
      end
    end

    def get_tuple(table_name)
      self if table_name == table.name
    end

    delegate :inspect, :to => :field_values

    protected
    attr_reader :fields_by_name

    def initialize_fields
      @fields_by_name = {}
      columns.each do |column|
        fields_by_name[column.name] = Field.new(self, column)
      end
    end
  end
end