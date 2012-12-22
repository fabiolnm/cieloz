describe SpreeCielo::Base do
  subject { SpreeCielo::Base.new }

  it "serializes" do
    subject.id = 1
    subject.versao = "1.2.0"
    expected_xml =
      %|<?xml version="1.0" encoding="UTF-8"?>| +
      %|<base id="1" versao="1.2.0"/>|
    assert_equal expected_xml, subject.to_xml
  end
end
