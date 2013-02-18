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
    end

    def self.included base
      base.extend ClassMethods
      base.send :include, ActiveModel::Validations
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
