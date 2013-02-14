class Cieloz::RequisicaoTransacao
  class DadosPortador
    INDICADOR_NAO_INFORMADO = 0
    INDICADOR_INFORMADO     = 1
    INDICADOR_ILEGIVEL      = 2
    INDICADOR_INEXISTENTE   = 9

    include Cieloz::Helpers

    attr_accessor :numero, :nome_portador, :validade
    attr_reader :indicador, :codigo_seguranca

    validates :nome_portador, length: { in: 0..50 }

    validates :numero, :validade, :indicador, presence: true

    validates :numero, length: { is: 16 }
    validates :numero, numericality: { only_integer: true }

    validates :validade, length: { is: 6 }
    validates :validade, format: { with: /2\d{3}(0[1-9]|1[012])/ }
    validates :validade, numericality: { only_integer: true }

    validates :codigo_seguranca, length: { in: 3..4 }
    validates :codigo_seguranca, numericality: { only_integer: true }

    def initialize attrs={}
      super
      indicador_nao_informado!
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
  end
end
