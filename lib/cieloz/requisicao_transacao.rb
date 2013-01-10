class Cieloz::RequisicaoTransacao < Cieloz::Base
  class DadosPortador
    include Cieloz::Helpers

    attr_accessor :numero, :nome_portador, :validade, :codigo_seguranca
    attr_reader :indicador

    def indicador
      1
    end

    def attributes
      {
        numero:           @numero,
        validade:         @validade,
        indicador:        indicador,
        codigo_seguranca: @codigo_seguranca,
        nome_portador:    @nome_portador
      }
    end

    TEST_VISA   = new numero: 4012001037141112,
      validade: 201805, codigo_seguranca: 123
    TEST_MC     = new numero: 5453010000066167,
      validade: 201805, codigo_seguranca: 123
    TEST_VISA_NO_AUTH =
      new numero: 4012001038443335,
      validade: 201805, codigo_seguranca: 123
    TEST_MC_NO_AUTH =
      new numero: 5453010000066167,
      validade: 201805, codigo_seguranca: 123
    TEST_AMEX   = new numero: 376449047333005,
      validade: 201805, codigo_seguranca: 1234
    TEST_ELO    = new numero: 6362970000457013,
      validade: 201805, codigo_seguranca: 123
    TEST_DINERS = new numero: 36490102462661,
      validade: 201805, codigo_seguranca: 123
    TEST_DISC   = new numero: 6011020000245045,
      validade: 201805, codigo_seguranca: 123
  end

  class DadosPedido
    include Cieloz::Helpers

    attr_accessor :numero, :valor, :moeda, :data_hora, :descricao, :idioma, :soft_descriptor

    def attributes
      {
        numero:           @numero,
        valor:            @valor,
        moeda:            @moeda,
        data_hora:        @data_hora,
        descricao:        @descricao,
        idioma:           @idioma,
        soft_descriptor:  @soft_descriptor
      }
    end
  end

  class FormaPagamento
    include Cieloz::Helpers

    attr_accessor :bandeira, :produto, :parcelas

    def attributes
      {
        bandeira: @bandeira,
        produto:  @produto,
        parcelas: @parcelas
      }
    end
  end

  SOMENTE_AUTENTICAR = 0

  hattr_writer :dados_portador
  hattr_writer :dados_pedido, :forma_pagamento

  attr_reader :autorizar
  attr_accessor :capturar

  def somente_autenticar
    @autorizar = SOMENTE_AUTENTICAR
  end

  def attributes
    {
      dados_ec:         @dados_ec,
      dados_portador:   @dados_portador,
      dados_pedido:     @dados_pedido,
      forma_pagamento:  @forma_pagamento,
      url_retorno:      @url_retorno,
      autorizar:        @autorizar,
      capturar:         @capturar,
      campo_livre:      @campo_livre
    }
  end
end
