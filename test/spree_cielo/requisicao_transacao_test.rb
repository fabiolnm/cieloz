describe SpreeCielo::RequisicaoTransacao do
  let(:txn)   { subject.new }
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-transacao" } }

  let(:ec)        { SpreeCielo::DadosEc::TEST_MOD_CIELO }
  let(:portador)  { subject::DadosPortador::TEST_VISA }

  let(:now)       { Time.now.strftime "%Y-%m-%dT%H:%M:%S" }
  let(:pedido)    {
    subject::DadosPedido.new numero: 123, valor: 5000, moeda: 986,
      data_hora: now, descricao: "teste", idioma: "PT", soft_descriptor: "soft test"
  }
  let(:pagamento)  { subject::FormaPagamento.new bandeira: "visa", produto: 1, parcelas: 1 }

  it "serializes dados-ec" do
    txn.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, txn.to_xml
  end

  it "serializes dados-portador" do
    txn.dados_portador = portador
    assert_equal expected_xml(opts) { xml_for :portador, dir, binding }, txn.to_xml
  end

  it "serializes dados-pedido" do
    txn.dados_pedido = pedido
    assert_equal expected_xml(opts) { xml_for :pedido, dir, binding }, txn.to_xml
  end

  it "serializes forma-pagamento" do
    txn.forma_pagamento = pagamento
    assert_equal expected_xml(opts) { xml_for :pagamento, dir, binding }, txn.to_xml
  end

  it "serializes simple attributes" do
    txn.url_retorno = "http://callback.acti.on"
    txn.somente_autenticar
    txn.capturar = true
    txn.campo_livre = "I want to break free"
    assert_equal expected_xml(opts) { xml_for :simple_attrs, dir, binding }, txn.to_xml
  end
end
