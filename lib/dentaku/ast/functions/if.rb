require_relative '../function'

module Dentaku
  module AST
    class If < Function
      attr_reader :predicate, :left, :right

      def initialize(predicate, left, right)
        @predicate = predicate
        @left      = left
        @right     = right
      end

      def value(context = {})
        predicate.value(context) ? left.value(context) : right.value(context)
      end

      def string_value(context = {})
        predicate_left, predicate_right, left_str, right_str = [predicate.left, predicate.right, left, right].map do |n|
          case n.class.name
            when "Dentaku::AST::Identifier"
              context[n.identifier]
            when "Dentaku::AST::Numeric"
              n.value
            when "Dentaku::AST::If"
              n.string_value(context)
            else
              ""
          end
        end

        "IF(#{predicate_left} #{predicate.operator.to_s} #{predicate_right}, #{left_str}, #{right_str})"
      end

      def node_type
        :condition
      end

      def type
        left.type
      end

      def dependencies(context = {})
        # TODO : short-circuit?
        (predicate.dependencies(context) + left.dependencies(context) + right.dependencies(context)).uniq
      end
    end
  end
end

Dentaku::AST::Function.register_class(:if, Dentaku::AST::If)
