# encoding: utf-8

describe Cieloz::RequisicaoCaptura do
  let(:dir)     { File.dirname __FILE__ }
  let(:opts)    { { root: "requisicao-captura" } }
  let(:ec)      { Cieloz::DadosEc::TEST_MOD_CIELO }

  it "serializes tid" do
    tid = 12345
    subject.tid = tid
    assert_equal expected_xml(opts) { "<tid>#{tid}</tid>" }, subject.to_xml
  end

  it "serializes dados-ec" do
    subject.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, subject.to_xml
  end

  it "serializes valor" do
    val = 123
    subject.valor = val
    assert_equal expected_xml(opts) { "<valor>#{val}</valor>" }, subject.to_xml
  end
end
