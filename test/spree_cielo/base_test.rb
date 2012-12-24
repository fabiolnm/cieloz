# encoding: utf-8

describe SpreeCielo::Base do
  subject { SpreeCielo::Base.new }

  let(:id)          { "1" }
  let(:versao)      { "1.2.0" }
  let(:xml_header)  { '<?xml version="1.0" encoding="UTF-8"?>' }

  before do
    subject.id = id
    subject.versao = versao
  end

  def expected_xml opts={}
    opts.reverse_merge! root: "base", id: id, versao: versao
    root, id, versao = opts[:root], opts[:id], opts[:versao]

    res = xml_header
    res << %|<#{root} id="#{id}" versao="#{versao}">| +
            "#{yield if block_given?}</#{root}>"
  end

  it "serializes" do
    assert_equal expected_xml, subject.to_xml
  end

  describe "value attributes" do
    it "serializes" do
      campo_livre = "Informações Extras"
      subject.campo_livre = campo_livre

      xml = expected_xml { "<campo-livre>#{campo_livre}</campo-livre>" }
      assert_equal xml, subject.to_xml
    end

    it "ignores nils" do
      subject.campo_livre = nil
      assert_equal expected_xml, subject.to_xml
    end
  end

  describe "complex attributes" do
    let(:numero)      { 123 }
    let(:chave)       { "M3str4" }
    let(:attributes)  { { numero: numero, chave: chave } }
    let(:ec)          {
      ec = MiniTest::Mock.new
      ec.expect :nil?, false
      ec.expect :instance_variables, attributes.keys
      attributes.each { |k,v|
        ec.expect :instance_variable_get, v, ["@#{k}"]
      }
      ec
    }
    let(:xml) {
      expected_xml {
        "<dados-ec>" +
        "<numero>#{numero}</numero>" +
        "<chave>#{chave}</chave>" +
        "</dados-ec>"
      }
    }

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
    require 'erb'
    require 'fakeweb'

    let(:err) { "101" }
    let(:msg) { "Invalid" }
    let(:dir) { File.dirname __FILE__ }
    let(:template) { File.join dir, "erro.xml" }
    let(:fake_response) { ERB.new(File.read(template)).result(binding) }

    before do
      FakeWeb.register_uri :post, SpreeCielo.test_url, body: fake_response
    end

    it "sends to test web service" do
      erro = subject.send
      assert_equal err, erro.codigo
      assert_equal "Invalid", erro.mensagem
    end
  end
end
