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

    validate :valida_ano_validade, unless: ->{ validade.nil? }
    validate :valida_mes_validade, unless: ->{ validade.nil? }

    validates :indicador, presence: true

    def initialize attrs={}
      super
      indicador_nao_informado! if codigo_seguranca.blank?
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
      VISA                = DadosPortador.new numero: 4012001037141112
      MACSTERCARD         = DadosPortador.new numero: 5453010000066167
      VISA_NO_AUTH        = DadosPortador.new numero: 4012001038443335
      MASTERCARD_NO_AUTH  = DadosPortador.new numero: 5453010000066167
      AMEX                = DadosPortador.new numero: 376449047333005
      ELO                 = DadosPortador.new numero: 6362970000457013
      DINERS              = DadosPortador.new numero: 36490102462661
      DISCOVERY           = DadosPortador.new numero: 6011020000245045

      constants.each { |c|
        flag = const_get c
        flag.validade = 201805
        flag.codigo_seguranca = 123
      }
    end

    private
    def valida_mes_validade
      if mes = validade[4..5]
        errors.add :validade, :invalid_month unless mes.length == 2 and mes.to_i.between? 1, 12
      end
    end

    def valida_ano_validade
      if ano = validade[0..3]
        errors.add :validade, :invalid_year if ano.to_i < Date.today.year
      end
    end
  end
end
