class Cieloz::RequisicaoTransacao < Cieloz::Base
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

  class FormaPagamento
    DEBITO          = "A"
    CREDITO         = 1
    PARCELADO_LOJA  = 2
    PARCELADO_ADM   = 3

    BANDEIRAS_DEBITO = [ Cieloz::Bandeiras::VISA, Cieloz::Bandeiras::MASTER_CARD ]
    SUPORTAM_AUTENTICACAO = BANDEIRAS_DEBITO

    BANDEIRAS_PARCELAMENTO = Cieloz::Bandeiras::ALL - [Cieloz::Bandeiras::DISCOVER]

    include Cieloz::Helpers

    attr_reader :bandeira, :produto, :parcelas

    validates :bandeira, :produto, :parcelas, presence: true

    validates :parcelas, numericality: {
      only_integer: true, greater_than: 0, less_than_or_equal_to: 3
    }

    validates :bandeira, inclusion: { in: BANDEIRAS_DEBITO }, if: "@produto == DEBITO"
    validates :bandeira, inclusion: { in: Cieloz::Bandeiras::ALL }, if: "@produto == CREDITO"
    validates :bandeira, inclusion: { in: BANDEIRAS_PARCELAMENTO },
      if: "[ PARCELADO_LOJA, PARCELADO_ADM ].include? @produto"

    def attributes
      {
        bandeira: @bandeira,
        produto:  @produto,
        parcelas: @parcelas
      }
    end

    def suporta_autenticacao?
      SUPORTAM_AUTENTICACAO.include? @bandeira
    end

    def debito bandeira
      set_attrs bandeira, DEBITO, 1
    end

    def debito?
      @produto == DEBITO
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
      if parcelas == 1
        credito bandeira
      else
        set_attrs bandeira, produto, parcelas
      end
    end
  end

  SOMENTE_AUTENTICAR        = 0
  AUTORIZAR_SE_AUTENTICADA  = 1
  AUTORIZAR_NAO_AUTENTICADA = 2
  AUTORIZACAO_DIRETA        = 3
  RECORRENTE                = 4

  CODIGOS_AUTORIZACAO = [
    SOMENTE_AUTENTICAR,
    AUTORIZAR_SE_AUTENTICADA,
    AUTORIZAR_NAO_AUTENTICADA,
    AUTORIZACAO_DIRETA,
    RECORRENTE
  ]

  hattr_writer :dados_portador
  hattr_writer :dados_pedido, :forma_pagamento

  attr_accessor :campo_livre, :url_retorno
  attr_reader :autorizar
  attr_reader :capturar

  with_options if: "@autorizar != AUTORIZACAO_DIRETA" do |txn|
    txn.validates :url_retorno, presence: true
    txn.validates :url_retorno, length: { in: 1..1024 }
  end

  validates :autorizar, presence: true,
    inclusion: { in: CODIGOS_AUTORIZACAO }

  with_options unless: "@forma_pagamento.nil?" do |txn|
    txn.validate :suporta_autorizacao_direta?
    txn.validate :suporta_autenticacao?
  end

  # validates string values because false.blank? is true, failing presence validation
  validates :capturar, presence: true,
    inclusion: { in: ["true", "false"] }

  validates :campo_livre, length: { maximum: 128 }

  def somente_autenticar
    @autorizar = SOMENTE_AUTENTICAR
  end

  def autorizar_somente_autenticada
    @autorizar = AUTORIZAR_SE_AUTENTICADA
  end

  def autorizar_nao_autenticada
    @autorizar = AUTORIZAR_NAO_AUTENTICADA
  end

  def autorizacao_direta
    @autorizar = AUTORIZACAO_DIRETA
  end

  def autorizacao_direta?
    @autorizar == AUTORIZACAO_DIRETA
  end

  def recorrente
    @autorizar = RECORRENTE
  end

  def capturar_automaticamente
    @capturar = "true"
  end

  def nao_capturar_automaticamente
    @capturar = "false"
  end

  def suporta_autorizacao_direta?
    if autorizacao_direta? and @forma_pagamento.debito?
      errors.add :autorizacao,
        "Autorizacao Direta disponivel apenas em operacoes de credito"
    end
  end

  def suporta_autenticacao?
    if not autorizacao_direta? and not @forma_pagamento.suporta_autenticacao?
      errors.add :autorizacao, "Bandeira nao possui programa de autenticacao"
    end
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
