describe SpreeCielo::RequisicaoTransacao do
  subject { SpreeCielo::RequisicaoTransacao.new }

  let(:dir)   { File.dirname __FILE__ }
  let(:ec)    { SpreeCielo::DadosEc::TEST_MOD_CIELO }
  let(:opts)  { { root: "requisicao-transacao" } }

  it "serializes dados-ec" do
    subject.dados_ec = ec
    assert_equal expected_xml(opts) { xml_ec(dir, binding) }, subject.to_xml
  end
end
