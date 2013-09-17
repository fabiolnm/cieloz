module Cieloz
  module Builder
    def portador source, opts={}
      RequisicaoTransacao::DadosPortador.map source, opts
    end

    def pedido source, opts={}
      RequisicaoTransacao::DadosPedido.map source, opts
    end

    def debito source, opts={}
      RequisicaoTransacao::FormaPagamento.map_debito source, opts
    end

    def credito source, opts={}
      RequisicaoTransacao::FormaPagamento.map_credito source, opts
    end

    def parcelado source, opts={}
      RequisicaoTransacao::FormaPagamento.map_parcelado source, opts
    end

    def transacao source, opts={}
      RequisicaoTransacao.map source, opts
    end

    def consulta source, opts={}
      RequisicaoConsulta.map source, opts
    end

    def captura source, opts={}
      RequisicaoCaptura.map source, opts
    end

    def cancelamento source, opts={}
      RequisicaoCancelamento.map source, opts
    end
  end

  extend Builder
end
