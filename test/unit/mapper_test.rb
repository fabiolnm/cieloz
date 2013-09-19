describe Cieloz::Helpers do
  class Source
    include ActiveModel::Validations

    def number ; nil end
  end

  let(:order) { Source.new }
  let(:pedido) { Cieloz.pedido order, numero: :number, valor: :value }

  it "recognizes error for attribute" do
    pedido.wont_be :valid?
    errors = order.errors.messages[:number]
    errors.wont_be_empty
    errors.must_equal pedido.errors[:numero]
  end

  let(:txn) { Source.new }
  let(:transacao) { Cieloz.transacao txn, dados_pedido: pedido }

  it "recognizes errors for dependent mappers" do
    transacao.wont_be :valid?
    errors = order.errors.messages[:number]
    errors.wont_be_empty
    errors.must_equal pedido.errors[:numero]
  end

  it "appends non-dependent errors to root aggregate base" do
    transacao.wont_be :valid?
    transacao.errors.delete :dados_pedido # ignores dependent errors
    expected_errors = transacao.errors.messages.map { |attr,errors|
      # errors have theit attributes identified when put on base
      errors.map { |e| "#{attr}: #{e}" }
    }.flatten
    txn.errors.messages[:base].must_equal expected_errors
  end

  describe "errors that parent object injects on dependent objects" do
    let(:pr) { Cieloz.portador  order, numero:    numero  }
    let(:pd) { Cieloz.pedido    order, valor:     valor   }
    let(:pg) { Cieloz.parcelado order, bandeira:  'visa', parcelas: 2 }
    let(:txn){
      Cieloz.transacao order, dados_portador: pr,
                              dados_pedido: pd,
                              forma_pagamento: pg
    }
    let(:err) { "activemodel.errors.models.cieloz/requisicao_transacao" }
    let(:min_parcel_msg) {
      I18n.t "#{err}/dados_pedido.attributes.valor.minimum_installment_not_satisfied"
    }
    let(:invalid_number_msg) {
      I18n.t "#{err}/dados_portador.attributes.numero.invalid"
    }

    before  { Cieloz::Configuracao.store_mode! }
    after   { Cieloz::Configuracao.reset! }

    describe "to base" do
      let(:valor)   { 9.00 }
      let(:numero)  { "1234" }

      before { txn.valid? }

      it "validates parcela minima" do
        order.errors[:base].must_include "valor: #{min_parcel_msg}"
      end

      it "validates credit card number" do
        order.errors[:base].must_include "numero: #{invalid_number_msg}"
      end
    end

    describe "to attribute" do
      let(:valor) { :value }
      let(:numero) { :number }

      before {
        def order.value ; 9.00 end
        def order.number ; "invalid" end
        txn.valid?
      }

      it "validates parcela minima" do
        order.errors[:value].must_include min_parcel_msg
      end

      it "validates credit card number" do
        order.errors[:number].must_include invalid_number_msg
      end
    end
  end
end
