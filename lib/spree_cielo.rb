require "spree_cielo/version"

require "spree_cielo/base"

module SpreeCielo
  TEST_HOST = "qasecommerce.cielo.com.br"
  WS_PATH   = "/servicos/ecommwsec.do"

  def self.test_url
    "https://#{TEST_HOST}#{WS_PATH}"
  end
end
