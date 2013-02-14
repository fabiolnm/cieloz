module Cieloz
  module Configuracao
    WS_PATH = "/servicos/ecommwsec.do"

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
  end
end
