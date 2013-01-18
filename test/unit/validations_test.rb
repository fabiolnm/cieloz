describe Cieloz::DadosEc do
  it { must validate_presence_of :numero }
  it { must validate_presence_of :chave }
end

describe Cieloz::RequisicaoTransacao::DadosPortador do
  it { must validate_presence_of :numero }
  it { must validate_presence_of :validade }
  it { must validate_presence_of :indicador }
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
