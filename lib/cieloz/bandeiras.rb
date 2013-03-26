module Cieloz
  module Bandeiras
    ALL = %w(amex diners discover elo mastercard visa)
    AMEX, DINERS, DISCOVER, ELO, MASTERCARD, VISA = ALL

    def self.operacao produto
      produto = produto.to_s
      case produto
      when 'mastercard_securecode'
        [MASTERCARD,      :autorizar_somente_autenticada]
      when 'verified_by_visa'
        [VISA,            :autorizar_somente_autenticada]
      else
        if ALL.include? produto
          [produto,  :autorizacao_direta]
        else
          [nil, nil]
        end
      end
    end
  end
end
