describe Cieloz::Configuracao do
  let(:_) { Cieloz::Configuracao }
  let(:_hash) { { numero: 123, chave: "abc123" } }

  before do
    _.reset!
  end

  describe "defaults" do
    it { _.moeda.must_equal               986   }
    it { _.idioma.must_equal              "PT"  }
    it { _.max_parcelas.must_equal        3     }
    it { _.max_adm_parcelas.must_equal    10    }
    it { _.captura_automatica.must_equal  false }
  end

  describe "settings" do
    before do
      @cur, @lang, @max, @max_adm, @cap = _.moeda, _.idioma,
        _.max_parcelas, _.max_adm_parcelas, _.captura_automatica

      _.moeda               = 123
      _.idioma              = "EN"
      _.max_parcelas        = 6
      _.max_adm_parcelas    = 12
      _.captura_automatica  = true
    end

    it { _.moeda.must_equal               123   }
    it { _.idioma.must_equal              "EN"  }
    it { _.max_parcelas.must_equal        6     }
    it { _.max_adm_parcelas.must_equal    12    }
    it { _.captura_automatica.must_equal  true  }

    after do
      _.moeda               = @cur
      _.idioma              = @lang
      _.max_parcelas        = @max
      _.max_adm_parcelas    = @max_adm
      _.captura_automatica  = @cap
    end
  end

  describe "credenciais" do
    describe "not set" do
      let(:loja_ec)   { Cieloz::Requisicao::DadosEc.new Cieloz::Homologacao::Credenciais::LOJA  }
      let(:cielo_ec)  { Cieloz::Requisicao::DadosEc.new Cieloz::Homologacao::Credenciais::CIELO }

      it "defaults to Homologacao::Credenciais::CIELO" do
        _.credenciais.numero.must_equal cielo_ec.numero
        _.credenciais.chave.must_equal cielo_ec.chave
      end

      it "returns Homologacao::LOJA at store_mode" do
        _.store_mode!
        _.credenciais.numero.must_equal loja_ec.numero
        _.credenciais.chave.must_equal loja_ec.chave
      end

      it "returns Homologacao::CIELO at cielo_mode" do
        _.cielo_mode!
        _.credenciais.numero.must_equal cielo_ec.numero
        _.credenciais.chave.must_equal cielo_ec.chave
      end
    end

    describe "set" do
      before { _.credenciais = _hash }

      it "returns DadosEc with credenciais attributes" do
        _.credenciais.numero.must_equal _hash[:numero]
        _.credenciais.chave.must_equal  _hash[:chave]
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
      _.credenciais = _hash
      _.host.must_equal Cieloz::Configuracao::HOST
    end
  end
end
