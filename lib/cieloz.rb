require 'active_support/core_ext/string'
require 'active_support/core_ext/object/with_options'
require 'cieloz/version'
require 'active_model'
require 'nokogiri'

DIR = File.dirname __FILE__
I18n.load_path += Dir.glob "#{DIR}/../config/locales/*.{rb,yml}"

require "cieloz/helpers"

module Cieloz
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
require "cieloz/requisicao/dados_ec"
require "cieloz/requisicao_transacao"
require "cieloz/requisicao_transacao/dados_portador"
require "cieloz/requisicao_transacao/dados_pedido"
require "cieloz/requisicao_transacao/forma_pagamento"
require "cieloz/requisicao_tid"
