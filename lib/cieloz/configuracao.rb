module Cieloz
  module Configuracao
    HOST    = "ecommerce.cielo.com.br"
    WS_PATH = "/servicos/ecommwsec.do"

    mattr_accessor :credenciais_hash, :max_parcelas

    def self.reset!
      @mode = nil
      self.credenciais_hash = nil
    end

    def self.store_mode!
      @mode = :store
    end

    def self.store_mode?
      @mode == :store
    end

    def self.cielo_mode!
      @mode = :cielo
    end

    def self.cielo_mode?
      @mode.nil? or @mode == :cielo
    end

    def self.credenciais
      return @dados_ec if @dados_ec
      return (@dados_ec = Requisicao::DadosEc.new @@credenciais_hash) if @@credenciais_hash

      mode = store_mode? ? :LOJA : :CIELO
      Homologacao::Credenciais.const_get mode
    end

    def self.host
      credenciais_hash ? HOST : Homologacao::HOST
    end

    def self.path
      WS_PATH
    end

    def self.url
      "https://#{host}#{WS_PATH}"
    end
  end
end
