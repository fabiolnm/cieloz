require 'minitest/spec'
require 'minitest/autorun'

require 'debugger'
require 'turn/autorun'

require 'spree_cielo'
require 'fakeweb'
require 'erb'

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
