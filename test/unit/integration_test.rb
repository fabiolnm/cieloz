describe "Integration test" do
  let(:_)         { Cieloz::RequisicaoTransacao }
  let(:ec)        { Cieloz::DadosEc::TEST_MOD_CIELO }
  let(:now)       { Time.now }

  let(:pedido)    {
    _::DadosPedido.new numero: 123, valor: 5000, moeda: 986,
      data_hora: now, descricao: "teste", idioma: "PT", soft_descriptor: "13letterstest"
  }

  let(:pagamento)  { _::FormaPagamento.new.credito "visa" }

  let(:autorizacao) {
    Cieloz::RequisicaoTransacao
    .new(dados_ec:      ec,
      dados_pedido:     pedido,
      forma_pagamento:  pagamento,
      url_retorno:      "http://ciel.oz/callback")
    .autorizacao_direta
  }

  let(:bandeira) { :visa }
  let(:portador) { _::DadosPortador::TEST::VISA }

  it "Autoriza, Consulta, Captura e Cancela" do
    autorizacao.nao_capturar_automaticamente

    txn = autorizacao.submit
    assert_equal({}, autorizacao.errors.messages)
    assert txn.criada?

    post_credit_card_on_cielo_page txn.url_autenticacao

    params = { tid: txn.tid, dados_ec: ec }

    consulta = Cieloz::RequisicaoConsulta.new params
    cst = consulta.submit
    assert_equal({}, consulta.errors.messages)
    assert cst.autorizada?

    captura = Cieloz::RequisicaoCaptura.new params
    cap = captura.submit
    assert_equal({}, captura.errors.messages)
    assert cap.capturada?

    cancelar = Cieloz::RequisicaoCancelamento.new params
    cnc = cancelar.submit
    assert_equal({}, cancelar.errors.messages)
    assert cnc.cancelada?
  end

  it "Captura Automaticamente, Consulta e Cancela" do
    autorizacao.capturar_automaticamente

    txn = autorizacao.submit
    assert_equal({}, autorizacao.errors.messages)
    assert txn.criada?

    post_credit_card_on_cielo_page txn.url_autenticacao

    params = { tid: txn.tid, dados_ec: ec }

    consulta = Cieloz::RequisicaoConsulta.new params
    cst = consulta.submit
    assert_equal({}, consulta.errors.messages)
    assert cst.capturada?

    cancelar = Cieloz::RequisicaoCancelamento.new params
    cnc = cancelar.submit
    assert_equal({}, cancelar.errors.messages)
    assert cnc.cancelada?
  end

  def post_credit_card_on_cielo_page url_cielo
    uri = URI(url_cielo)

    http = Net::HTTP.new uri.host, 443
    http.use_ssl = true

    # first, visit url_autenticacao
    http.request Net::HTTP::Get.new uri.request_uri

    # after, prepare post to verify
    uri.path = "/web/verify.cbmp"

    params = Hash[*(uri.query.split("&").collect{ |param| param.split("=") }.flatten)]
    uri.query = ""

    post = Net::HTTP::Post.new uri.path
    post.set_form_data id: params["id"],
      bandeira: bandeira,
      numeroCartao: portador.numero,
      mes: portador.validade.to_s[4..5],
      ano: portador.validade.to_s[2..3],
      codSeguranca: portador.codigo_seguranca

    res = http.request post
    assert_equal "302", res.code
    res
  end
end
