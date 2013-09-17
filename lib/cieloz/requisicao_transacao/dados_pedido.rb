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

    def self.map(source, opts={})
      mappings = attrs_from source, opts, :numero, :valor,
        :descricao, :data_hora, :moeda, :idioma, :soft_descriptor

      num, val, desc, time, cur, lang, soft = mappings
      val = (val * 100).round unless val.nil? or val.integer?

      time  ||= Time.now
      cur   ||= Cieloz::Configuracao.moeda
      lang  ||= Cieloz::Configuracao.idioma
      soft  ||= Cieloz::Configuracao.soft_descriptor

      new data_hora: time, numero: num, valor: val, moeda: cur,
        idioma: lang, descricao: desc, soft_descriptor: soft
    end

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
