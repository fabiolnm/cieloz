require 'active_support/core_ext/string'
require 'builder'

class SpreeCielo::Base
  attr_accessor :id, :versao, :dados_ec, :campo_livre

  def to_xml
    x = Builder::XmlMarkup.new
    x.instruct!
    name = self.class.name.demodulize
    x.tag! name.underscore.dasherize, id: id, versao: versao do
      (instance_variables - [:@id, :@versao]).each { |attr|
        value = instance_variable_get attr
        next if value.nil?

        value_attrs = value.instance_variables

        if value_attrs.empty?
          x.tag! dash(attr), value
        else
          x.tag! dash(attr) do
            value_attrs.each do |vattr|
              attr_value = value.instance_variable_get "@#{vattr}"
              x.tag!(dash(vattr), attr_value) unless attr_value.nil?
            end
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
