require 'debugger'
require 'cieloz'

require 'minitest/autorun'
# require 'turn/autorun'

require 'minitest/matchers'
require 'shoulda/matchers'

require 'vcr'
require 'erb'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

class MiniTest::Spec
  include Shoulda::Matchers::ActiveModel

  class << self
    alias :_create :create

    def create name, desc
      cls = _create name, desc
      begin
        c = eval name
        cls.subject {
          if c.is_a? Class then c.new elsif c.is_a? Module then c end
        }
      rescue
      end
      cls
    end
  end
end

module Shoulda::Matchers::ActiveModel
  class AllowValueMatcher
    def matches? instance
      @instance = instance
      @values_to_match.none? do |value|
        @value = value
        @instance.instance_variable_set "@#{@attribute}", @value
        errors_match?
      end
    end
  end
end

def expected_xml opts={}
  root, id, versao = opts[:root], opts[:id], opts[:versao]

  '<?xml version="1.0" encoding="UTF-8"?>'    +
  %|<#{root} id="#{id}" versao="#{versao}">|  +
    "#{yield if block_given?}"                +
  "</#{root}>"
end

def render_template dir, filename, binding
  template = File.join dir, [ "xml", filename ]
  file = File.read template
  erb = ERB.new file
  res = erb.result binding
  res.split("\n").collect {|line| line.strip }.join
end

def xml_for type, dir, binding
  render_template dir, "dados-#{type}.xml", binding
end
