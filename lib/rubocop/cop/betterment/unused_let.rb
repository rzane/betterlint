# frozen_string_literal: true

module RuboCop
  module Cop
    module Betterment
      # Checks for unused `let` definitions in RSpec tests.
      class UnusedLet < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Unused let definition `%<name>s`. Remove it or use it in your tests.'
        RSPEC_BLOCK_METHODS = %i(describe context shared_examples shared_context).freeze

        # @!method let_definition(node)
        def_node_matcher :let_definition, <<~PATTERN
          (block (send nil? :let (sym $_)) ...)
        PATTERN

        # @!method variable_reference?(node, name)
        def_node_search :variable_reference?, <<~PATTERN
          (send nil? %1)
        PATTERN

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          let_name = let_definition(node) or return
          context_block = find_context_block(node) or return

          unless variable_reference?(context_block, let_name)
            add_offense(node, message: format(MSG, name: let_name)) do |corrector|
              corrector.remove(range_with_surrounding_space(range: node.source_range, side: :left))
            end
          end
        end

        private

        def find_context_block(node)
          node.each_ancestor(:block).find do |ancestor|
            RSPEC_BLOCK_METHODS.include?(ancestor.send_node&.method_name)
          end
        end
      end
    end
  end
end
