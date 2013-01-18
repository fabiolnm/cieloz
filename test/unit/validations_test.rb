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
  it { must validate_presence_of :bandeira }
  it { must validate_presence_of :produto }
  it { must validate_presence_of :parcelas }
end

describe Cieloz::Base do
  it { must validate_presence_of :id }
  it { must validate_presence_of :versao }
  it { must validate_presence_of :dados_ec }
end
