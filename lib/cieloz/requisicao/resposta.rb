module Cieloz
  class Requisicao
    class Resposta
      include ActiveModel::Serializers::Xml
      include Helpers

      STATUSES = {
        "0" => :criada,
        "1" => :em_andamento,
        "2" => :autenticada,
        "3" => :nao_autenticada,
        "4" => :autorizada,
        "5" => :nao_autorizada,
        "6" => :capturada,
        "9" => :cancelada,
        "10" => :em_autenticacao,
        "12" => :em_cancelamento
      }

      attr_reader :xml

      def self.from xml
        obj = new
        begin
          obj = obj.from_xml xml
        rescue
          # makes it resilient to bad responses,
          # allowing them to be logged
        end
        obj.instance_variable_set :@xml, xml
        obj
      end

      STATUSES.each do |_, status_type|
        define_method "#{status_type}?" do
          success? and STATUSES[status] == status_type
        end
      end
    end
  end
end
