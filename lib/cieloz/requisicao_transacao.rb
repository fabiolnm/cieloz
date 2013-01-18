class Cieloz::RequisicaoTransacao < Cieloz::Base
  class DadosPortador
    include Cieloz::Helpers

    attr_accessor :numero, :nome_portador, :validade, :codigo_seguranca
    attr_reader :indicador

    validates :numero, :validade, :indicador, presence: true

    def indicador
      1
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

    TEST_VISA   = new numero: 4012001037141112,
      validade: 201805, codigo_seguranca: 123
    TEST_MC     = new numero: 5453010000066167,
      validade: 201805, codigo_seguranca: 123
    TEST_VISA_NO_AUTH =
      new numero: 4012001038443335,
      validade: 201805, codigo_seguranca: 123
    TEST_MC_NO_AUTH =
      new numero: 5453010000066167,
      validade: 201805, codigo_seguranca: 123
    TEST_AMEX   = new numero: 376449047333005,
      validade: 201805, codigo_seguranca: 1234
    TEST_ELO    = new numero: 6362970000457013,
      validade: 201805, codigo_seguranca: 123
    TEST_DINERS = new numero: 36490102462661,
      validade: 201805, codigo_seguranca: 123
    TEST_DISC   = new numero: 6011020000245045,
      validade: 201805, codigo_seguranca: 123
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
    PARCELADO_CIELO = 3

    include Cieloz::Helpers

    attr_reader :bandeira, :produto, :parcelas

    validates :bandeira, :produto, :parcelas, presence: true

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
      raise "Parcelas invalidas: #{parcelas}" if parcelas.to_i <= 0
      raise "Nao suportado pela bandeira DISCOVER" if @bandeira == Cieloz::Bandeiras::DISCOVER
      if parcelas == 1
        credito_a_vista bandeira
      else
        set_attrs bandeira, PARCELADO_LOJA, parcelas
      end
    end

    def parcelado_adm bandeira, parcelas
      raise "Parcelas invalidas: #{parcelas}" if parcelas.to_i <= 0
      raise "Nao suportado pela bandeira DISCOVER" if @bandeira == Cieloz::Bandeiras::DISCOVER
      if parcelas == 1
        credito_a_vista bandeira
      else
        set_attrs bandeira, PARCELADO_CIELO, parcelas
      end
    end

    private
    def set_attrs bandeira, produto, parcelas
      @bandeira = bandeira
      @produto  = produto
      @parcelas = parcelas
      self
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
