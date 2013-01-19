class Cieloz::RequisicaoTransacao < Cieloz::Base
  class DadosPortador
    INDICADOR_NAO_INFORMADO = 0
    INDICADOR_INFORMADO     = 1
    INDICADOR_ILEGIVEL      = 2
    INDICADOR_INEXISTENTE   = 9

    include Cieloz::Helpers

    attr_accessor :numero, :nome_portador, :validade
    attr_reader :indicador, :codigo_seguranca

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

  class DadosPedido
    include Cieloz::Helpers

    attr_accessor :numero, :valor, :moeda, :data_hora, :descricao, :idioma, :soft_descriptor

    validates :numero, :valor, :moeda, :data_hora, presence: true

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

  class FormaPagamento
    DEBITO          = "A"
    CREDITO         = 1
    PARCELADO_LOJA  = 2
    PARCELADO_ADM   = 3

    include Cieloz::Helpers

    attr_reader :bandeira, :produto, :parcelas

    validates :bandeira, :produto, :parcelas, presence: true
    validates :parcelas, numericality: {
      only_integer: true, greater_than: 0, less_than_or_equal_to: 3
    }
    validate :operacao_nao_especificada

    def attributes
      {
        bandeira: @bandeira,
        produto:  @produto,
        parcelas: @parcelas
      }
    end

    def debito bandeira
      raise "Operacao disponivel apenas para VISA e MasterCard" unless [
        Cieloz::Bandeiras::VISA, Cieloz::Bandeiras::MASTER_CARD
      ].include? bandeira

      set_attrs bandeira, DEBITO, 1
    end

    def credito bandeira
      set_attrs bandeira, CREDITO, 1
    end

    def parcelado_loja bandeira, parcelas
      parcelar bandeira, parcelas, PARCELADO_LOJA
    end

    def parcelado_adm bandeira, parcelas
      parcelar bandeira, parcelas, PARCELADO_ADM
    end

    private
    def set_attrs bandeira, produto, parcelas
      @bandeira = bandeira
      @produto  = produto
      @parcelas = parcelas
      self
    end

    def parcelar bandeira, parcelas, produto
      raise "Nao suportado pela bandeira DISCOVER" if bandeira == Cieloz::Bandeiras::DISCOVER
      if parcelas == 1
        credito bandeira
      else
        set_attrs bandeira, produto, parcelas
      end
    end

    def operacao_nao_especificada
      if @bandeira.nil? or @produto.nil? or @parcelas.nil?
        errors.add :estado_invalido, %{#{attributes.to_s} - execute
          alguma das operacoes de debito, credito ou parcelamento}
      end
    end
  end

  SOMENTE_AUTENTICAR        = 0
  AUTORIZAR_SE_AUTENTICADA  = 1
  AUTORIZAR_NAO_AUTENTICADA = 2
  AUTORIZACAO_DIRETA        = 3
  RECORRENTE                = 4

  hattr_writer :dados_portador
  hattr_writer :dados_pedido, :forma_pagamento

  attr_accessor :campo_livre, :url_retorno
  attr_reader :autorizar
  attr_reader :capturar

  def somente_autenticar
    @autorizar = SOMENTE_AUTENTICAR
  end

  def requer_autenticacao
    @autorizar = AUTORIZAR_SE_AUTENTICADA
  end

  def nao_requer_autenticacao
    @autorizar = AUTORIZAR_NAO_AUTENTICADA
  end

  def autorizacao_direta
    @autorizar = AUTORIZACAO_DIRETA
  end

  def recorrente
    @autorizar = RECORRENTE
  end

  def capturar_automaticamente
    @capturar = true
  end

  def nao_capturar_automaticamente
    @capturar = false
  end

  def attributes
    {
      dados_ec:         @dados_ec,
      dados_portador:   @dados_portador,
      dados_pedido:     @dados_pedido,
      forma_pagamento:  @forma_pagamento,
      url_retorno:      @url_retorno,
      autorizar:        @autorizar,
      capturar:         @capturar,
      campo_livre:      @campo_livre
    }
  end
end
