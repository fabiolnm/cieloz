describe Cieloz::Configuracao do
  let(:_) { Cieloz::Configuracao }
  let(:hash) { { numero: 123, chave: "abc123" } }

  before do
    _.reset!
  end

  describe "defaults" do
    it { _.moeda.must_equal               986   }
    it { _.idioma.must_equal              "PT"  }
    it { _.max_parcelas.must_equal        3     }
    it { _.captura_automatica.must_equal  false }
  end

  describe "settings" do
    before do
      _.moeda               = 123
      _.idioma              = "EN"
      _.max_parcelas        = 10
      _.captura_automatica  = true

    end

    it { _.moeda.must_equal               123   }
    it { _.idioma.must_equal              "EN"  }
    it { _.max_parcelas.must_equal        10    }
    it { _.captura_automatica.must_equal  true  }
  end

  describe "credenciais" do
    describe "not set" do
      it "defaults to Homologacao::Credenciais::CIELO" do
        _.credenciais.must_equal Cieloz::Homologacao::Credenciais::CIELO
      end

      it "returns Homologacao::LOJA at store_mode" do
        _.store_mode!
        _.credenciais.must_equal Cieloz::Homologacao::Credenciais::LOJA
      end

      it "returns Homologacao::CIELO at cielo_mode" do
        _.cielo_mode!
        _.credenciais.must_equal Cieloz::Homologacao::Credenciais::CIELO
      end
    end

    describe "set" do
      before { _.credenciais = hash }

      it "returns DadosEc with credenciais attributes" do
        _.credenciais.numero.must_equal hash[:numero]
        _.credenciais.chave.must_equal  hash[:chave]
      end

      it "returns the same DadosEc in subsequent calls" do
        _.credenciais.must_equal _.credenciais
      end
    end
  end

  describe "host" do
    it "returns homologation host when credenciais is not set" do
      _.host.must_equal Cieloz::Homologacao::HOST
    end

    it "returns production host when credenciais is set" do
      _.credenciais = hash
      _.host.must_equal Cieloz::Configuracao::HOST
    end
  end
end
