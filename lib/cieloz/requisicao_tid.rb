module Cieloz
  class RequisicaoTid < Requisicao
    attr_accessor :tid

    def attributes
      { tid: @tid, dados_ec: @dados_ec }
    end
  end

  class RequisicaoTidValor < RequisicaoTid
    attr_accessor :valor

    def attributes
      { tid: @tid, dados_ec: @dados_ec, valor: @valor }
    end
  end

  class RequisicaoConsulta < RequisicaoTid ; end
  class RequisicaoAutorizacaoTid < RequisicaoTid ; end

  class RequisicaoCaptura < RequisicaoTidValor ; end
  class RequisicaoCancelamento < RequisicaoTidValor ; end
end
