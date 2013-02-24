module Cieloz
  module Configuracao
    HOST    = "ecommerce.cielo.com.br"
    WS_PATH = "/servicos/ecommwsec.do"

    @@mode                = :cielo
    @@moeda               = 986 # ISO 4217 - Manual Cielo, p 11
    @@idioma              = "PT"
    @@max_parcelas        = 3
    @@max_adm_parcelas    = 10
    @@captura_automatica  = false
    @@credenciais         = nil
    @@dados_ec            = nil

    mattr_writer :credenciais, :captura_automatica
    mattr_accessor :url_retorno, :soft_descriptor
    mattr_accessor :max_parcelas, :max_adm_parcelas, :moeda, :idioma

    def self.reset!
      cielo_mode!
    end

    def self.store_mode!
      @@mode = :store
      @@dados_ec = nil
      @@credenciais = nil
    end

    def self.store_mode?
      @@mode == :store
    end

    def self.cielo_mode!
      @@mode = :cielo
      @@dados_ec = nil
      @@credenciais = nil
    end

    def self.cielo_mode?
      @@mode == :cielo
    end

    def self.credenciais
      return @@dados_ec if @@dados_ec
      return (@@dados_ec = Requisicao::DadosEc.new @@credenciais) if @@credenciais

      mode = store_mode? ? :LOJA : :CIELO
      @@dados_ec = Requisicao::DadosEc.new Homologacao::Credenciais.const_get mode
    end

    def self.host
      @@credenciais ? HOST : Homologacao::HOST
    end

    def self.path
      WS_PATH
    end

    def self.url
      "https://#{host}#{WS_PATH}"
    end

    def self.captura_automatica
      !!@@captura_automatica
    end
  end
end
