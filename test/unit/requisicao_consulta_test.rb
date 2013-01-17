# encoding: utf-8

describe Cieloz::RequisicaoConsulta do
  let(:consulta)  { subject.new }
  let(:dir)       { File.dirname __FILE__ }
  let(:opts)      { { root: "requisicao-consulta" } }
  let(:ec)        { Cieloz::DadosEc::TEST_MOD_CIELO }

  it "serializes tid" do
    tid = 12345
    consulta.tid = tid
    assert_equal expected_xml(opts) { "<tid>#{tid}</tid>" }, consulta.to_xml
  end

  it "serializes dados-ec" do
    consulta.dados_ec = ec
    assert_equal expected_xml(opts) { xml_for :ec, dir, binding }, consulta.to_xml
  end
end
