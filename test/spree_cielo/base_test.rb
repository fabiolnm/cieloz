# encoding: utf-8

describe SpreeCielo::Base do
  let(:base)    { subject.new }
  let(:id)      { "1" }
  let(:versao)  { "1.2.0" }
  let(:opts)    { { root: "base", id: id, versao: versao } }

  let(:dir)     { File.dirname __FILE__ }

  before do
    base.id = id
    base.versao = versao
  end

  it "serializes" do
    assert_equal expected_xml(opts), base.to_xml
  end

  describe "value attributes" do
    it "serializes" do
      campo_livre = "Informações Extras"
      base.campo_livre = campo_livre

      xml = expected_xml(opts) { "<campo-livre>#{campo_livre}</campo-livre>" }
      assert_equal xml, base.to_xml
    end

    it "ignores nils" do
      base.campo_livre = nil
      assert_equal expected_xml(opts), base.to_xml
    end
  end

  describe "complex attributes" do
    let(:attributes)  { { numero: 123, chave: "M3str4" } }
    let(:ec)          { SpreeCielo::DadosEc.new attributes }
    let(:xml) { expected_xml(opts) { xml_for :ec, dir, binding } }

    it "serializes" do
      base.dados_ec = ec
      assert_equal xml, base.to_xml
    end

    it "ignores nils" do
      attributes.merge! ignore_me: nil
      base.dados_ec = ec
      assert_equal xml, base.to_xml
    end
  end

  describe "request posting" do
    let(:err) { "101" }
    let(:msg) { "Invalid" }
    let(:fake_response) { render_template dir, "erro.xml", binding }

    before do
      FakeWeb.register_uri :post, SpreeCielo.test_url, body: fake_response
    end

    it "sends to test web service" do
      erro = base.send
      assert_equal err, erro.codigo
      assert_equal "Invalid", erro.mensagem
    end

    after do
      FakeWeb.clean_registry
    end
  end
end
