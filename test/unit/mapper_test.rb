describe Cieloz::Mapper do
  class Source
    attr_reader :errors

    def initialize
      @errors = Hash.new

      def @errors.add(attr, value)
        (self[attr] ||= []) << value
      end
    end

    def number ; nil end
  end

  let(:order) { Source.new }

  let(:order_mapper) {
    Cieloz::Mapper.map order, :pedido, numero: :number, valor: :value
  }

  it "recognizes error for attribute" do
    order_mapper.wont_be :valid?
    errors = order.errors[:number]
    errors.wont_be_empty
    errors.must_equal order_mapper.errors[:numero]
  end

  let(:transaction_mapper) {
    Cieloz::Mapper.map order, :transacao, dados_pedido: order_mapper
  }

  it "recognizes errors for dependent mappers" do
    transaction_mapper.wont_be :valid?
    errors = order.errors[:number]
    errors.wont_be_empty
    errors.must_equal order_mapper.errors[:numero]
  end

  it "appends non-dependent errors to root aggregate base" do
    transaction_mapper.wont_be :valid?
    order.errors[:base].wont_be_empty
  end
end
