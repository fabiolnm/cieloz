class Cieloz::RequisicaoTransacao
  class FormaPagamento
    DEBITO          = "A"
    CREDITO         = 1
    PARCELADO_LOJA  = 2
    PARCELADO_ADM   = 3

    BANDEIRAS_DEBITO = [ Cieloz::Bandeiras::VISA, Cieloz::Bandeiras::MASTER_CARD ]
    SUPORTAM_AUTENTICACAO = BANDEIRAS_DEBITO

    BANDEIRAS_PARCELAMENTO = Cieloz::Bandeiras::ALL - [Cieloz::Bandeiras::DISCOVER]

    include Cieloz::Helpers

    attr_reader :bandeira, :produto, :parcelas

    validates :bandeira, :produto, :parcelas, presence: true

    validates :parcelas, numericality: {
      only_integer: true, greater_than: 0, less_than_or_equal_to: 3
    }

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

    def parcelado_loja bandeira, parcelas
      parcelar bandeira, parcelas, PARCELADO_LOJA
    end

    def parcelado_adm bandeira, parcelas
      parcelar bandeira, parcelas, PARCELADO_ADM
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
