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
  describe "debito validation" do
    let(:supported_flags) {
      [ Cieloz::Bandeiras::VISA, Cieloz::Bandeiras::MASTER_CARD ]
    }

    it "raises error if bandeira is not VISA or MASTERCARD" do
      (Cieloz::Bandeiras::ALL - supported_flags).each { |flag|
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
end

describe Cieloz::Base do
  it { must validate_presence_of :id }
  it { must validate_presence_of :versao }
  it { must validate_presence_of :dados_ec }
end
