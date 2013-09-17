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
end
