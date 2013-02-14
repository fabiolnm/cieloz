module Cieloz
  module Homologacao
    HOST = "qasecommerce.cielo.com.br"

    def self.url
      "https://#{HOST}#{Cieloz::Configuracao::WS_PATH}"
    end

    module Credenciais
      CIELO = {
        numero: "1001734898",
        chave: "e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"
      }
      LOJA  = {
        numero: "1006993069",
        chave: "25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3"
      }
    end
  end
end
