class Cieloz::RequisicaoTransacao < Cieloz::Requisicao
  SOMENTE_AUTENTICAR        = 0
  AUTORIZAR_SE_AUTENTICADA  = 1
  AUTORIZAR_NAO_AUTENTICADA = 2
  AUTORIZACAO_DIRETA        = 3
  RECORRENTE                = 4

  hattr_writer  :dados_portador, :dados_pedido, :forma_pagamento
  attr_reader   :dados_portador, :dados_pedido, :forma_pagamento
  attr_reader   :autorizar, :capturar
  attr_accessor :campo_livre, :url_retorno

  validate :nested_validations

  with_options if: "Cieloz::Configuracao.store_mode?" do |c|
    c.validates :dados_portador, presence: true
    c.validate :valida_digitos_numero_cartao
  end

  validates :dados_pedido, :forma_pagamento, presence: true

  with_options unless: "@forma_pagamento.nil?" do |txn|
    txn.validate :suporta_autorizacao_direta?
    txn.validate :suporta_autenticacao?
  end

  validate :parcela_minima?,
    if: "not @dados_pedido.nil? and not @forma_pagamento.nil?"

  validates :autorizar, inclusion: {
    in: [
      SOMENTE_AUTENTICAR, AUTORIZAR_SE_AUTENTICADA,
      AUTORIZAR_NAO_AUTENTICADA, AUTORIZACAO_DIRETA, RECORRENTE
    ]
  }
  # validates string values because false.blank? is true, failing presence validation
  validates :capturar, inclusion: { in: ["true", "false"] }

  with_options if: "@autorizar != AUTORIZACAO_DIRETA" do |txn|
    txn.validates :url_retorno, presence: true
    txn.validates :url_retorno, length: { maximum: 1024 }
  end

  validates :campo_livre, length: { maximum: 128 }

  def self.map(source, opts={})
    portador, pedido, pagamento, url, capturar, campo_livre =
      attrs_from source, opts, :dados_portador, :dados_pedido,
      :forma_pagamento, :url_retorno, :capturar, :campo_livre

    url ||= Cieloz::Configuracao.url_retorno

    txn = new source: source, opts: opts, dados_portador: portador,
      dados_pedido: pedido, forma_pagamento: pagamento,
      campo_livre: campo_livre, url_retorno: url,
      dados_ec: Cieloz::Configuracao.credenciais

    capturar ||= Cieloz::Configuracao.captura_automatica

    case capturar.to_s
    when 'true' then txn.capturar_automaticamente
    else        txn.nao_capturar_automaticamente
    end

    txn.send pagamento.metodo_autorizacao if pagamento

    txn
  end

  def nested_validations
    nested_attrs = [ :dados_ec, :dados_pedido, :forma_pagamento ]
    nested_attrs << :dados_portador if Cieloz::Configuracao.store_mode?

    nested_attrs.each { |attr|
      attr_value = instance_variable_get "@#{attr}"
      if not attr_value.nil? and not attr_value.valid?
        errors.add attr, attr_value.errors
      end
    }
  end

  def parcela_minima?
    valor, parcelas = @dados_pedido.valor.to_i, @forma_pagamento.parcelas.to_i
    if parcelas > 0 and valor / parcelas < 500
      @dados_pedido.errors.add :valor, :minimum_installment_not_satisfied
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
      errors.add :autorizar, :direct_auth_available_for_credit_only
    end
  end

  def suporta_autenticacao?
    if not autorizacao_direta? and not @forma_pagamento.suporta_autenticacao?
      errors.add :autorizar, :authentication_not_supported
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

  private
  def valida_digitos_numero_cartao
    if dados_portador and forma_pagamento and bandeira = forma_pagamento.bandeira
      numero = dados_portador.numero.to_s
      case bandeira.to_s
      when Cieloz::Bandeiras::DINERS
        dados_portador.errors.add :numero, :invalid_diners  unless numero =~ /\A\d{14}\z/
      when Cieloz::Bandeiras::AMEX
        dados_portador.errors.add :numero, :invalid_amex    unless numero =~ /\A\d{15}\z/
      else
        dados_portador.errors.add :numero, :invalid         unless numero =~ /\A\d{16}\z/
      end
    end
  end
end
