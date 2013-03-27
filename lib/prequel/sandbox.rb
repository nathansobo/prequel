module Prequel
  class Sandbox
    class << self
      def expose(name, &definition)
        exposed_relation_definitions[name] = definition
        def_relation_accessor(name)
      end

      def exposed_relation_definitions
        @exposed_relation_definitions ||= {}.with_indifferent_access
      end

      def def_relation_accessor(name)
        define_method(name) do
          get_relation(name)
        end
      end
    end

    delegate :exposed_relation_definitions, :to => 'self.class'

    def create(relation_name, field_values)
      field_values.symbolize_keys!

      response = nil
      Prequel.transaction do
        relation = get_relation(relation_name)
        unless relation
          response = [404, "Relation #{relation_name} not found."]
          raise Prequel::Rollback
        end

        if record = relation.secure_new(field_values)
          if record.save
            if relation.find(record.id)
              response = [200, record.wire_representation]
            else
              response = [403, "Create operation forbidden (out of bounds)"]
              raise Prequel::Rollback
            end
          else
            response = [422, record.errors]
          end
        else
          response = [403, "Create operation forbidden"]
        end
      end
      response
    end

    def update(relation_name, id, field_values)
      field_values.symbolize_keys!

      response = nil
      Prequel.transaction do
        relation = get_relation(relation_name)
        unless relation
          response = [404, "No relation named #{relation_name} found"]
          raise Prequel::Rollback
        end
        record = relation.find(id)
        unless record
          response = [404, "No record with id #{id} found in #{relation_name}"]
          raise Prequel::Rollback
        end

        if record.secure_soft_update(field_values)
          if record.save
            if relation.find(id)
              response = [200, record.wire_representation]
            else
              response = [403, "Update operation forbidden (out of bounds)"]
              raise Prequel::Rollback
            end
          else
            response = [422, record.errors]
          end
        else
          response = [403, "Update operation forbidden"]
        end
      end
      response
    end

    def destroy(relation_name, id)
      relation = get_relation(relation_name)
      return [404, "No relation #{relation_name} found"] unless relation
      record = relation.find(id)
      return [404, "No record #{id} found in #{relation_name}"] unless record
      record.destroy
      200
    end

    def fetch(*wire_reps)
      (Hash.new {|h,k| h[k] = {}}).tap do |dataset|
        wire_reps.each do |wire_rep|
          evaluate(wire_rep).add_to_client_dataset(dataset)
        end
      end
    end

    def get_relation(name)
      if definition = exposed_relation_definitions[name]
        instance_eval(&definition)
      end
    end

    def evaluate(wire_rep)
      wire_rep = wire_rep.with_indifferent_access

      case wire_rep[:type]
      when 'Table'
        get_relation(wire_rep[:name])
      when 'Selection'
        Relations::Selection.new(evaluate(wire_rep[:operand]), evaluate(wire_rep[:predicate]))
      when 'InnerJoin'
        Relations::InnerJoin.new(evaluate(wire_rep[:leftOperand]), evaluate(wire_rep[:rightOperand]), evaluate(wire_rep[:predicate]))
      when 'Projection'
        Relations::Projection.new(evaluate(wire_rep[:operand]), wire_rep[:table].to_sym)
      when 'Equal'
        Expressions::Equal.new(evaluate(wire_rep[:leftOperand]), evaluate(wire_rep[:rightOperand]))
      when 'Column'
        "#{wire_rep[:table]}__#{wire_rep[:name]}".to_sym
      when 'Scalar'
        wire_rep[:value]
      else
        raise "Can't evaluate #{wire_rep.inspect}"
      end
    end
  end
end
