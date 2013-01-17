# encoding: utf-8

describe Cieloz::RequisicaoAutorizacaoTid do
  let(:auth)  { subject.new }
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-autorizacao-tid" } }
  let(:ec)    { Cieloz::DadosEc::TEST_MOD_CIELO }

  it "serializes tid" do
    tid = 12345
    auth.tid = tid
    assert_equal expected_xml(opts) { "<tid>#{tid}</tid>" }, auth.to_xml
  end

  it "serializes dados-ec" do
    auth.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, auth.to_xml
  end
end
