module Cieloz
  class Mapper
    def self.map(source, type, opts)
      new.map source, type, opts
    end

    def map(source, type, opts)
      @opts   = opts
      @source = source
      @target = Cieloz.send type, source, opts
      self
    end

    def valid?
      if @valid.nil? and not (@valid = @target.valid?)
        @target.errors.messages.each { |attr,errors|
          source_attr = @opts[attr]
          if source_attr.is_a?(Symbol) and @source.respond_to?(source_attr)
            errors.each {|e| @source.errors.add source_attr, e }
          else
            errors.each {|e| @source.errors.add :base, "#{attr}: #{e}" if e.is_a? String }
          end
        }
      end
      @valid
    end

    def errors
      @target.errors
    end
  end
end
