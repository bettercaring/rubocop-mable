# frozen_string_literal: true

module RuboCop
  module Cop
    module Mable
      class RequiredTaskHeader
        # Annotation parsing module
        module AnnotationParser
          def self.find_annotation_block_for_task(node, processed_source)
            task_line = node.loc.line
            return nil if task_line <= 1

            annotation_lines = collect_annotation_lines(task_line, processed_source)
            return nil unless valid_annotation_block?(annotation_lines)

            annotation_lines
          end

          def self.collect_annotation_lines(task_line, processed_source)
            lines = processed_source.raw_source.lines
            annotation_lines = []

            (task_line - 1).downto(1) do |line_num|
              line = lines[line_num - 1]
              stripped = line.strip

              break if non_comment_line?(stripped)

              annotation_lines.unshift(line)
              break if annotation_start?(stripped)
            end

            annotation_lines
          end

          def self.non_comment_line?(stripped)
            !stripped.empty? && !stripped.start_with?('#')
          end

          def self.annotation_start?(stripped)
            stripped.match?(/^#\s*Task:\s*/)
          end

          def self.valid_annotation_block?(annotation_lines)
            return false if annotation_lines.empty?

            annotation_lines.any? { |l| annotation_start?(l.strip) }
          end

          ANNOTATION_PATTERNS = {
            /^#\s*Task:\s*(.+)/ => :task_name,
            /^#\s+Type:\s*(.+)/ => :type,
            /^#\s+Created:\s*(.+)/ => :created,
            /^#\s+Ownership:\s*(.+)/ => :ownership,
            /^#\s+Cleanup Card:\s*(.+)/ => :cleanup_card,
            /^#\s+Cleanup Date:\s*(.+)/ => :cleanup_date
          }.freeze

          def self.parse_annotation_block(annotation_lines)
            annotation = initialize_annotation_hash

            annotation_lines.each do |line|
              parse_annotation_line(line, annotation)
            end

            annotation
          end

          def self.initialize_annotation_hash
            {
              task_name: nil,
              type: nil,
              created: nil,
              ownership: nil,
              cleanup_card: nil,
              cleanup_date: nil
            }
          end

          def self.parse_annotation_line(line, annotation)
            stripped = line.strip

            ANNOTATION_PATTERNS.each do |pattern, field|
              match = stripped.match(pattern)
              next unless match

              annotation[field] = match[1].strip
              break
            end
          end
        end
      end
    end
  end
end
