# coding: UTF-8

# TODO: Most of these issues are not present in Rails 3. Remove this when updating.
# Force mysql rows to be UTF-8 (see rails.lighthouseapp.com/projects/8994/tickets/2476)
if RUBY_VERSION.split(".").map{|i| i.to_i}[1] == 9
    require 'mysql'

    # solve utf-8 problems when searching
    # warning: regexp match /.../n against to UTF-8 string
    module Rack
      module Utils
        def escape(s)
          EscapeUtils.escape_url(s)
        end
      end
    end

    class Mysql::Result
      def encode(value, encoding = "utf-8")
        String === value ? value.force_encoding(encoding) : value
      end

      def each_utf8(&block)
        each_orig do |row|
          yield row.map {|col| encode(col) }
        end
      end
      alias each_orig each
      alias each each_utf8

      def each_hash_utf8(&block)
        each_hash_orig do |row|
          row.each {|k, v| row[k] = encode(v) }
          yield(row)
        end
      end
      alias each_hash_orig each_hash
      alias each_hash each_hash_utf8
    end

    # fix template rendering
    module ActionView
      # NOTE: The template that this mixin is being included into is frozen
      # so you cannot set or modify any instance variables
      module Renderable #:nodoc:
        extend ActiveSupport::Memoizable


        private
        def compile!(render_symbol, local_assigns)
            locals_code = local_assigns.keys.map { |key| "#{key} = local_assigns[:#{key}];" }.join

            source = <<-end_src
              def #{render_symbol}(local_assigns)
                old_output_buffer = output_buffer;#{locals_code};#{compiled_source}
              ensure
                self.output_buffer = old_output_buffer
              end
            end_src

            # Workaround for erb
            source.force_encoding('utf-8') if '1.9'.respond_to?(:force_encoding)

            begin
              ActionView::Base::CompiledTemplates.module_eval(source, filename, 0)
            rescue Errno::ENOENT => e
              raise e # Missing template file, re-raise for Base to rescue
            rescue Exception => e # errors from template code
              if logger = defined?(ActionController) && Base.logger
                logger.debug "ERROR: compiling #{render_symbol} RAISED #{e}"
                logger.debug "Function body: #{source}"
                logger.debug "Backtrace: #{e.backtrace.join("\n")}"
              end

              raise ActionView::TemplateError.new(self, {}, e)
            end
          end

      end
    end

    # the previous fix causes issues in uploaded files encoding, fixed here
    module ActionController
      class Request
        private

          # Convert nested Hashs to HashWithIndifferentAccess and replace
          # file upload hashs with UploadedFile objects
          def normalize_parameters(value)
            case value
            when Hash
              if value.has_key?(:tempfile)
                upload = value[:tempfile]
                upload.extend(UploadedFile)
                upload.original_path = value[:filename]
                upload.content_type = value[:type]
                upload
              else
                h = {}
                value.each { |k, v| h[k] = normalize_parameters(v) }
                h.with_indifferent_access
              end
            when Array
              value.map { |e| normalize_parameters(e) }
            else
              value.force_encoding(Encoding::UTF_8) if value.respond_to?(:force_encoding)
              value
            end
          end
      end
    end

end

