require 'active_support/core_ext/string'
require 'active_support/core_ext/object/with_options'
require 'active_model'
require 'nokogiri'

require 'cieloz/version'
require "cieloz/helpers"
require 'cieloz/builder'
require "cieloz/bandeiras"
require "cieloz/configuracao"
require "cieloz/homologacao"
require "cieloz/requisicao"
require "cieloz/requisicao/dados_ec"
require "cieloz/requisicao/resposta"
require "cieloz/requisicao/resposta/erro"
require "cieloz/requisicao/resposta/transacao"
require "cieloz/requisicao_transacao"
require "cieloz/requisicao_transacao/dados_portador"
require "cieloz/requisicao_transacao/dados_pedido"
require "cieloz/requisicao_transacao/forma_pagamento"
require "cieloz/requisicao_tid"

DIR = File.dirname __FILE__
I18n.load_path += Dir.glob "#{DIR}/../config/locales/*.{rb,yml}"
