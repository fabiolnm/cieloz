require 'active_support/core_ext/string'
require 'active_support/core_ext/object/with_options'
require 'cieloz/version'
require 'active_model'
require 'nokogiri'

DIR = File.dirname __FILE__
I18n.load_path += Dir.glob "#{DIR}/../config/locales/*.{rb,yml}"

module Cieloz
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
require "cieloz/homologacao"
require "cieloz/requisicao"
require "cieloz/requisicao_transacao"
require "cieloz/requisicao_transacao/dados_portador"
require "cieloz/requisicao_transacao/dados_pedido"
require "cieloz/requisicao_transacao/forma_pagamento"
require "cieloz/requisicao_tid"
