describe "Bandeiras e Operacoes" do
  let(:_) { Cieloz::Bandeiras }

  it "recognizes mastercard secure code requires authentication" do
    res = _.operacao "mastercard_securecode"
    assert_equal [_::MASTERCARD, :autorizar_somente_autenticada], res
  end

  it "recognizes verified by visa code requires authentication" do
    res = _.operacao "verified_by_visa"
    assert_equal [_::VISA, :autorizar_somente_autenticada], res
  end

  it "recognizes supported products allows direct authorization" do
    _::ALL.each do |bandeira|
      res = _.operacao bandeira
      assert_equal [bandeira, :autorizacao_direta], res
    end
  end

  it "disallows unsupported products" do
    error = lambda { _.operacao("anything else") }.must_raise RuntimeError
    error.message.must_match /product_not_supported/
  end
end
