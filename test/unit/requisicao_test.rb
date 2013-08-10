# encoding: utf-8

describe Cieloz::Requisicao do
  let(:_)       { subject.class }
  let(:id)      { "1" }
  let(:versao)  { "1.2.0" }
  let(:opts)    { { root: "requisicao", id: id, versao: versao } }

  let(:dir)     { File.dirname __FILE__ }

  before do
    subject.id = id
    subject.versao = versao
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
    let(:ec)  { Cieloz::Configuracao.credenciais }
    let(:xml) { expected_xml(opts) { xml_for :ec, dir, binding } }

    it "serializes" do
      VCR.use_cassette("requisicao_test_complex_attributes") do
        subject.submit # @dados_ec is set on submission
        assert_equal xml, subject.to_xml
      end
    end
  end

  describe "request posting" do
    it "sends to test web service" do
      VCR.use_cassette("requisicao_test_request_posting") do
        res = subject.submit
        assert_equal({}, subject.errors.messages)
        refute_nil res.codigo
        refute_nil res.mensagem
      end
    end
  end
end
