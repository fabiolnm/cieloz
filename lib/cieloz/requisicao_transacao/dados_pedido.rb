class Cieloz::RequisicaoTransacao
  class DadosPedido
    include Cieloz::Helpers

    IDIOMAS = [ "PT", "EN", "ES" ] # portugues, ingles, espanhol

    attr_accessor :numero, :valor, :moeda, :data_hora, :descricao, :idioma, :soft_descriptor

    validates :numero, :valor, :moeda, :data_hora, presence: true

    validates :numero, length: { in: 1..20 }

    validates :valor, length: { in: 1..12 }
    validates :valor, numericality: { only_integer: true }

    validates :descricao, length: { in: 0..1024 }
    validates :idioma, inclusion: { in: IDIOMAS }
    validates :soft_descriptor, length: { in: 0..13 }

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
