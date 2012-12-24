require 'active_support/core_ext/string'
require 'active_model'
require 'net/http'
require 'builder'

class SpreeCielo::Base
  class Erro
    include ActiveModel::Serializers::Xml
    include SpreeCielo::Helpers

    attr_accessor :codigo, :mensagem
  end

  attr_accessor :id, :versao, :campo_livre
  attr_reader :dados_ec

  def dados_ec= value
    unless value.is_a? Hash
      @dados_ec = value
    else
      @dados_ec = SpreeCielo::DadosEc.new value
    end
  end

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
              attr_value = value.instance_variable_get vattr
              x.tag!(dash(vattr), attr_value) unless attr_value.nil?
            end
          end
        end
      }
    end
  end

  def send host=SpreeCielo::TEST_HOST
    http = Net::HTTP.new host, 443
    http.use_ssl = true
    http.open_timeout = 5 * 1000
    http.read_timeout = 30 * 1000

    res = http.post SpreeCielo::WS_PATH, "mensagem=#{to_xml}"
    parse res.body
  end

  def parse xml
    Erro.new.from_xml xml
  end

  private
  def dash value
    value.to_s.gsub("@", "").dasherize
  end
end
