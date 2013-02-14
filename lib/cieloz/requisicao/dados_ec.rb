module Cieloz
  class Requisicao
    class DadosEc
      include Helpers

      attr_accessor :numero, :chave
      validates :numero, :chave, presence: true

      def attributes
        { numero: @numero, chave: @chave }
      end
    end
  end
end
