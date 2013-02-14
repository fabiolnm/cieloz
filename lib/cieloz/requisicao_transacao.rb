class Cieloz::RequisicaoTransacao < Cieloz::Base
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

  hattr_writer  :dados_portador, :dados_pedido, :forma_pagamento
  attr_reader   :dados_portador, :dados_pedido, :forma_pagamento
  attr_reader   :autorizar, :capturar
  attr_accessor :campo_livre, :url_retorno

  validate :nested_validations

  validates :dados_portador, presence: true, if: "Cieloz.store_mode?"
  validates :dados_pedido, :forma_pagamento, presence: true

  with_options unless: "@forma_pagamento.nil?" do |txn|
    txn.validate :suporta_autorizacao_direta?
    txn.validate :suporta_autenticacao?
  end

  validate :parcela_minima?,
    if: "not @dados_pedido.nil? and not @forma_pagamento.nil?"

  validates :autorizar, presence: true, inclusion: { in: CODIGOS_AUTORIZACAO }
  # validates string values because false.blank? is true, failing presence validation
  validates :capturar,  presence: true, inclusion: { in: ["true", "false"] }

  with_options if: "@autorizar != AUTORIZACAO_DIRETA" do |txn|
    txn.validates :url_retorno, presence: true
    txn.validates :url_retorno, length: { in: 1..1024 }
  end

  validates :campo_livre, length: { maximum: 128 }

  def nested_validations
    nested_attrs = [ :dados_ec, :dados_pedido, :forma_pagamento ]
    nested_attrs << :dados_portador if Cieloz.store_mode?

    nested_attrs.each { |attr|
      attr_value = instance_variable_get "@#{attr}"
      if not attr_value.nil? and not attr_value.valid?
        errors.add attr, attr_value.errors
      end
    }
  end

  def parcela_minima?
    if @dados_pedido.valid? and @forma_pagamento.valid?
      if @dados_pedido.valor / @forma_pagamento.parcelas < 500
        errors.add :dados_pedido,
          "O valor minimo da parcela deve ser R$ 5,00"
      end
    end
  end

  def somente_autenticar
    @autorizar = SOMENTE_AUTENTICAR
    self
  end

  def autorizar_somente_autenticada
    @autorizar = AUTORIZAR_SE_AUTENTICADA
    self
  end

  def autorizar_nao_autenticada
    @autorizar = AUTORIZAR_NAO_AUTENTICADA
    self
  end

  def autorizacao_direta
    @autorizar = AUTORIZACAO_DIRETA
    self
  end

  def autorizacao_direta?
    @autorizar == AUTORIZACAO_DIRETA
  end

  def recorrente
    @autorizar = RECORRENTE
    self
  end

  def capturar_automaticamente
    @capturar = "true"
    self
  end

  def nao_capturar_automaticamente
    @capturar = "false"
    self
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
      campo_livre:      @campo_livre,
      bin:              (@dados_portador.numero.to_s[0..5] unless @dados_portador.nil?)
    }
  end
end
