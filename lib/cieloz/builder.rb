module Cieloz
  module Builder
    def portador source, opts={}
      num, val, cod, nome = attrs_from source, opts,
        :numero, :validade, :codigo_seguranca, :nome_portador

      RequisicaoTransacao::DadosPortador.new numero: num,
        validade: val, codigo_seguranca: cod, nome_portador: nome
    end

    def pedido source, opts={}
      mappings = attrs_from source, opts, :numero, :valor,
        :descricao, :data_hora, :moeda, :idioma, :soft_descriptor

      num, val, desc, time, cur, lang, soft = mappings
      val = (val * 100).round unless val.nil? or val.integer?

      time  ||= Time.now
      cur   ||= Cieloz::Configuracao.moeda
      lang  ||= Cieloz::Configuracao.idioma
      soft  ||= Cieloz::Configuracao.soft_descriptor

      RequisicaoTransacao::DadosPedido.new data_hora: time,
        numero: num, valor: val, moeda: cur, idioma: lang,
        descricao: desc, soft_descriptor: soft
    end

    def pagamento source, opts={}
      opr, parcelas = attrs_from source, opts, :operacao, :parcelas
      RequisicaoTransacao::FormaPagamento.new.operacao opr, parcelas
    end

    def transacao source, opts={}
      portador, pedido, pagamento, url, capturar, campo_livre =
        attrs_from source, opts, :dados_portador, :dados_pedido,
        :forma_pagamento, :url_retorno, :capturar, :campo_livre

      url ||= Cieloz::Configuracao.url_retorno

      txn = RequisicaoTransacao.new dados_portador: portador,
        dados_pedido: pedido, forma_pagamento: pagamento,
        campo_livre: campo_livre, url_retorno: url,
        dados_ec: Cieloz::Configuracao.credenciais

      capturar ||= Cieloz::Configuracao.captura_automatica

      case capturar.to_s
      when 'true' then txn.capturar_automaticamente
      else        txn.nao_capturar_automaticamente
      end

      txn.send pagamento.metodo_autorizacao

      txn
    end

    private
    def attrs_from source, opts, *keys
      keys.map { |k|
        value_or_attr_name = opts[k] || k
        if value_or_attr_name.is_a? Symbol
          source.send value_or_attr_name if source.respond_to? value_or_attr_name
        else
          value_or_attr_name
        end
      }
    end
  end

  extend Builder
end
