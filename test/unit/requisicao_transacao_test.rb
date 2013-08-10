describe Cieloz::RequisicaoTransacao do
  let(:_)     { subject.class }
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-transacao" } }

  let(:ec)        { Cieloz::Configuracao.credenciais }
  let(:portador)  { _::DadosPortador::TEST::VISA }

  let(:now)       { Time.now }
  let(:pedido)    {
    _::DadosPedido.new numero: 123, valor: 5000, moeda: 986,
      data_hora: now, descricao: "teste", idioma: "PT", soft_descriptor: "13letterstest"
  }
  let(:pagamento)  { _::FormaPagamento.new.credito "visa" }

  it "serializes dados-ec" do
    subject.submit # @dados_ec is set on submission
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
    let(:id)          { "1001734898090FD31001" }
    let(:tid)         { "1001734898000E531001" }
    let(:url_cielo)   {
      "https://cerecommerce.cielo.com.br/web/index.cbmp?id=608c31fb28c54bda159cd46d08766439"
    }

    before do
      portador.nome_portador = "Jose da Silva"
    end

    it "sends to test web service" do
      Cieloz::Configuracao.reset!
      subject.id              = tid
      subject.versao          = "1.2.0"
      # txn.dados_portador  = portador # buy page loja only!
      subject.dados_pedido    = pedido
      subject.forma_pagamento = pagamento
      subject.url_retorno = "http://localhost:3000/cielo/callback"
      subject.autorizacao_direta
      subject.capturar_automaticamente
      subject.campo_livre = "debug"

      res = nil
      VCR.use_cassette("requisicao_transacao_test_request_posting") do
        res = subject.submit
      end

      assert_equal({}, subject.errors.messages)
      assert_equal Cieloz::Requisicao::Transacao, res.class
      assert_equal tid,         res.tid
      assert_equal status_txn,  res.status
      assert_equal url_cielo,   res.url_autenticacao
    end
  end
end
