module Cieloz
  class RequisicaoTid < Requisicao
    module ClassMethods
      def map source, opts={}
        tid = attrs_from source, opts, :tid
        new source: source, opts: opts, tid: tid
      end
    end

    def self.inherited(target)
      target.extend ClassMethods
    end

    attr_accessor :tid

    def attributes
      { tid: @tid, dados_ec: @dados_ec }
    end
  end

  class RequisicaoTidValor < RequisicaoTid
    module ClassMethods
      def map source, opts={}
        tid, valor = attrs_from source, opts, :tid, :valor
        new source: source, opts: opts, tid: tid, valor: valor
      end
    end

    def self.inherited(target)
      target.extend ClassMethods
    end

    attr_reader :valor

    def valor=(val)
      @valor = (val.nil? or val.integer?) ? val : (val * 100).round
    end

    def attributes
      { tid: @tid, dados_ec: @dados_ec, valor: @valor }
    end
  end

  class RequisicaoConsulta < RequisicaoTid ; end
  class RequisicaoAutorizacaoTid < RequisicaoTid ; end

  class RequisicaoCaptura < RequisicaoTidValor ; end
  class RequisicaoCancelamento < RequisicaoTidValor ; end
end
