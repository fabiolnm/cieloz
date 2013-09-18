class Cieloz::RequisicaoTransacao
  class DadosPortador
    INDICADOR_NAO_INFORMADO = 0
    INDICADOR_INFORMADO     = 1
    INDICADOR_ILEGIVEL      = 2
    INDICADOR_INEXISTENTE   = 9

    include Cieloz::Helpers

    attr_accessor :numero, :nome_portador, :validade
    attr_reader :indicador, :codigo_seguranca

    validates :nome_portador, length: { maximum: 50 }

    set_callback :validate, :before do |portador|
      [:numero, :validade, :codigo_seguranca].each {|attr|
        val = portador.send attr
        portador.instance_variable_set "@#{attr}", val.to_s
      }
      portador.numero.gsub! ' ', ''
    end

    validates :numero, format: { with: /\A\d{16}\z/ }
    validates :codigo_seguranca, format: { with: /\A(\d{3}|\d{4})\z/ }

    validate :valida_validade

    validates :indicador, presence: true

    def self.map(source, opts={})
      num, val, cod, nome = attrs_from source, opts,
        :numero, :validade, :codigo_seguranca, :nome_portador

      new source: source, opts: opts,
        numero: num, validade: val, codigo_seguranca: cod, nome_portador: nome
    end

    def initialize attrs={}
      super
      indicador_nao_informado! if codigo_seguranca.blank?
    end

    def mascara
      num = numero.to_s
      mask_size = num.length - 6
      ("*" * mask_size) + num[mask_size..-1]
    end

    def codigo_seguranca= codigo
      @indicador = INDICADOR_INFORMADO
      @codigo_seguranca = codigo
    end

    def indicador_nao_informado!
      @indicador = INDICADOR_NAO_INFORMADO
      @codigo_seguranca = nil
    end

    def indicador_ilegivel!
      @indicador = INDICADOR_ILEGIVEL
      @codigo_seguranca = nil
    end

    def indicador_inexistente!
      @indicador = INDICADOR_INEXISTENTE
      @codigo_seguranca = nil
    end

    def attributes
      {
        numero:           @numero,
        validade:         @validade,
        indicador:        indicador,
        codigo_seguranca: @codigo_seguranca,
        nome_portador:    @nome_portador
      }
    end

    module TEST
      VISA_AUTH       = DadosPortador.new numero: 4012001037141112
      MASTERCARD_AUTH = DadosPortador.new numero: 5453010000066167
      VISA            = DadosPortador.new numero: 4012001038443335
      MASTERCARD      = DadosPortador.new numero: 5453010000066167
      AMEX            = DadosPortador.new numero: 376449047333005
      ELO             = DadosPortador.new numero: 6362970000457013
      DINERS          = DadosPortador.new numero: 36490102462661
      DISCOVERY       = DadosPortador.new numero: 6011020000245045

      constants.each { |c|
        flag = const_get c
        flag.validade = 201805
        flag.codigo_seguranca = 123
      }
    end

    private
    def valida_validade
      val = validade.to_i
      min = Date.today.strftime("%Y%m").to_i
      max = 10.years.from_now.strftime("%Y%m").to_i
      errors.add :validade, :invalid unless val.between?(min, max) and val % 100 <= 12
    end
  end
end
