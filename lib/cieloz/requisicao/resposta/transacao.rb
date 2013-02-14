module Cieloz
  class Requisicao
    class Transacao < Resposta
      attr_accessor :tid, :status, :url_autenticacao

      def success?
        true
      end
    end
  end
end
