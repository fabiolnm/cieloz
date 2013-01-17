describe Cieloz::RequisicaoTransacao do
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-transacao" } }

  let(:ec)        { Cieloz::DadosEc::TEST_MOD_CIELO }
  let(:portador)  { subject.class::DadosPortador::TEST_VISA }

  let(:now)       { Time.now }
  let(:pedido)    {
    subject.class::DadosPedido.new numero: 123, valor: 5000, moeda: 986,
      data_hora: now, descricao: "teste", idioma: "PT", soft_descriptor: "13letterstest"
  }
  let(:pagamento)  {
    pg = subject.class::FormaPagamento.new bandeira: "visa"
    pg.credito_a_vista
    pg
  }

  it "serializes dados-ec" do
    subject.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, subject.to_xml
  end

  it "serializes dados-portador" do
    subject.dados_portador = portador
    assert_equal expected_xml(opts) { xml_for :portador, dir, binding }, subject.to_xml
  end

  it "serializes dados-pedido" do
    subject.dados_pedido = pedido
    assert_equal expected_xml(opts) { xml_for :pedido, dir, binding }, subject.to_xml
  end

  it "serializes forma-pagamento" do
    subject.forma_pagamento = pagamento
    assert_equal expected_xml(opts) { xml_for :pagamento, dir, binding }, subject.to_xml
  end

  it "serializes simple attributes" do
    subject.url_retorno = "http://callback.acti.on"
    subject.autorizacao_direta
    subject.capturar_automaticamente
    subject.campo_livre = "I want to break free"
    assert_equal expected_xml(opts) { xml_for :simple_attrs, dir, binding }, subject.to_xml
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
      subject.id              = SecureRandom.uuid
      subject.versao          = "1.2.0"
      subject.dados_ec        = ec
      # txn.dados_portador  = portador # buy page loja only!
      subject.dados_pedido    = pedido
      subject.forma_pagamento = pagamento
      subject.url_retorno = "http://localhost:3000/cielo/callback"
      subject.autorizacao_direta
      subject.capturar_automaticamente
      subject.campo_livre = "debug"

      res = subject.submit
      assert_equal Cieloz::Transacao, res.class
      assert_equal tid,         res.tid
      assert_equal status_txn,  res.status
      assert_equal url_cielo,   res.url_autenticacao
    end
  end
end
