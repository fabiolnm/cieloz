# encoding: utf-8

describe Cieloz::Requisicao::DadosEc do
  it { must_validate_presence_of :numero }
  it { must_validate_presence_of :chave }
end

describe Cieloz::RequisicaoTransacao::DadosPortador do
  let(:_) { subject.class }

  it "must not override codigo_seguranca if it's given for initializer" do
    _.new(codigo_seguranca: "123").codigo_seguranca.wont_be_nil
  end

  it { must_ensure_length_of :nome_portador, is_at_most: 50 }

  let(:invalid_number) {
    I18n.t 'activemodel.errors.models.cieloz/requisicao_transacao/dados_portador.attributes.numero.invalid'
  }

  it {
    (100..9999).step(123).each {|val|
      must_allow_value :codigo_seguranca, val
    }
  }

  let(:invalid_security_number) {
    I18n.t 'activemodel.errors.models.cieloz/requisicao_transacao/dados_portador.attributes.codigo_seguranca.invalid'
  }
  it { wont_allow_value :codigo_seguranca, 99, message: invalid_security_number }
  it { wont_allow_value :codigo_seguranca, 10000, message: invalid_security_number }
  it { wont_allow_value :codigo_seguranca, "ab1", message: invalid_security_number }
  it { wont_allow_value :codigo_seguranca, "abc1", message: invalid_security_number }

  def mm_values range
    yyyy = 2013
    range.map { |i| mm = '%02d' % (i % 100) ; "#{yyyy}#{mm}" }
  end

  it "validates mês validade" do
    year, month = Date.today.year, Date.today.month
    (month..12).each {|m|
      must_allow_value :validade, "#{year}#{"%02d" % m}"
    }
    (0..9).each {|m|
      subject.validade = "#{year}#{"%d" % m}"
      subject.valid?
      subject.errors[:validade].must_equal [ I18n.t(:invalid, scope: [:errors, :messages]) ]
    }
    (13..99).each {|m|
      subject.validade = "#{year}#{"%d" % m}"
      subject.valid?
      subject.errors[:validade].must_equal [ I18n.t(:invalid, scope: [:errors, :messages]) ]
    }
  end

  it "validates ano validade" do
    year = Date.today.year
    (year+1..year+10).each {|y|
      must_allow_value :validade, "#{y}01"
    }
    (year-10..year-1).each {|y|
      subject.validade = "#{y}01"
      subject.valid?
      subject.errors[:validade].must_equal [ I18n.t(:invalid, scope: [:errors, :messages]) ]
    }
  end

  describe "indicador and codigo_seguranca validation" do
    let(:code) { 123 }

    before do
      subject.instance_variable_set :@codigo_seguranca, code
      refute_nil subject.codigo_seguranca
    end

    it "sets indicador nao informado" do
      subject.indicador_nao_informado!
      assert_equal _::INDICADOR_NAO_INFORMADO, subject.indicador
      assert_nil subject.codigo_seguranca
    end

    it "sets indicador when codigo_seguranca is set" do
      subject.codigo_seguranca = code
      assert_equal _::INDICADOR_INFORMADO, subject.indicador
      assert_equal code, subject.codigo_seguranca
    end

    it "sets indicador ilegivel" do
      subject.indicador_ilegivel!
      assert_equal _::INDICADOR_ILEGIVEL, subject.indicador
      assert_nil subject.codigo_seguranca
    end

    it "sets indicador inexistente" do
      subject.indicador_inexistente!
      assert_equal _::INDICADOR_INEXISTENTE, subject.indicador
      assert_nil subject.codigo_seguranca
    end

    it "defaults to NAO_INFORMADO" do
      subject = _.new
      assert_equal _::INDICADOR_NAO_INFORMADO, subject.indicador
      assert_nil subject.codigo_seguranca
    end
  end

  it "is validated inside RequisicaoTransacao" do
    Cieloz::Configuracao.store_mode!
    txn = Cieloz::RequisicaoTransacao.new dados_portador: subject
    refute txn.valid?
    refute txn.errors[:dados_portador].empty?
  end
end

describe Cieloz::RequisicaoTransacao::DadosPedido do
  it { must_validate_presence_of :numero }
  it { must_ensure_length_of :numero, is_at_most: 20 }

  it { must_validate_presence_of :valor }
  it { must_validate_numericality_of :valor, only_integer: true }

  it "dont validate valor numericality if it's blank" do
    subject.valor = ""
    refute subject.valid?
    assert_equal [I18n.t('errors.messages.blank')], subject.errors[:valor]

    subject.valor = "abc"
    refute subject.valid?
    assert_equal [I18n.t('errors.messages.not_a_number')], subject.errors[:valor]
  end

  it { must_validate_presence_of :moeda }
  it { must_validate_presence_of :data_hora }

  it { must_ensure_length_of :descricao, is_at_most: 1024 }
  it { must_ensure_length_of :soft_descriptor, is_at_most: 13 }

  it { must_ensure_inclusion_of :idioma, in_array: subject.class::IDIOMAS }

  it "is validated inside RequisicaoTransacao" do
    txn = Cieloz::RequisicaoTransacao.new dados_pedido: subject
    refute txn.valid?
    refute txn.errors[:dados_pedido].empty?
  end
end

describe Cieloz::RequisicaoTransacao::FormaPagamento do
  let(:all_flags) { Cieloz::Bandeiras::ALL }

  let(:invalid_flag) {
    I18n.t 'activemodel.errors.models.cieloz/requisicao_transacao/forma_pagamento.attributes.bandeira.invalid'
  }

  describe "debito validation" do
    let(:supported_flags) { subject.class::BANDEIRAS_DEBITO }

    it "validates bandeira is VISA or MASTERCARD" do
      supported_flags.each { |flag|
        subject.debito flag
        must_ensure_inclusion_of :bandeira, in_array: supported_flags, message: invalid_flag
      }
    end

    it "accepts payment for VISA and MASTERCARD" do
      supported_flags.each { |flag|
        subject.debito flag
        assert_equal subject.class::DEBITO, subject.produto
        assert_equal flag,  subject.bandeira
        assert_equal 1,     subject.parcelas
      }
    end
  end

  it "validates bandeiras for credito" do
    all_flags.each { |flag|
      subject.credito flag
      must_ensure_inclusion_of :bandeira, in_array: all_flags, message: invalid_flag
    }
  end

  it "accepts payment for credito" do
    all_flags.each { |flag|
      subject.credito flag
      assert_equal subject.class::CREDITO, subject.produto
      assert_equal flag,  subject.bandeira
      assert_equal 1,     subject.parcelas
    }
  end

  describe "validates parcelamento" do
    it "is not supported by DISCOVER" do
      supported_flags = subject.class::BANDEIRAS_PARCELAMENTO

      subject.parcelado Cieloz::Bandeiras::DISCOVER, 2
      must_ensure_inclusion_of :bandeira, in_array: supported_flags, message: invalid_flag
    end

    let(:flag) { all_flags.first }
    let(:max_parcelas) { Cieloz::Configuracao.max_parcelas }
    let(:max_adm_parcelas) { Cieloz::Configuracao.max_adm_parcelas }

    it "converts 1 installment to CREDITO" do
      pg = subject.parcelado flag, 1
      assert_equal subject.class::CREDITO, pg.produto
    end

    it "creates a PARCELADO_LOJA payment till max_parcelas" do
      (2..max_parcelas).each do |n|
        pg = subject.parcelado flag, n
        assert_equal subject.class::PARCELADO_LOJA, pg.produto
        assert_equal flag, pg.bandeira
        assert_equal n, pg.parcelas
      end
    end

    it "creates a PARCELADO_ADM payment between max_installments and max_adm_installments" do
      (max_parcelas+1..max_adm_parcelas).each do |n|
        pg = subject.parcelado flag, n
        assert_equal subject.class::PARCELADO_ADM, pg.produto
        assert_equal flag, pg.bandeira
        assert_equal n, pg.parcelas
      end
    end

    it "validates parcelas in range 1..max_adm_parcelas" do
      (1..max_adm_parcelas).each {|i|
        assert subject.parcelado(flag, i).valid?, subject.errors.messages
      }
      (-10..0).each { |i|
        refute subject.parcelado(flag, i).valid?, subject.errors.messages
      }
      (max_adm_parcelas+1..max_adm_parcelas+3).each { |i|
        refute subject.parcelado(flag, i).valid?, subject.errors.messages
      }
      # refute not integers parcelas
      refute subject.parcelado(flag, 1.234).valid?
      refute subject.parcelado(flag, "abc").valid?
    end
  end

  it "is validated inside RequisicaoTransacao" do
    txn = Cieloz::RequisicaoTransacao.new forma_pagamento: subject
    refute txn.valid?
    refute txn.errors[:forma_pagamento].empty?
  end
end

describe Cieloz::RequisicaoTransacao do
  let(:_) { subject.class }

  it { must_validate_presence_of :dados_pedido }
  it { must_validate_presence_of :forma_pagamento }

  it "somente autenticar requires url_retorno" do
    subject.somente_autenticar
    must_validate_presence_of :url_retorno
  end

  it "autorizar somente autenticada requires url_retorno" do
    subject.autorizar_somente_autenticada
    must_validate_presence_of :url_retorno
  end

  it "autorizar nao autenticada requires url_retorno" do
    subject.autorizar_nao_autenticada
    must_validate_presence_of :url_retorno
  end

  it "autorizacao direta doesnt require url_retorno" do
    subject.autorizacao_direta
    wont_validate_presence_of :url_retorno
  end

  it { must_ensure_length_of :url_retorno, is_at_most: 1024 }

  it "doesnt validate url_retorno length for autorizacao direta" do
    subject.autorizacao_direta
    wont_ensure_length_of :url_retorno, is_at_least: 1, is_at_most: 1024
  end


  let(:invalid_auth_mode) {
    I18n.t 'activemodel.errors.models.cieloz/requisicao_transacao.attributes.autorizar.inclusion'
  }
  it {
    must_ensure_inclusion_of :autorizar, in_array: [
      _::SOMENTE_AUTENTICAR, _::AUTORIZAR_SE_AUTENTICADA,
      _::AUTORIZAR_NAO_AUTENTICADA, _::AUTORIZACAO_DIRETA, _::RECORRENTE
    ], message: invalid_auth_mode
  }

  it "doesnt support autorizacao_direta on debito operations" do
    pg = subject.class::FormaPagamento.new
    pg.debito Cieloz::Bandeiras::VISA
    subject.forma_pagamento = pg

    subject.autorizacao_direta

    refute subject.valid?
    assert_equal "Direct auth available for credit only", subject.errors[:autorizar].first
  end

  def refute_authentication_supported
    refute subject.valid?
    assert_equal "Authentication not supported", subject.errors[:autorizar].first
  end

  it "refute authentication support for DINERS, DISCOVER, ELO and AMEX" do
    (Cieloz::Bandeiras::ALL - subject.class::FormaPagamento::SUPORTAM_AUTENTICACAO).each { |b|
      pg = subject.class::FormaPagamento.new
      pg.credito b
      subject.forma_pagamento = pg

      subject.somente_autenticar
      refute_authentication_supported

      subject.autorizar_somente_autenticada
      refute_authentication_supported

      subject.autorizar_nao_autenticada
      refute_authentication_supported

      subject.recorrente
      refute_authentication_supported
    }
  end

  it "has authentication support for VISA and MASTERCARD" do
    subject.class::FormaPagamento::SUPORTAM_AUTENTICACAO.each { |b|
      pg = subject.class::FormaPagamento.new
      pg.credito b
      subject.forma_pagamento = pg

      subject.somente_autenticar
      assert subject.errors[:autorizacao].empty?

      subject.autorizar_somente_autenticada
      assert subject.errors[:autorizacao].empty?

      subject.autorizar_nao_autenticada
      assert subject.errors[:autorizacao].empty?

      subject.recorrente
      assert subject.errors[:autorizacao].empty?
    }
  end

  it {
    must_ensure_inclusion_of :capturar, in_array: ["true", "false"], message:
    I18n.t('activemodel.errors.models.cieloz/requisicao_transacao.attributes.capturar.inclusion')
  }

  it { must_ensure_length_of :campo_livre, is_at_most: 128 }

  it "extracts bin from DadosPortador" do
    # no DadosPortador - bin should be nil
    assert subject.attributes[:bin].nil?

    p = subject.class::DadosPortador.new numero: 1234567887654321
    subject.dados_portador = p
    assert_equal "123456", subject.attributes[:bin]
  end

  it "validates dados portador on mode Buy Page Loja" do
    Cieloz::Configuracao.store_mode!
    must_validate_presence_of :dados_portador
  end

  describe "Buy Page Cielo" do
    it "wont validate dados portador if mode is nil" do
      Cieloz::Configuracao.reset!
      wont_validate_presence_of :dados_portador
    end

    it "wont validate dados portador on hosted mode" do
      Cieloz::Configuracao.cielo_mode!
      wont_validate_presence_of :dados_portador
    end
  end

  it "validates parcela minima is R$ 5,00" do
    subject.dados_pedido = subject.class::DadosPedido.new numero: 123,
      valor: 1400, idioma: "PT", moeda: "986", data_hora: Time.now

    subject.forma_pagamento = subject
    .class::FormaPagamento.new.parcelado Cieloz::Bandeiras::VISA, 3

    refute subject.valid?
    msg = "Installment should be greater than or equal to R$ 5,00"
    assert_equal msg, subject.dados_pedido.errors[:valor].first
  end

  describe "validates credit card number format" do
    after do
      Cieloz::Configuracao.reset!
    end

    def self.validate_number_of_credit_card_digits_for(flag, digits)
      describe flag do
        let(:pg) { subject.class::FormaPagamento.new.credito flag }

        before do
          Cieloz::Configuracao.store_mode!
          subject.forma_pagamento = pg
        end

        it "accepts credit card numbers with #{digits} digits" do
          subject.dados_portador = subject.class::DadosPortador.new numero: '1' * digits
          subject.valid?
          subject.dados_portador.errors[:numero].must_be_empty
        end

        it "rejects credit card numbers with other formats" do
          ['1' * (digits - 1), '1' * (digits + 1), 'ABC4567890123456'].each do |number|
            subject.dados_portador = subject.class::DadosPortador.new numero: number
            subject.valid?
            subject.dados_portador.errors[:numero].wont_be_empty
          end
        end
      end
    end

    validate_number_of_credit_card_digits_for Cieloz::Bandeiras::DINERS,      14
    validate_number_of_credit_card_digits_for Cieloz::Bandeiras::AMEX,        15
    validate_number_of_credit_card_digits_for Cieloz::Bandeiras::VISA,        16
    validate_number_of_credit_card_digits_for Cieloz::Bandeiras::MASTERCARD,  16
    validate_number_of_credit_card_digits_for Cieloz::Bandeiras::ELO,         16
    validate_number_of_credit_card_digits_for Cieloz::Bandeiras::DISCOVER,    16
  end
end
