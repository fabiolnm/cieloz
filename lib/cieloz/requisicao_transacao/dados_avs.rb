class Cieloz::RequisicaoTransacao
  class DadosAvs
    CONFERE       = 'C'
    NAO_CONFERE   = 'N'
    INDISPONIVEL  = 'I'
    TEMPORARIAMENTE_INDISPONIVEL = 'T'
    NAO_SUPORTADO = 'X'

    include Cieloz::Helpers

    attr_accessor :cep, :endereco, :complemento, :numero, :bairro

    validates :cep, presence: true, format: { with: /\A(\d{5}-\d{3})\z/ }

    def self.map(source, opts={})
      cep, endereco, complemento, numero, bairro = attrs_from source, opts,
        :cep, :endereco, :complemento, :numero, :bairro

      new source: source, opts: opts,
        cep: cep, endereco: endereco, complemento: complemento, numero: numero, bairro: bairro
    end

    def attributes
      {
        endereco:    @endereco,
        complemento: @complemento,
        numero:      @numero,
        bairro:      @bairro,
        cep:         @cep
      }
    end

    def build_xml builder
      builder.tag! 'avs' do
        builder.cdata! attr_to_xml
      end
    end

    private
    def attr_to_xml
      x = Builder::XmlMarkup.new
      @xml = x.tag! 'dados-avs' do
        attributes.each do |attr, value|
          next if value.nil?

          x.tag! dasherize_attr(attr), value
        end
      end
    end
  end
end
