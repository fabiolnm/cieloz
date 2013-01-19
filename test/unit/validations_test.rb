describe Cieloz::DadosEc do
  it { must validate_presence_of :numero }
  it { must validate_presence_of :chave }
end

describe Cieloz::RequisicaoTransacao::DadosPortador do
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

  it "validates validade as yyyymm" do
    yyyy = 2013
    (1..12).each { |i|
      mm = '%02d' % i
      must validate_format_of(:validade).with("#{yyyy}#{mm}")
    }
    ((13..19).to_a + (20..100).step(10).to_a).each { |i|
      mm = '%02d' % (i % 100)
      must validate_format_of(:validade).not_with("#{yyyy}#{mm}")
    }
    must validate_format_of(:validade).not_with("199911")
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
  it { must validate_presence_of :valor }
  it { must validate_presence_of :moeda }
  it { must validate_presence_of :data_hora }
end

describe Cieloz::RequisicaoTransacao::FormaPagamento do
  let(:all_flags) { Cieloz::Bandeiras::ALL }

  describe "debito validation" do
    let(:supported_flags) {
      [ Cieloz::Bandeiras::VISA, Cieloz::Bandeiras::MASTER_CARD ]
    }

    it "raises error if bandeira is not VISA or MASTERCARD" do
      (all_flags - supported_flags).each { |flag|
        assert_raises(RuntimeError,
          /Operacao disponivel apenas para VISA e MasterCard/) {
          subject.debito flag
        }
      }
    end

    it "accepts payment for VISA or MASTERCARD" do
      supported_flags.each { |flag|
        subject.debito flag
        assert_equal subject.class::DEBITO, subject.produto
        assert_equal flag,  subject.bandeira
        assert_equal 1,     subject.parcelas
      }
    end
  end

  it "validates credito" do
    all_flags.each { |flag|
      subject.credito flag
      assert_equal subject.class::CREDITO, subject.produto
      assert_equal flag,  subject.bandeira
      assert_equal 1,     subject.parcelas
    }
  end

  describe "validates parcelamento" do
    it "is not supported by DISCOVER" do
      assert_raises(RuntimeError, /Nao suportado pela bandeira DISCOVER/) {
        subject.parcelado_adm Cieloz::Bandeiras::DISCOVER, 1
      }
      assert_raises(RuntimeError, /Nao suportado pela bandeira DISCOVER/) {
        subject.parcelado_loja Cieloz::Bandeiras::DISCOVER, 1
      }
      # nothing is expected to be raised for other flags
      (all_flags - [Cieloz::Bandeiras::DISCOVER]).each { |flag|
        refute_nil subject.parcelado_adm flag, 1
        refute_nil subject.parcelado_loja flag, 1
      }
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
        assert subject.parcelado_loja(flag, i).valid?
      }
      (-10..0).each { |i|
        refute subject.parcelado_loja(flag, i).valid?
      }
      (4..10).each { |i|
        refute subject.parcelado_loja(flag, i).valid?
      }
      # refute not integers
      refute subject.parcelado_loja(flag, 1.234).valid?
      refute subject.parcelado_loja(flag, "abc").valid?
    end

    it "requires an operation to be called" do
      refute subject.valid?
      assert subject.errors.has_key? :estado_invalido
    end
  end
end

describe Cieloz::Base do
  it { must validate_presence_of :id }
  it { must validate_presence_of :versao }
  it { must validate_presence_of :dados_ec }
end
