module Cieloz
  class Requisicao
    class Transacao < Resposta
      attr_accessor :tid, :status, :url_autenticacao

      def success?
        true
      end

      STATUSES = {
        "0"   => :criada,
        "1"   => :em_andamento,
        "2"   => :autenticada,
        "3"   => :nao_autenticada,
        "4"   => :autorizada,
        "5"   => :nao_autorizada,
        "6"   => :capturada,
        "9"   => :cancelada,
        "10"  => :em_autenticacao,
        "12"  => :em_cancelamento
      }

      STATUSES.each do |_, status_type|
        define_method "#{status_type}?" do
          STATUSES[status] == status_type
        end
      end
    end
  end
end
