module Cieloz
  class Requisicao
    class Resposta
      include ActiveModel::Serializers::Xml
      include Helpers

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
    end
  end
end
