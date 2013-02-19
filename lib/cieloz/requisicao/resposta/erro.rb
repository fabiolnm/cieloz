module Cieloz
  class Requisicao
    class Erro < Resposta
      attr_accessor :codigo, :mensagem

      def success?
        false
      end

      def status
        codigo
      end
    end
  end
end
