# encoding: utf-8

describe Cieloz::RequisicaoCancelamento do
  let(:cancela) { subject.new }
  let(:dir)     { File.dirname __FILE__ }
  let(:opts)    { { root: "requisicao-cancelamento" } }
  let(:ec)      { Cieloz::DadosEc::TEST_MOD_CIELO }

  it "serializes tid" do
    tid = 12345
    cancela.tid = tid
    assert_equal expected_xml(opts) { "<tid>#{tid}</tid>" }, cancela.to_xml
  end

  it "serializes dados-ec" do
    cancela.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, cancela.to_xml
  end

  it "serializes valor" do
    val = 123
    cancela.valor = val
    assert_equal expected_xml(opts) { "<valor>#{val}</valor>" }, cancela.to_xml
  end
end
