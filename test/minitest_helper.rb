require 'cieloz'

require 'minitest/autorun'
# require 'turn/autorun'

require 'vcr'
require 'erb'

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
  # c.debug_logger = File.open('test/tmp/vcr.log', 'w')
end

class MiniTest::Spec
  class << self
    alias :_create :create

    def create name, desc
      cls = _create name, desc
      begin
        c = eval name
        cls.subject {
          if c.is_a? Class then c.new elsif c.is_a? Module then c end
        }
      rescue
      end
      cls
    end
  end
end

def expected_xml opts={}
  root, id, versao = opts[:root], opts[:id], opts[:versao]

  '<?xml version="1.0" encoding="UTF-8"?>'    +
  %|<#{root} id="#{id}" versao="#{versao}">|  +
    "#{yield if block_given?}"                +
  "</#{root}>"
end

def render_template dir, filename, binding
  template = File.join dir, [ "xml", filename ]
  file = File.read template
  erb = ERB.new file
  res = erb.result binding
  res.split("\n").collect {|line| line.strip }.join
end

def xml_for type, dir, binding
  render_template dir, "dados-#{type}.xml", binding
end

module MiniTest::Assertions
  def must_validate_presence_of(attribute)
    @attribute = attribute
    must_be_invalid_with nil, :blank
  end

  def wont_validate_presence_of(attribute)
    @attribute = attribute
    must_be_valid_with nil, :blank
  end

  def must_allow_value(attribute, value, options={})
    @attribute = attribute
    must_be_valid_with value, :invalid, options
  end

  def wont_allow_value(attribute, value, options={})
    @attribute = attribute
    must_be_invalid_with value, :invalid, options
  end

  def must_ensure_length_of(attribute, options)
    @attribute = attribute
    if max = options[:is_at_most]
      value = (max + 1).times.collect { "a" }.join
      must_be_invalid_with value, 'too_long', count: max
    end
    if min = options[:is_at_least]
      value = (min - 1).times.collect { "a" }.join
      must_be_invalid_with value, 'too_short', count: min
    end
  end

  def wont_ensure_length_of(attribute, options)
    @attribute = attribute
    if max = options[:is_at_most]
      value = (max + 1).times.collect { "a" }.join
      must_be_valid_with value, 'too_long', count: max
    end
    if min = options[:is_at_least]
      value = (min - 1).times.collect { "a" }.join
      must_be_valid_with value, 'too_short', count: min
    end
  end

  def must_validate_numericality_of(attribute, options)
    @attribute = attribute
    if options[:only_integer]
      must_be_invalid_with 1.1, :not_an_integer
    end
  end

  def must_ensure_inclusion_of(attribute, options)
    @attribute = attribute
    if array = options[:in_array]
      array.each do |value|
        must_be_valid_with value, options['message']
      end
    end
  end

  private
  def must_be_valid_with(value, error_key, options={})
    subject.instance_variable_set "@#{@attribute}", value
    subject.valid?

    msg = options[:message] || I18n.t("errors.messages.#{error_key}", options)
    (subject.errors.messages[@attribute] || []).wont_include msg
  end

  def must_be_invalid_with(value, error_key, options={})
    subject.instance_variable_set "@#{@attribute}", value
    subject.valid?

    msg = options[:message] || I18n.t("errors.messages.#{error_key}", options)
    (subject.errors.messages[@attribute] || []).must_include msg
  end
end
