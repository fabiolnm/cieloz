require 'active_support/core_ext/string'
require 'builder'

class SpreeCielo::Base
  attr_accessor :id, :versao, :dados_ec

  def to_xml
    x = Builder::XmlMarkup.new
    x.instruct!
    name = self.class.name.demodulize
    x.tag! name.underscore.dasherize, id: id, versao: versao do
      (instance_variables - [:@id, :@versao]).each { |attr|
        x.tag! dash(attr) do
          value = instance_variable_get attr

          value.instance_variables.each do |vattr|
            attr_value = value.instance_variable_get "@#{vattr}"
            x.tag! dash(vattr), attr_value
          end
        end
      }
    end
  end

  private
  def dash value
    value.to_s.gsub("@", "").dasherize
  end
end
