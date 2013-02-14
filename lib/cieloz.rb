require 'active_support/core_ext/string'
require 'active_support/core_ext/object/with_options'
require 'cieloz/version'
require 'active_model'
require 'nokogiri'

DIR = File.dirname __FILE__
I18n.load_path += Dir.glob "#{DIR}/../config/locales/*.{rb,yml}"

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

  class DadosEc
    include Helpers

    attr_accessor :numero, :chave
    validates :numero, :chave, presence: true

    def attributes
      { numero: @numero, chave: @chave }
    end

    TEST_MOD_CIELO  = new numero: "1001734898",
      chave: "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"

    TEST_MOD_LOJA   = new numero: "1006993069",
      chave: "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3"
  end

  class Resposta
    include ActiveModel::Serializers::Xml
    include Helpers

    STATUSES = {
      "0" => :criada,
      "1" => :em_andamento,
      "2" => :autenticada,
      "3" => :nao_autenticada,
      "4" => :autorizada,
      "5" => :nao_autorizada,
      "6" => :capturada,
      "9" => :cancelada,
      "10" => :em_autenticacao,
      "12" => :em_cancelamento
    }

    attr_reader :xml

    def self.from xml
      obj = new.from_xml xml
      obj.instance_variable_set :@xml, xml
      obj
    end

    STATUSES.each do |_, status_type|
      define_method "#{status_type}?" do
        success? and STATUSES[status] == status_type
      end
    end
  end

  class Erro < Resposta
    attr_accessor :codigo, :mensagem

    def success?
      false
    end
  end

  class Transacao < Resposta
    attr_accessor :tid, :status, :url_autenticacao

    def success?
      true
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

    ALL = [ VISA, MASTER_CARD, AMEX, ELO, DINERS, DISCOVER ]
  end
end

require "cieloz/configuracao"
require "cieloz/requisicao"
require "cieloz/requisicao_transacao"
require "cieloz/requisicao_transacao/dados_portador"
require "cieloz/requisicao_transacao/dados_pedido"
require "cieloz/requisicao_transacao/forma_pagamento"
require "cieloz/requisicao_tid"
