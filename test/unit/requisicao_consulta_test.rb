# encoding: utf-8

describe Cieloz::RequisicaoConsulta do
  let(:_)     { subject.class }
  let(:dir)   { File.dirname __FILE__ }
  let(:opts)  { { root: "requisicao-consulta" } }
  let(:ec)    { Cieloz::Configuracao.credenciais }

  it "serializes tid" do
    tid = 12345
    subject.tid = tid
    assert_equal expected_xml(opts) { "<tid>#{tid}</tid>" }, subject.to_xml
  end
end
