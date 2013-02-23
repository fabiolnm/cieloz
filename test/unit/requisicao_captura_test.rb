# encoding: utf-8

describe Cieloz::RequisicaoCaptura do
  let(:_)     { subject.class }
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-captura" } }
  let(:ec)    { Cieloz::Configuracao.credenciais }

  it "serializes tid" do
    tid = 12345
    subject.tid = tid
    assert_equal expected_xml(opts) { "<tid>#{tid}</tid>" }, subject.to_xml
  end

  it "serializes valor" do
    val = 123
    subject.valor = val
    assert_equal expected_xml(opts) { "<valor>#{val}</valor>" }, subject.to_xml
  end
end
