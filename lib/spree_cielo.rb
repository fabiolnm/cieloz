require "spree_cielo/version"

module SpreeCielo
  TEST_HOST = "qasecommerce.cielo.com.br"
  WS_PATH   = "/servicos/ecommwsec.do"

  def self.test_url
    "https://#{TEST_HOST}#{WS_PATH}"
  end

  module Helpers
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

    TEST_MOD_CIELO  = new numero: "1001734898",
      chave: "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"

    TEST_MOD_LOJA   = new numero: "1006993069",
      chave: "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3"
  end
end

require "spree_cielo/base"
require "spree_cielo/requisicao_transacao"
