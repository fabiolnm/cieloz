class Cieloz::RequisicaoTransacao
  class FormaPagamento
    DEBITO          = "A"
    CREDITO         = 1
    PARCELADO_LOJA  = 2
    PARCELADO_ADM   = 3

    BANDEIRAS_DEBITO = [ Cieloz::Bandeiras::VISA, Cieloz::Bandeiras::MASTERCARD ]
    SUPORTAM_AUTENTICACAO = BANDEIRAS_DEBITO

    BANDEIRAS_PARCELAMENTO = Cieloz::Bandeiras::ALL - [Cieloz::Bandeiras::DISCOVER]

    include Cieloz::Helpers

    attr_reader :bandeira, :produto, :parcelas

    validates :bandeira, :produto, :parcelas, presence: true

    validates :parcelas, numericality: {
      only_integer: true, greater_than: 0,
      less_than_or_equal_to: Cieloz::Configuracao.max_parcelas
    }, if: "produto == PARCELADO_LOJA"

    validates :parcelas, numericality: {
      only_integer: true,
      greater_than: Cieloz::Configuracao.max_parcelas,
      less_than_or_equal_to: Cieloz::Configuracao.max_adm_parcelas
    }, if: "produto == PARCELADO_ADM"

    validates :bandeira, inclusion: { in: BANDEIRAS_DEBITO }, if: "@produto == DEBITO"
    validates :bandeira, inclusion: { in: Cieloz::Bandeiras::ALL }, if: "@produto == CREDITO"
    validates :bandeira, inclusion: { in: BANDEIRAS_PARCELAMENTO },
      if: "[ PARCELADO_LOJA, PARCELADO_ADM ].include? @produto"

    def attributes
      {
        bandeira: @bandeira,
        produto:  @produto,
        parcelas: @parcelas
      }
    end

    def suporta_autenticacao?
      SUPORTAM_AUTENTICACAO.include? @bandeira
    end

    def debito bandeira
      set_attrs bandeira, DEBITO, 1
    end

    def debito?
      @produto == DEBITO
    end

    def credito bandeira
      set_attrs bandeira, CREDITO, 1
    end

    def parcelado bandeira, parcelas
      max, max_adm = Cieloz::Configuracao.max_parcelas, Cieloz::Configuracao.max_adm_parcelas
      produto = case parcelas
                when (1..max)         then PARCELADO_LOJA
                when (max+1..max_adm) then PARCELADO_ADM
                end
      parcelar bandeira, parcelas, produto
    end

    # Utility methods that deduces what authorization method should be performed
    def operacao opr, parcelas
      bandeira, @metodo_autorizacao = Cieloz::Bandeiras.operacao opr
      parcelado bandeira, parcelas
    end

    def metodo_autorizacao
      @metodo_autorizacao || :autorizacao_direta
    end

    private
    def set_attrs bandeira, produto, parcelas
      @bandeira = bandeira
      @produto  = produto
      @parcelas = parcelas
      self
    end

    def parcelar bandeira, parcelas, produto
      if parcelas == 1
        credito bandeira
      else
        set_attrs bandeira, produto, parcelas
      end
    end
  end
end
