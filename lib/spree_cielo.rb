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
  end
end

require "spree_cielo/base"
