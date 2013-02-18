describe Cieloz::Builder do
  let(:_)   { Cieloz }

  before do
    Cieloz::Configuracao.soft_descriptor = "config"

    @source = Object.new
    def @source.numero  ; 123456  end
    def @source.valor   ; 7890    end
  end

  describe "Pedido building" do
    let(:now) { Time.now }

    before do
      Time.stub :now, now do
        @pedido = _.pedido @source
      end
    end

    describe "missing opts" do
      it "asks for pedido / numero and valor attributes" do
        @pedido.numero.must_equal @source.numero
        @pedido.valor.must_equal  @source.valor
      end

      it "populates config values for data_hora, idioma, moeda and soft_descriptor" do
        @pedido.descricao.must_be_nil
        @pedido.data_hora.must_equal        now
        @pedido.moeda.must_equal            Cieloz::Configuracao.moeda
        @pedido.idioma.must_equal           Cieloz::Configuracao.idioma
        @pedido.soft_descriptor.must_equal  Cieloz::Configuracao.soft_descriptor
      end
    end

    describe "opts given" do
      before do
        def @source.number      ; 24680     end
        def @source.value       ; 13579     end
        def @source.description ; "abc"     end
        def @source.time        ; Time.at 0 end
        def @source.currency    ; 123       end
        def @source.language    ; "EN"      end
        def @source.soft_desc   ; "xyz"     end
      end

      it "maps attribute names" do
        mappings = {
          numero:           :number,
          valor:            :value,
          descricao:        :description,
          data_hora:        :time,
          moeda:            :currency,
          idioma:           :language,
          soft_descriptor:  :soft_desc
        }
        pedido = _.pedido @source, mappings

        mappings.each { |k,v| pedido.send(k).must_equal @source.send(v) }
      end

      it "gets given opts values" do
        opts = {
          numero:           "abc",
          valor:            123,
          descricao:        "description",
          data_hora:        1.day.ago,
          moeda:            321,
          idioma:           "ES",
          soft_descriptor:  "soft_desc"
        }
        pedido = _.pedido @source, opts

        opts.each { |k,v| pedido.send(k).must_equal opts[k] }
      end
    end

    describe "valor handling" do
      it "preserves valor if it's an integer" do
        _.pedido(@source).valor.must_equal @source.valor
      end

      it "converts valor to integer number of cents if it's a float" do
        def @source.valor ; 123.451 end
        _.pedido(@source).valor.must_equal 12345

        def @source.valor ; 123.456 end
        _.pedido(@source).valor.must_equal 12346
      end
    end
  end

  describe "Pagamento Building" do
    before do
      def @source.operacao ; :visa  end
      def @source.parcelas ; 2      end
    end

    it "asks for operacao / parcelas attributes when missing opts" do
      pg = _.pagamento @source
      pg.bandeira.must_equal "visa"
      pg.parcelas.must_equal @source.parcelas
    end

    it "maps operacao / numero when opts are given" do
      def @source.operation     ; :mastercard end
      def @source.installments  ; 6           end

      opts = { operacao: :operation, parcelas: :installments }
      pg = _.pagamento @source, opts

      pg.bandeira.must_equal @source.operation.to_s
      pg.parcelas.must_equal @source.installments
    end

    it "get given operacao / numero values" do
      opts = { operacao: "amex", parcelas: 9 }
      pg = _.pagamento @source, opts

      pg.bandeira.must_equal opts[:operacao]
      pg.parcelas.must_equal opts[:parcelas]
    end
  end

  describe "Transacao Building" do
    let(:mappings) {
      {
        dados_pedido:     _.pedido(@source),
        forma_pagamento:  _.pagamento(@source)
      }
    }

    before do
      @captura = Cieloz::Configuracao.captura_automatica
      Cieloz::Configuracao.captura_automatica = true
      Cieloz::Configuracao.url_retorno = "http://call.back"

      def @source.operacao        ; :visa       end
      def @source.parcelas        ; 2           end
      def @source.dados_portador  ; @portador   end
      def @source.dados_pedido    ; @pedido     end
      def @source.forma_pagamento ; @pagamento  end

      @portador   = _.portador(@source)
      @pedido     = _.pedido(@source)
      @pagamento  = _.pagamento(@source)

      @source.instance_variable_set :@portador,   @portador
      @source.instance_variable_set :@pedido,     @pedido
      @source.instance_variable_set :@pagamento,  @pagamento
    end

    after do
      Cieloz::Configuracao.captura_automatica = @captura
    end

    it "populates config values for url_retorno / captura_automatica when missing opts" do
      txn = _.transacao @source

      txn.url_retorno.must_equal Cieloz::Configuracao.url_retorno
      txn.capturar.must_equal Cieloz::Configuracao.captura_automatica.to_s
    end

    it "maps attributes when opts are given" do
      obj_mappings = {
        dados_portador:   :card_owner,
        dados_pedido:     :order,
        forma_pagamento:  :payment,
      }
      val_mappings = {
        url_retorno:      :callback_url,
        capturar:         :auto_capture,
        campo_livre:      :notes
      }

      def @source.card_owner    ; @portador       end
      def @source.order         ; @pedido         end
      def @source.payment       ; @pagamento      end
      def @source.callback_url  ; "http://ca.ll"  end
      def @source.auto_capture  ; "true"          end
      def @source.notes         ; "notes"         end

      txn = _.transacao @source, obj_mappings.merge(val_mappings)
      obj_mappings.each { |k,v| txn.send(k).must_be_same_as @source.send(v) }
      val_mappings.each { |k,v| txn.send(k).must_equal      @source.send(v) }
    end

    it "gets given attribute values" do
      values = {
        dados_portador:   @portador,
        dados_pedido:     @pedido,
        forma_pagamento:  @pagamento,
        url_retorno:      "http://call",
        capturar:         "false",
        campo_livre:      "livre"
      }
      txn = _.transacao @source, values
      values.each { |k,v| txn.send(k).must_equal v }
    end

    it "triggers pagamento.operacao" do
      _.transacao(@source).autorizar
      .must_equal Cieloz::RequisicaoTransacao::AUTORIZACAO_DIRETA

      ["verified_by_visa", "mastercard_securecode"].each {|opr|
        pg = _.pagamento @source, operacao: opr, parcelas: 2
        _.transacao(@source, forma_pagamento: pg).autorizar
        .must_equal Cieloz::RequisicaoTransacao::AUTORIZAR_SE_AUTENTICADA
      }
    end
  end
end
