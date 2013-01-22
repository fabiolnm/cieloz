describe Cieloz::DadosEc do
  it { must validate_presence_of :numero }
  it { must validate_presence_of :chave }
end

describe Cieloz::RequisicaoTransacao::DadosPortador do
  it { must ensure_length_of(:nome_portador).is_at_most(50) }

  it { must validate_presence_of :numero }
  it { must ensure_length_of(:numero).is_equal_to 16 }
  it { must validate_numericality_of(:numero).only_integer }

  it { must validate_presence_of :validade }
  it { must ensure_length_of(:validade).is_equal_to 6 }
  it { must validate_numericality_of(:validade).only_integer }

  it { must ensure_length_of(:codigo_seguranca)
                              .is_at_least(3)
                              .is_at_most(4) }
  it { must validate_numericality_of(:codigo_seguranca).only_integer }

  def mm_values range
    yyyy = 2013
    range.map { |i| mm = '%02d' % (i % 100) ; "#{yyyy}#{mm}" }
  end

  it "validates validade as yyyymm" do
    must allow_value(*mm_values(1..12)).for(:validade)

    values = mm_values(13..100) << "199911"
    wont allow_value(*values).for(:validade)
  end

  describe "indicador and codigo_seguranca validation" do
    let(:_) { subject.class }
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
end

describe Cieloz::RequisicaoTransacao::DadosPedido do
  it { must validate_presence_of :numero }
  it { must ensure_length_of(:numero)
                            .is_at_least(1)
                            .is_at_most(20) }

  it { must validate_presence_of :valor }
  it { must validate_numericality_of(:valor).only_integer }
  it { must ensure_length_of(:valor)
                            .is_at_least(1)
                            .is_at_most(12) }

  it { must validate_presence_of :moeda }
  it { must validate_presence_of :data_hora }

  it { must ensure_length_of(:descricao).is_at_most(1024) }
  it { must ensure_length_of(:soft_descriptor).is_at_most(13) }

  it { must ensure_inclusion_of(:idioma).in_array(subject.class::IDIOMAS) }
end

describe Cieloz::RequisicaoTransacao::FormaPagamento do
  let(:all_flags) { Cieloz::Bandeiras::ALL }

  describe "debito validation" do
    let(:supported_flags) { subject.class::BANDEIRAS_DEBITO }

    it "validates bandeira is VISA or MASTERCARD" do
      supported_flags.each { |flag|
        subject.debito flag
        must ensure_inclusion_of(:bandeira).in_array(supported_flags)
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
      must ensure_inclusion_of(:bandeira).in_array(all_flags)
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

      subject.parcelado_adm Cieloz::Bandeiras::DISCOVER, 2
      must ensure_inclusion_of(:bandeira).in_array(supported_flags)

      subject.parcelado_loja Cieloz::Bandeiras::DISCOVER, 2
      must ensure_inclusion_of(:bandeira).in_array(supported_flags)
    end

    let(:flag) { all_flags.first }

    it "converts 1 installment to CREDITO" do
      pg = subject.parcelado_adm flag, 1
      assert_equal subject.class::CREDITO, pg.produto

      pg = subject.parcelado_loja flag, 1
      assert_equal subject.class::CREDITO, pg.produto
    end

    it "creates a PARCELADO_LOJA payment" do
      pg = subject.parcelado_loja flag, 2
      assert_equal subject.class::PARCELADO_LOJA, pg.produto
      assert_equal flag, pg.bandeira
      assert_equal 2, pg.parcelas
    end

    it "creates a PARCELADO_ADM payment" do
      pg = subject.parcelado_adm flag, 2
      assert_equal subject.class::PARCELADO_ADM, pg.produto
      assert_equal flag, pg.bandeira
      assert_equal 2, pg.parcelas
    end

    it "validates parcelas in range 1..3" do
      (1..3).each { |i|
        assert subject.parcelado_loja(flag, i).valid?, subject.errors.messages
      }
      (-10..0).each { |i|
        refute subject.parcelado_loja(flag, i).valid?, subject.errors.messages
      }
      (4..10).each { |i|
        refute subject.parcelado_loja(flag, i).valid?, subject.errors.messages
      }
      # refute not integers
      refute subject.parcelado_loja(flag, 1.234).valid?
      refute subject.parcelado_loja(flag, "abc").valid?
    end
  end
end

describe Cieloz::Base do
  it { must validate_presence_of :id }
  it { must validate_presence_of :versao }
  it { must validate_presence_of :dados_ec }
end

describe Cieloz::RequisicaoTransacao do
  it "somente autenticar requires url_retorno" do
    subject.somente_autenticar
    must validate_presence_of :url_retorno
  end

  it "autorizar somente autenticada requires url_retorno" do
    subject.autorizar_somente_autenticada
    must validate_presence_of :url_retorno
  end

  it "autorizar nao autenticada requires url_retorno" do
    subject.autorizar_nao_autenticada
    must validate_presence_of :url_retorno
  end

  it "autorizacao direta doesnt require url_retorno" do
    subject.autorizacao_direta
    wont validate_presence_of :url_retorno
  end

  it { must ensure_length_of(:url_retorno).is_at_least(1).is_at_most(1024) }

  it "doesnt validate url_retorno length for autorizacao direta" do
    subject.autorizacao_direta
    wont ensure_length_of(:url_retorno).is_at_least(1).is_at_most(1024)
  end

  it { must validate_presence_of :autorizar }
  it { must ensure_inclusion_of(:autorizar).in_array(subject.class::CODIGOS_AUTORIZACAO) }

  it "doesnt support autorizacao_direta on debito operations" do
    pg = subject.class::FormaPagamento.new
    pg.debito Cieloz::Bandeiras::VISA
    subject.forma_pagamento = pg

    subject.autorizacao_direta

    refute subject.valid?
    assert_equal "Autorizacao Direta disponivel apenas em operacoes de credito",
      subject.errors[:autorizacao].first
  end

  def refute_authentication_supported
    refute subject.valid?
    assert_equal "Bandeira nao possui programa de autenticacao",
      subject.errors[:autorizacao].first
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

  it { must validate_presence_of :capturar }
  it { must ensure_inclusion_of(:capturar).in_array(["true", "false"]) }

  it { must ensure_length_of(:campo_livre).is_at_most(128) }
end
