module Cieloz
  class Requisicao
    class Erro < Resposta
      attr_accessor :codigo, :mensagem

      def success?
        false
      end
    end
  end
end
