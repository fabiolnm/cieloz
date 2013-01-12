require 'net/http'
require 'builder'

class Cieloz::Base
  include Cieloz::Helpers

  attr_accessor :id, :versao, :campo_livre, :url_retorno
  attr_reader :dados_ec
  hattr_writer :dados_ec

  def attributes
    {
      dados_ec:     @dados_ec,
      url_retorno:  @url_retorno,
      campo_livre:  @campo_livre
    }
  end

  def to_xml
    x = Builder::XmlMarkup.new
    x.instruct!
    name = self.class.name.demodulize
    x.tag! name.underscore.dasherize, id: id, versao: versao do
      attributes.each { |attr, value|
        next if value.nil?

        unless value.respond_to? :attributes
          x.tag! dash(attr), value
        else
          x.tag! dash(attr) do
            value.attributes.each do |attr, value|
              x.tag!(dash(attr), value) unless value.nil?
            end
          end
        end
      }
    end
  end

  def submit host=Cieloz::TEST_HOST
    http = Net::HTTP.new host, 443
    http.use_ssl = true
    http.open_timeout = 5 * 1000
    http.read_timeout = 30 * 1000

    self.id     = SecureRandom.uuid if id.blank?
    self.versao = "1.2.0"           if versao.blank?

    res = http.post Cieloz::WS_PATH, "mensagem=#{to_xml}"
    parse res.body
  end

  def parse xml
    root = Nokogiri::XML(xml).root
    response_class =  case root.name
    when 'erro'       then Cieloz::Erro
    when 'transacao'  then Cieloz::Transacao
    end
    response_class.new.from_xml xml
  end

  private
  def dash value
    value.to_s.gsub("@", "").dasherize
  end
end
