module Cieloz
  module Helpers
    module ClassMethods
      def hattr_writer *attrs
        attrs.each { |attr|
          define_method "#{attr}=" do |value|
            if value.is_a? Hash
              name = attr.to_s.camelize
              cls = self.class.const_get name
              value = cls.new(value)
            end
            instance_variable_set "@#{attr}", value
            yield(value) if block_given?
          end
        }
      end

      def attrs_from source, opts, *keys
        attrs = keys.map { |k|
          value_or_attr_name = opts[k] || k
          if value_or_attr_name.is_a? Symbol
            source.send value_or_attr_name if source.respond_to? value_or_attr_name
          else
            value_or_attr_name
          end
        }
        attrs.count == 1 ? attrs.first : attrs
      end
    end

    module InstanceMethods
      def add_error(attr, message)
        error_message = errors.add(attr, message).first
        if @source
          source_attr = @opts[attr]
          if source_attr.is_a?(Symbol) and @source.respond_to?(source_attr)
            @source.errors.add source_attr, error_message
          else
            @source.errors.add :base, "#{attr}: #{error_message}"
          end
        end
      end

      def valid?
        valid = _valid?
        unless @source.nil?
          unless valid
            errors.messages.each { |attr,attr_errors|
              source_attr = @opts[attr]
              if source_attr.is_a?(Symbol) and @source.respond_to?(source_attr)
                attr_errors.each {|e| @source.errors.add source_attr, e }
              else
                attr_errors.each {|e| @source.errors.add :base, "#{attr}: #{e}" if e.is_a? String }
              end
              @source.errors.messages.each {|attr,attr_errors| attr_errors.uniq! }
            }
          end
        end
        valid
      end
    end

    def self.included base
      base.send :include, ActiveModel::Validations
      base.extend ClassMethods
      base.class_eval do
        alias :_valid? :valid?
        attr_accessor :source, :opts
      end
      base.send :include, InstanceMethods
    end

    def initialize attrs={}
      self.attributes = attrs
    end

    def attributes= attrs
      attrs.each {|k,v|
        m = "#{k}="
        send(m, v) if respond_to? m
      }
    end
  end
end
