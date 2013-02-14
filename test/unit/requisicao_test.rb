# encoding: utf-8

describe Cieloz::Requisicao do
  let(:id)      { "1" }
  let(:versao)  { "1.2.0" }
  let(:opts)    { { root: "requisicao", id: id, versao: versao } }

  let(:dir)     { File.dirname __FILE__ }

  before do
    subject.id = id
    subject.versao = versao
  end

  it "serializes" do
    assert_equal expected_xml(opts), subject.to_xml
  end

  describe "value attributes" do
    before do
      subject.class_eval do
        attr_accessor :foo

        def attributes
          { foo: @foo }
        end
      end
    end

    let(:foo) { "Informações Extras" }

    it "serializes" do
      subject.foo = foo

      xml = expected_xml(opts) { "<foo>#{foo}</foo>" }
      assert_equal xml, subject.to_xml
    end

    it "ignores nils" do
      subject.foo = nil
      assert_equal expected_xml(opts), subject.to_xml
    end
  end

  describe "complex attributes" do
    let(:attributes)  { { numero: 123, chave: "M3str4" } }
    let(:ec)          { Cieloz::DadosEc.new attributes }
    let(:xml) { expected_xml(opts) { xml_for :ec, dir, binding } }

    it "serializes" do
      subject.dados_ec = ec
      assert_equal xml, subject.to_xml
    end

    it "ignores nils" do
      attributes.merge! ignore_me: nil
      subject.dados_ec = ec
      assert_equal xml, subject.to_xml
    end
  end

  describe "request posting" do
    let(:err) { "101" }
    let(:msg) { "Invalid" }
    let(:fake_response) { render_template dir, "erro.xml", binding }

    before do
      FakeWeb.register_uri :post, Cieloz::Homologacao.url, body: fake_response
    end

    it "sends to test web service" do
      subject.dados_ec = Cieloz::DadosEc.new Cieloz::Homologacao::Credenciais::CIELO
      erro = subject.submit
      assert_equal({}, subject.errors.messages)
      assert_equal err, erro.codigo
      assert_equal "Invalid", erro.mensagem
    end

    after do
      FakeWeb.clean_registry
    end
  end
end
