class SpreeCielo::RequisicaoTransacao < SpreeCielo::Base
  class DadosPortador
    include SpreeCielo::Helpers

    attr_accessor :numero, :validade, :codigo_seguranca
    attr_reader :indicador

    def indicador!
      @indicador = 1
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

  hattr_writer(:dados_portador) { |p| p.indicador! }
end
