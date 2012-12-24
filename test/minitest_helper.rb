require 'minitest/spec'
require 'minitest/autorun'

require 'debugger'
require 'turn/autorun'

require 'spree_cielo'
require 'fakeweb'
require 'erb'

class MiniTest::Spec
  class << self
    alias :_create :create

    def create name, desc
      cls = _create name, desc
      begin
        c = eval name
        cls.subject { c } if c.is_a? Class
      rescue
      end
      cls
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
  template = File.join dir, filename
  file = File.read template
  erb = ERB.new file
  res = erb.result binding
  res.split("\n").collect {|line| line.strip }.join
end

def xml_for type, dir, binding
  render_template dir, "dados-#{type}.xml", binding
end
