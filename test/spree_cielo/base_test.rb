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

  let(:ec) { MiniTest::Mock.new }

  it "seralizes attributes" do
    numero, chave = 123, "M3str4"
    attributes = { numero: numero, chave: chave }

    ec.expect :instance_variables, attributes.keys
    attributes.each { |k,v|
      ec.expect :instance_variable_get, v, ["@#{k}"]
    }

    subject.dados_ec = ec

    xml = expected_xml {
      "<dados-ec>" +
        "<numero>#{numero}</numero>" +
        "<chave>#{chave}</chave>" +
      "</dados-ec>"
    }
    assert_equal xml, subject.to_xml
  end

  it "serializes value attributes" do
    campo_livre = "Informações Extras"
    subject.campo_livre = campo_livre

    xml = expected_xml { "<campo-livre>#{campo_livre}</campo-livre>" }
    assert_equal xml, subject.to_xml
  end
end
