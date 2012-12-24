describe SpreeCielo::RequisicaoTransacao do
  let(:txn)   { subject.new }
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-transacao" } }

  let(:ec)        { SpreeCielo::DadosEc::TEST_MOD_CIELO }
  let(:portador)  { subject::DadosPortador::TEST_VISA }

  it "serializes dados-ec" do
    txn.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, txn.to_xml
  end

  it "serializes dados-portador" do
    txn.dados_portador = portador
    assert_equal expected_xml(opts) { xml_for :portador, dir, binding }, txn.to_xml
  end
end
