require 'active_support/core_ext/string'
require 'builder'

class SpreeCielo::Base
  attr_accessor :id, :versao

  def to_xml
    x = Builder::XmlMarkup.new
    x.instruct!
    name = self.class.name.demodulize
    x.tag! name.underscore.dasherize, id: id, versao: versao
  end
end
