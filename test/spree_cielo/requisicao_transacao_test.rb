describe Cieloz::RequisicaoTransacao do
  let(:txn)   { subject.new }
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-transacao" } }

  let(:ec)        { Cieloz::DadosEc::TEST_MOD_CIELO }
  let(:portador)  { subject::DadosPortador::TEST_VISA }

  let(:now)       { Time.now.strftime "%Y-%m-%dT%H:%M:%S" }
  let(:pedido)    {
    subject::DadosPedido.new numero: 123, valor: 5000, moeda: 986,
      data_hora: now, descricao: "teste", idioma: "PT", soft_descriptor: "13letterstest"
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

  describe "request posting" do
    let(:status_txn)  { "0" }
    let(:tid)         { "1001734898090FD31001" }
    let(:url_cielo)   {
      "https://qasecommerce.cielo.com.br/web/index.cbmp?id=690ef010bfa77778f23da1a982d5d4cc"
    }
    let(:fake_response) { render_template dir, "transacao.xml", binding }

    before do
      portador.nome_portador = "Jose da Silva"
      FakeWeb.register_uri :post, Cieloz.test_url, body: fake_response
    end

    after do
      FakeWeb.clean_registry
    end

    it "sends to test web service" do
      txn.id              = SecureRandom.uuid
      txn.versao          = "1.2.0"
      txn.dados_ec        = ec
      # txn.dados_portador  = portador # buy page loja only!
      txn.dados_pedido    = pedido
      txn.forma_pagamento = pagamento
      txn.url_retorno = "http://localhost:3000/cielo/callback"
      txn.somente_autenticar
      txn.capturar = true
      txn.campo_livre = "debug"

      res = txn.send
      assert_equal Cieloz::Transacao, res.class
      assert_equal tid,         res.tid
      assert_equal status_txn,  res.status
      assert_equal url_cielo,   res.url_autenticacao
    end
  end
end
