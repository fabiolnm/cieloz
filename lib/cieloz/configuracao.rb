module Cieloz
  module Configuracao
    HOST    = "ecommerce.cielo.com.br"
    WS_PATH = "/servicos/ecommwsec.do"

    mattr_writer :credenciais
    mattr_accessor :max_parcelas

    def self.reset_mode!
      @mode = nil
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
      return (@dados_ec = Requisicao::DadosEc.new @credenciais) if @credenciais

      mode = store_mode? ? :LOJA : :CIELO
      Homologacao::Credenciais.const_get mode
    end

    def self.host
      @credenciais ? HOST : Homologacao::HOST
    end

    def self.path
      WS_PATH
    end

    def self.url
      "https://#{host}#{WS_PATH}"
    end
  end
end
