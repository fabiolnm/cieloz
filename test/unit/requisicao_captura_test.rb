# encoding: utf-8

describe Cieloz::RequisicaoCaptura do
  let(:captura) { subject.new }
  let(:dir)     { File.dirname __FILE__ }
  let(:opts)    { { root: "requisicao-captura" } }
  let(:ec)      { Cieloz::DadosEc::TEST_MOD_CIELO }

  it "serializes tid" do
    tid = 12345
    captura.tid = tid
    assert_equal expected_xml(opts) { "<tid>#{tid}</tid>" }, captura.to_xml
  end

  it "serializes dados-ec" do
    captura.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, captura.to_xml
  end

  it "serializes valor" do
    val = 123
    captura.valor = val
    assert_equal expected_xml(opts) { "<valor>#{val}</valor>" }, captura.to_xml
  end
end
