# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      class RequiredTaskHeader
        # Task extraction module
        module TaskExtractor
          def self.collect_all_tasks(processed_source)
            tasks = {}
            ast = processed_source.ast
            return tasks unless ast

            find_task_calls(ast).each do |node|
              task_name = extract_task_name(node)
              next unless task_name

              full_task_name = build_full_task_name(node, task_name)
              tasks[full_task_name] = node unless tasks.key?(full_task_name)
            end
            tasks
          end

          def self.build_full_task_name(node, task_name)
            namespace = extract_namespace_context(node)
            namespace ? "#{namespace}:#{task_name}" : task_name
          end

          def self.find_task_calls(ast)
            ast.each_node(:send).select { |node| node.method_name == :task && node.receiver.nil? }
          end

          def self.extract_task_name(node)
            return nil unless node.arguments.any?

            first_arg = node.arguments.first
            case first_arg.type
            when :sym
              first_arg.value.to_s
            when :str
              first_arg.value
            end
          end

          def self.extract_namespace_context(node)
            namespace_parts = []
            current = node.parent

            while current
              if namespace_block?(current)
                namespace_name = extract_namespace_name(current)
                namespace_parts.unshift(namespace_name) if namespace_name
              end
              current = current.parent
            end

            namespace_parts.empty? ? nil : namespace_parts.join(':')
          end

          def self.namespace_block?(node)
            return false unless node.block_type?

            send_node = node.send_node
            send_node&.method_name == :namespace && send_node.receiver.nil?
          end

          def self.extract_namespace_name(node)
            return nil unless namespace_block?(node)

            namespace_call = node.send_node
            return nil unless namespace_call.arguments.any?

            first_arg = namespace_call.arguments.first
            case first_arg.type
            when :sym
              first_arg.value.to_s
            when :str
              first_arg.value
            end
          end
        end
      end
    end
  end
end
