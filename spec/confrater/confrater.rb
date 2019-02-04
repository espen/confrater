require 'spec_helper'
require 'cgi'

describe Confrater do
  describe "attributes" do
    before do
      Confrater::APIRequest.send(:public, *Confrater::APIRequest.protected_instance_methods)

      @username = "42"
      @password = "hemmelig"
      @proxy = 'the_proxy'
    end

    it "have no API by default" do
      @confrere = Confrater::Request.new
      expect(@confrere.username).to be_nil
    end

    it "sets an API key in the constructor" do
      @confrere = Confrater::Request.new(username: @username, password: @password)
      expect(@confrere.username).to eq(@username)
      expect(@confrere.password).to eq(@password)
    end

    it "sets an API key via setter" do
      @confrere = Confrater::Request.new
      @confrere.username = @username
      @confrere.password = @password
      expect(@confrere.username).to eq(@username)
      expect(@confrere.password).to eq(@password)
    end

    it "sets timeout and get" do
      @confrere = Confrater::Request.new
      timeout = 30
      @confrere.timeout = timeout
      expect(timeout).to eq(@confrere.timeout)
    end

    it "sets the open_timeout and get" do
      @confrere = Confrater::Request.new
      open_timeout = 30
      @confrere.open_timeout = open_timeout
      expect(open_timeout).to eq(@confrere.open_timeout)
    end

    it "timeout properly passed to APIRequest" do
      @confrere = Confrater::Request.new
      timeout = 30
      @confrere.timeout = timeout
      @request = Confrater::APIRequest.new(builder: @confrere)
      expect(timeout).to eq(@request.timeout)
    end

    it "timeout properly based on open_timeout passed to APIRequest" do
      @confrere = Confrater::Request.new
      open_timeout = 30
      @confrere.open_timeout = open_timeout
      @request = Confrater::APIRequest.new(builder: @confrere)
      expect(open_timeout).to eq(@request.open_timeout)
    end

    it "has no Proxy url by default" do
      @confrere = Confrater::Request.new
      expect(@confrere.proxy).to be_nil
    end

    it "sets an proxy url key from the 'CONFRERE_PROXY_URL' ENV variable" do
      ENV['CONFRERE_PROXY_URL'] = @proxy
      @confrere = Confrater::Request.new
      expect(@confrere.proxy).to eq(@proxy)
      ENV.delete('CONFRERE_PROXY_URL')
    end

    it "sets an API key via setter" do
      @confrere = Confrater::Request.new
      @confrere.proxy = @proxy
      expect(@confrere.proxy).to eq(@proxy)
    end

    it "sets an adapter in the constructor" do
      adapter = :em_synchrony
      @confrere = Confrater::Request.new(faraday_adapter: adapter)
      expect(@confrere.faraday_adapter).to eq(adapter)
    end

    it "symbolize_keys false by default" do
      @confrere = Confrater::Request.new
      expect(@confrere.symbolize_keys).to be false
    end

    it "sets symbolize_keys in the constructor" do
      @confrere = Confrater::Request.new(symbolize_keys: true)
      expect(@confrere.symbolize_keys).to be true
    end

    it "sets symbolize_keys in the constructor" do
      @confrere = Confrater::Request.new(symbolize_keys: true)
      expect(@confrere.symbolize_keys).to be true
    end

    it "debug false by default" do
      @confrere = Confrater::Request.new
      expect(@confrere.debug).to be false
    end

    it "sets debug in the constructor" do
      @confrere = Confrater::Request.new(debug: true)
      expect(@confrere.debug).to be true
    end

    it "sets logger in constructor" do
      logger = double(:logger)
      @confrere = Confrater::Request.new(logger: logger)
      expect(@confrere.logger).to eq(logger)
    end

    it "is a Logger instance by default" do
      @confrere = Confrater::Request.new
      expect(@confrere.logger).to be_a Logger
    end

    it "api_environment production by default" do
      @confrere = Confrater::Request.new
      expect(@confrere.api_environment).to be :production
    end

    it "sets api_environment in the constructor" do
      @confrere = Confrater::Request.new(api_environment: :sandbox)
      expect(@confrere.api_environment).to be :sandbox
    end

  end

  describe "supports different environments" do
    before do
      Confrater::APIRequest.send(:public, *Confrater::APIRequest.protected_instance_methods)
    end

    it "has correct api url" do
      @confrere = Confrater::Request.new()
      @request = Confrater::APIRequest.new(builder: @confrere)
      expect(@request.send(:base_api_url)).to eq("https://api.confrere.com/v1/")
    end

  end

  describe "build api url" do
    before do
      Confrater::APIRequest.send(:public, *Confrater::APIRequest.protected_instance_methods)

      @confrere = Confrater::Request.new
    end

    it "doesn't allow empty api username or password" do
      expect {@confrere.try.retrieve}.to raise_error(Confrater::ConfrereError)
    end

  end

  describe "class variables" do
    let(:logger) { double(:logger) }

    before do
      Confrater::Request.username = "42"
      Confrater::Request.password = "hemmelig"
      Confrater::Request.timeout = 15
      Confrater::Request.api_environment = :sandbox
      Confrater::Request.api_endpoint = 'https://confrere.example.org/v1337/'
      Confrater::Request.logger = logger
      Confrater::Request.proxy = "http://1234.com"
      Confrater::Request.symbolize_keys = true
      Confrater::Request.faraday_adapter = :net_http
      Confrater::Request.debug = true
    end

    after do
      Confrater::Request.username = nil
      Confrater::Request.password = nil
      Confrater::Request.timeout = nil
      Confrater::Request.api_environment = nil
      Confrater::Request.api_endpoint = nil
      Confrater::Request.logger = nil
      Confrater::Request.proxy = nil
      Confrater::Request.symbolize_keys = nil
      Confrater::Request.faraday_adapter = nil
      Confrater::Request.debug = nil
    end

    it "set username on new instances" do
      expect(Confrater::Request.new.username).to eq(Confrater::Request.username)
    end

    it "set password on new instances" do
      expect(Confrater::Request.new.password).to eq(Confrater::Request.password)
    end

    it "set timeout on new instances" do
      expect(Confrater::Request.new.timeout).to eq(Confrater::Request.timeout)
    end

    it "set api_environment on new instances" do
      expect(Confrater::Request.api_environment).not_to be_nil
      expect(Confrater::Request.new.api_environment).to eq(Confrater::Request.api_environment)
    end

    it "set api_endpoint on new instances" do
      expect(Confrater::Request.api_endpoint).not_to be_nil
      expect(Confrater::Request.new.api_endpoint).to eq(Confrater::Request.api_endpoint)
    end

    it "set proxy on new instances" do
      expect(Confrater::Request.new.proxy).to eq(Confrater::Request.proxy)
    end

    it "set symbolize_keys on new instances" do
      expect(Confrater::Request.new.symbolize_keys).to eq(Confrater::Request.symbolize_keys)
    end

    it "set debug on new instances" do
      expect(Confrater::Request.new.debug).to eq(Confrater::Request.debug)
    end

    it "set faraday_adapter on new instances" do
      expect(Confrater::Request.new.faraday_adapter).to eq(Confrater::Request.faraday_adapter)
    end

    it "set logger on new instances" do
      expect(Confrater::Request.new.logger).to eq(logger)
    end
  end

  describe "missing methods" do
    it "respond to .method call on class" do
      expect(Confrater::Request.method(:appointmets)).to be_a(Method)
    end
    it "respond to .method call on instance" do
      expect(Confrater::Request.new.method(:appointmets)).to be_a(Method)
    end
  end
end
