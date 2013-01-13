require 'active_support/core_ext/string'
require 'cieloz/version'
require 'active_model'
require 'nokogiri'

module Cieloz
  TEST_HOST = "qasecommerce.cielo.com.br"
  WS_PATH   = "/servicos/ecommwsec.do"

  def self.test_url
    "https://#{TEST_HOST}#{WS_PATH}"
  end

  module Helpers
    module ClassMethods
      def hattr_writer *attrs
        attrs.each { |attr|
          define_method "#{attr}=" do |value|
            value = eval(attr.to_s.constantize).new(value) if value.is_a? Hash
            instance_variable_set "@#{attr}", value
            yield(value) if block_given?
          end
        }
      end
    end

    def self.included base
      base.extend ClassMethods
    end

    def initialize attrs={}
      self.attributes = attrs
    end

    def attributes= attrs
      attrs.each {|k,v| send("#{k}=", v) if respond_to? k }
    end
  end

  class DadosEc
    include Helpers
    attr_accessor :numero, :chave

    def attributes
      { numero: @numero, chave: @chave }
    end

    TEST_MOD_CIELO  = new numero: "1001734898",
      chave: "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"

    TEST_MOD_LOJA   = new numero: "1006993069",
      chave: "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3"
  end

  class Erro
    include ActiveModel::Serializers::Xml
    include Cieloz::Helpers

    attr_accessor :codigo, :mensagem
    attr_reader :xml

    def self.from xml
      obj = new.from_xml xml
      obj.instance_variable_set :@xml, xml
      obj
    end
  end

  class Transacao
    include ActiveModel::Serializers::Xml
    include Cieloz::Helpers

    attr_accessor :tid, :status, :url_autenticacao
    attr_reader :xml

    def self.from xml
      obj = new.from_xml xml
      obj.instance_variable_set :@xml, xml
      obj
    end
  end

  MAX_INSTALLMENTS = 3

  module Bandeiras
    VISA        = "visa"
    MASTER_CARD = "mastercard"
    AMEX        = "amex"
    ELO         = "elo"
    DINERS      = "diners"
    DISCOVER    = "discover"

    SUPPORTED_FLAGS = [ VISA, MASTER_CARD, AMEX, ELO, DINERS, DISCOVER ]
  end
end

require "cieloz/base"
require "cieloz/requisicao_transacao"
