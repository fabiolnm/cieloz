module Cieloz
  module Bandeiras
    ALL = %w(amex diners discover elo mastercard visa)
    AMEX, DINERS, DISCOVER, ELO, MASTERCARD, VISA = ALL

    def self.operacao produto
      case produto.to_sym
      when :mastercard_securecode
        [MASTERCARD,      :autorizar_somente_autenticada]
      when :verified_by_visa
        [VISA,            :autorizar_somente_autenticada]
      else
        if ALL.include?(produto)
          [produto.to_s,  :autorizacao_direta]
        else
          raise "product_not_supported"
        end
      end
    end
  end
end
