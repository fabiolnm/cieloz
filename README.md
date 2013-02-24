[<img src="https://secure.travis-ci.org/fabiolnm/cieloz.png"/>](http://travis-ci.org/fabiolnm/cieloz)

# Cieloz

A utility gem for SpreeCielo Gateway gem.

## Installation

Add this line to your application's Gemfile:

    gem 'cieloz'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cieloz

# Usage

    This is a quick start guide to Cieloz API. 
    If you want to learn deeply about Cielo Gateway, read the Getting Started section.

## Low Level API: Requisicao objects

Provides a one-to-one ruby implementation for Cielo specification.
It's much more verbose than the High Level API, but provide a fine grained relation with Cielo WS API.
The High Level API is just a wrapper with convenient methods to handle with the Low Level API.
A developer must instantiates one of the available operations:

 * RequisicaoTransacao
 * RequisicaoConsulta
 * RequisicaoCaptura
 * RequisicaoCancelamento

Then populate them with appropriate data. This gem validates these request objects according to
Cielo Specifications present at Developer Guide (pages 10, 11, 26, 28 and 30), so it makes error
handling easier ans faster, before the request is sent to Cielo Web Service.

If the operation is valid, this gem serializes them as XML and submits to Cielo, parsing the
response as a Transaction (Transacao) or Error (Erro) objects. Both keeps the original XML response
as a xml attribute, so it can be logged.

### Authorization

    dados_ec  = Cieloz::Configuracao.credenciais

    pedido    = Cieloz::RequisicaoTransacao::DadosPedido.new numero: 123, valor: 5000, moeda: 986,
                data_hora: now, descricao: "teste", idioma: "PT", soft_descriptor: "13letterstest"
                
    pagamento = Cieloz::RequisicaoTransacao::FormaPagamento.new.credito "visa"
    
    transacao = Cieloz::RequisicaoTransacao.new dados_ec:         dados_ec,
                                                dados_pedido:     pedido,
                                                forma_pagamento:  pagamento,
                                                url_retorno:      your_callback_url
                                                
    response  = transacao.autorizacao_direta.submit
    
    response.success? # returned Transacao (with status and id for the created Cielo transaction) or Error object?

### Verify

    consulta = Cieloz::RequisicaoConsulta.new tid: transacao.tid, dados_ec: ec
    resposta = consulta.submit
    resposta.autorizada?

### Capture

    captura = Cieloz::RequisicaoCaptura.new tid: transacao.tid, dados_ec: ec
    resposta = captura.submit
    resposta.capturada?

### Partial Capture

    value = 1000      # a value less than the authorized
    captura = Cieloz::RequisicaoCaptura.new tid: transacao.tid, dados_ec: ec, valor: value
    resposta = captura.submit
    resposta.capturada?

### Cancel

    cancelar = Cieloz::RequisicaoCancelamento.new tid: transacao.tid, dados_ec: ec
    resposta = cancelar.submit
    resposta.cancelada?

### Partial Cancel

    value = 1000      # a value less than the authorized
    cancelar = Cieloz::RequisicaoCancelamento.new tid: transacao.tid, dados_ec: ec, valor: value
    resposta = cancelar.submit
    resposta.cancelada?

## High Level API: Cieloz::Buider

The easiest way to use this gem is through the high level API provided by Cieloz::Builder.
It provides convenient methods to build the respective Cieloz request objects from your domain model object.

### Cieloz.transacao - builds a RequisicaoTransacao object for Payment Authorization
    
    pd = Cieloz.pedido    order 
    pg = Cieloz.pagamento payment, operacao: :op, parcelas: :installments
    tx = Cieloz.transacao nil, dados_pedido: pd, forma_pagamento: pg

### Cieloz.consulta - builds RequisicaoConsulta

    consulta = Cieloz.consulta payment

### Cieloz.captura - builds RequisicaoCaptura

    captura = Cieloz.captura payment # total capture
    
    or
    
    captura = Cieloz.captura payment, value: partial_value


### Cieloz.cancelamento - builds RequisicaoCancelamento

    cancelamento = Cieloz.cancelamento payment # total cancel
    
    or
    
    cancelamento = Cieloz.cancelamento payment, value: partial_cancel
    
### Domain Model Mapping Startegies

High Level API uses three different strategies to extract the attribute values required to build Cielo object attribute 
values to be serialized in XML format and sent to Cielo Web Service (see Domain Model Mapping Strategies below).

When an attribute cannot be resolved from one mapping strategy, Cieloz::Builder retrieves the default values configured
at Cieloz::Configuracao class:

    @@mode                = :cielo
    @@moeda               = 986 # ISO 4217 - Manual Cielo, p 11
    @@idioma              = "PT"
    @@max_parcelas        = 3
    @@max_adm_parcelas    = 10
    @@captura_automatica  = false

#### Default Naming Mappings

When your domain object attribute names are the same as the Cielo Web Service expect.

    order.numero  = "R123456"
    order.valor   = 12345
    
    # creates Cieloz::RequisicaoTransacao::DadosPedido extracting order attributes
    # that has the same names as DadosPedido attributes
    pedido = Cieloz.pedido order
    
    p pedido.numero
    $ R123456
    
    p pedido.valor
    $ 12345

#### Domain Model Mappings

When you should provide a mapping between your domain model attributes and Cielo Web Service attributes.

    order.number  = "R123456"
    order.value   = 12345

    # maps  order.number  to DadosPedido#numero
    # and   order.value   to DadosPedido#valor
    pedido = Cieloz.pedido order, numero: :number, valor: :value
    
    p pedido.numero
    $ R123456
    
    p pedido.valor
    $ 12345

#### Explicit Values

When you provide values.

    pedido = Cieloz.pedido nil, numero: "R123456", valor: 12345
    
    p pedido.numero
    $ R123456
    
    p pedido.valor
    $ 12345

#### The strategies can be used together!

    order.descricao = "Hello Cielo!"
    pedido = Cieloz.pedido source, numero: number, valor: 12345
    
    p pedido.numero
    $ R123456
    
    p pedido.valor
    $ 12345

    p pedido.descricao
    $ Hello Cielo!

## Configuration

Your application can configure Cieloz::Configuracao default values.
In a Rails application, it can be done in a config/initializers/cieloz.rb file.

If you don't provide ```credenciais```, all operations will be requested against Cielo Homologation Environment.

When you go to production, you MUST configure ```credenciais``` with your Cielo ```numero``` and ```chave```.

    YourApp::Application.class_eval do
      # Runs in after initialize block to be able to access url helpers
      config.after_initialize do
        # must reload routes to initialize routes.url_helpers
        reload_routes!

        # These are Global Default Settings, and can be overriden at Bulder / Requisicao method levels
        Cieloz::Configuracao.tap { |c|
          # 13 letters descriptor to be printed on the buyer's credit card billing
          c.soft_descriptor = "Your App name"

          # Callback url: in Cielo Mode this is the location to where Cielo redirects a transaction
          # after the user types this Credit card data.
          #
          # NOTICE: In order to *_url methods to work, it's required to set
          # in config/application.rb or in one of config/environment initializers:
          #
          #   [Rails.application.]routes.default_url_options = { host: "HOSTNAME[:PORT]" }
          #
          c.url_retorno     = routes.url_helpers.root_url

          # Credit card data is asked to the user in a page hosted by Cielo. This is the default mode
          # c.cielo_mode!

          # Your application must provide a view asking credit card data, and provide additional security,
          # in conformance with PCI Standards: http://www.cielo.com.br/portal/cielo/solucoes-de-tecnologia/o-que-e-ais.html
          # c.store_mode!

          # default to Cieloz::Homologacao::Credenciais::LOJA if store_mode? and ::CIELO if cielo_mode?
          # c.credenciais = { numero: "", chave: "" }

          # c.moeda               = 986   # ISO 4217 - Manual Cielo, p 11
          # c.idioma              = "PT"  # EN and ES available - language to Cielo use in this pages

          # http://www.cielo.com.br/portal/cielo/produtos/cielo/parcelado-loja.html
          # c.max_parcelas        = 3     # no additional interest rates

          # http://www.cielo.com.br/portal/cielo/produtos/cielo/parcelado-administradora.html
          # c.max_adm_parcelas    = 10    # available with Cielo interest rate

          # if true, payments are automatically captured by authorization request
          # c.captura_automatica  = false
        }
      end
    end

## Getting Started

This is a step-by-step guide to enable Cielo Gateway as a payment method to your e-commerce store.

First, you should create your credentials at the following Cielo Page:

![Credentials](https://raw.github.com/fabiolnm/cieloz/master/readme/credentials.png)

Then a form will be presented to be filled with Store, Store's Owner, Store's Address* and Banking data.
* address must be the same as the present at Store CNPJ!

After the form is submitted, a receipt number is generated, and generally in one or two business days,
Cielo sends an e-mail with detailed instructions and manuals:

 * [Email example](https://raw.github.com/fabiolnm/cieloz/master/readme/email_cielo.pdf)
 * [Security Guide](https://raw.github.com/fabiolnm/cieloz/master/readme/cielo_guia_seguranca_ecommerce.pdf)
 * [Affiliation Contract](https://raw.github.com/fabiolnm/cieloz/master/readme/contrato_de_afiliacao_ao_sistema_cielo.pdf)
 * [Preventive Tips for securing sales](https://raw.github.com/fabiolnm/cieloz/master/readme/dicas_preventivas_para_vendas_mais_seguras.pdf)
 * [Required documents for affiliation](https://raw.github.com/fabiolnm/cieloz/master/readme/lista_de_documentos_necessarios_para_afiliacao_de_vendas_pela_internet_pessoa_juridica.pdf)
 * [Risk Terms](https://raw.github.com/fabiolnm/cieloz/master/readme/termo_de_adesao_de_risco.pdf)

##### NOTE
These were the documents sent by Cielo at December 21, 2012, and are subject to changes according to the Cielo affiliation processs changes.
If you notice any document is changed since then, and wants to collaborate on keeping this gem updated, please open an issue
so our team can update this README.

##### Cielo Developer Kit
Additionaly, the email provides a link where the Cielo Integration Kit can be downloaded:

  http://www.cielo.com.br/portal/kit-e-commerce-cielo.html

This kit contais the API documentation that served as a basis to developing this gem:
[Cielo e-commerce Developer Guide v2.0.3](https://raw.github.com/fabiolnm/cieloz/master/readme/cielo_developer_guide_2.0.3.pdf).

### The Test Environment

The page 32 of this manual provides information about a Test Environment that can be used as a sandbox
to test integration with Cielo Web Services:

  https://qasecommerce.cielo.com.br/servicos/ecommwsec.do

It also provides API ID and API Secret that are required to be sent within every request sent
to Cielo Web Services, and valid test credit card numbers to be used at this environment.

### The Cielo Payment Workflow

#### Hosted Buy Page versus Store Buy Page

Credit Card data can be provided directly to a Store BuyPage, but this requires the Store
Owner to handle with security issues.

The simplest alternative to get started is using an environment provided by the Cielo
infrastructure. When the user is required to type his credit card data, he is redirected
to a Cielo Hosted Buy Page. When the user submits his data, he's redirected back to
a Callback URL provided by the store.


#### Supported CreditCard operations

The following diagram was extracted from Cielo Developer Guide v2.0.3, page 5.

![Payment States](https://raw.github.com/fabiolnm/cieloz/master/readme/supported_products.png)

#### TransactionRequest (RequisicaoTransacao)

Every payment starts with a TransactionRequest. In the Hosted Mode, its main data are:
 * Order Data (DadosPedido)
 * PaymentMethod (FormaPagamento)
 * Authorization Mode (whether it supports Authentication Programs)
 * Capture Mode (can be util for fraud prevention)

In Store Mode, it also should include Credit Card Data (DadosPortador).

##### Authorization Modes

Visa and Mastercard supports Authentication Programs. This means additional security, as the
user is required to provide additional security credentials with his bank to be able to
have a transaction authorized for online payments:

 * [Verified by Visa](https://raw.github.com/fabiolnm/cieloz/master/readme/verified_by_visa.png),
   from this [source](http://www.verifiedbyvisa.com.br/aspx/funciona/comofunciona.aspx)
 * [MasterCard Secure Code](https://raw.github.com/fabiolnm/cieloz/master/readme/mastercard_securecodedemo.swf),
   from this [source](https://www.mycardsecure.com/vpas/certegy_mc/i18n/en_US/securecodedemo.swf)

Additionaly, a specific authorization mode is available to enable recurrent payments, in the
case they are supported by the Credit Card operator.

#### Transaction States and Web Service Operations

The following diagram was extracted from Cielo Developer Guide v2.0.3, page 9.

![Payment States](https://raw.github.com/fabiolnm/cieloz/master/readme/cielo_payment_states.png)

When a TransactionRequest succeeds, it responds with a Transaction (Transacao) with Status 0 - CREATED.
This response contains the Transaction ID (TID), and an Authentication URL (url-autenticacao)
where the user must be redirected to start the Authorization flow.

When the user visits this URL, the transaction assumes Status 1 - IN_PROGRESS.
When the user submits its Credit Card data, the transaction can assume Authentication States,
if supported by the selected credit card (Verified by Visa or MasterCard Secure Code programs).

After authentication/authorization flow, if the user has available credit, the
transaction assumes Status 4 - AUTHORIZED (Autorizada).

#### RequisicaoCaptura

When the transaction is at AUTHORIZED state, the Store Owner must capture this payment in the
next five days. This can be done with a CaptureRequest (RequisicaoCaptura)

The Store Owner also has the option to request automatic payment capture, bypassing AUTHORIZED state.
After capture, the transaction assumes Status 6 - CAPTURED (Capturada).

* Manual Capture can be useful for fraud prevention, but it requires aditional Admin efforts.

#### RequisicaoCancelamento

In the 90 days that follows the Authorization or Capture, the transaction can be fully or
partially cancelled, assuming state 9 - CANCELLED (Cancelada). This can be done with a
CancelRequest (RequisicaoCancelamento).

* At any time, a pending request can be expired at Cielo Gateway, that puts the transaction in CANCELLED state.
* Each state has its own expire time, see the Developer Guide for detailed information.

#### RequisicaoConsulta

At any time, a QueryRequest (RequisicaoConsulta) can be made for a specific transaction
(identified by its TID) to query about the state of the transaction.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
