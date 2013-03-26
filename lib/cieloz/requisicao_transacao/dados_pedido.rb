class Cieloz::RequisicaoTransacao
  class DadosPedido
    include Cieloz::Helpers

    IDIOMAS = [ "PT", "EN", "ES" ] # portugues, ingles, espanhol

    attr_accessor :numero, :valor, :moeda, :data_hora, :descricao, :idioma, :soft_descriptor

    validates :numero, :valor, :moeda, :data_hora, presence: true

    validates :numero, length: { maximum: 20 }

    validates :valor, length: { maximum: 12 }
    validates :valor, numericality: { only_integer: true }, unless: "@valor.blank?"

    validates :descricao, length: { maximum: 1024 }
    validates :idioma, inclusion: { in: IDIOMAS }
    validates :soft_descriptor, length: { maximum: 13 }

    def attributes
      {
        numero:           @numero,
        valor:            @valor,
        moeda:            @moeda,
        data_hora:        @data_hora.strftime("%Y-%m-%dT%H:%M:%S"),
        descricao:        @descricao,
        idioma:           @idioma,
        soft_descriptor:  @soft_descriptor
      }
    end
  end
end
