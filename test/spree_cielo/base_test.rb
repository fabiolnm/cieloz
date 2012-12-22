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
    unless block_given?
      res << %|<#{root} id="#{id}" versao="#{versao}"/>|
    else
      res << %|<#{root} id="#{id}" versao="#{versao}">#{yield}</#{root}>|
    end
  end

  it "serializes" do
    assert_equal expected_xml, subject.to_xml
  end
end
