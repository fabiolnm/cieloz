module Cieloz
  module Bandeiras
    ALL = %w(amex diners discover elo mastercard visa)
    AMEX, DINERS, DISCOVER, ELO, MASTERCARD, VISA = ALL

    def self.operacao produto
      produto = produto.to_s
      case produto
      when 'mastercard_securecode'
        :autorizar_somente_autenticada
      when 'verified_by_visa'
        :autorizar_somente_autenticada
      else
        :autorizacao_direta if ALL.include? produto
      end
    end
  end
end
