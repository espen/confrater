require 'spec_helper'
require 'cgi'

describe Confrere do
  describe "attributes" do
    before do
      Confrere::APIRequest.send(:public, *Confrere::APIRequest.protected_instance_methods)

      @username = "42"
      @password = "hemmelig"
      @proxy = 'the_proxy'
    end

    it "have no API by default" do
      @confrere = Confrere::Request.new
      expect(@confrere.username).to be_nil
    end

    it "sets an API key in the constructor" do
      @confrere = Confrere::Request.new(username: @username, password: @password)
      expect(@confrere.username).to eq(@username)
      expect(@confrere.password).to eq(@password)
    end

    it "sets an API key via setter" do
      @confrere = Confrere::Request.new
      @confrere.username = @username
      @confrere.password = @password
      expect(@confrere.username).to eq(@username)
      expect(@confrere.password).to eq(@password)
    end

    it "sets timeout and get" do
      @confrere = Confrere::Request.new
      timeout = 30
      @confrere.timeout = timeout
      expect(timeout).to eq(@confrere.timeout)
    end

    it "sets the open_timeout and get" do
      @confrere = Confrere::Request.new
      open_timeout = 30
      @confrere.open_timeout = open_timeout
      expect(open_timeout).to eq(@confrere.open_timeout)
    end

    it "timeout properly passed to APIRequest" do
      @confrere = Confrere::Request.new
      timeout = 30
      @confrere.timeout = timeout
      @request = Confrere::APIRequest.new(builder: @confrere)
      expect(timeout).to eq(@request.timeout)
    end

    it "timeout properly based on open_timeout passed to APIRequest" do
      @confrere = Confrere::Request.new
      open_timeout = 30
      @confrere.open_timeout = open_timeout
      @request = Confrere::APIRequest.new(builder: @confrere)
      expect(open_timeout).to eq(@request.open_timeout)
    end

    it "has no Proxy url by default" do
      @confrere = Confrere::Request.new
      expect(@confrere.proxy).to be_nil
    end

    it "sets an proxy url key from the 'CONFRERE_PROXY_URL' ENV variable" do
      ENV['CONFRERE_PROXY_URL'] = @proxy
      @confrere = Confrere::Request.new
      expect(@confrere.proxy).to eq(@proxy)
      ENV.delete('CONFRERE_PROXY_URL')
    end

    it "sets an API key via setter" do
      @confrere = Confrere::Request.new
      @confrere.proxy = @proxy
      expect(@confrere.proxy).to eq(@proxy)
    end

    it "sets an adapter in the constructor" do
      adapter = :em_synchrony
      @confrere = Confrere::Request.new(faraday_adapter: adapter)
      expect(@confrere.faraday_adapter).to eq(adapter)
    end

    it "symbolize_keys false by default" do
      @confrere = Confrere::Request.new
      expect(@confrere.symbolize_keys).to be false
    end

    it "sets symbolize_keys in the constructor" do
      @confrere = Confrere::Request.new(symbolize_keys: true)
      expect(@confrere.symbolize_keys).to be true
    end

    it "sets symbolize_keys in the constructor" do
      @confrere = Confrere::Request.new(symbolize_keys: true)
      expect(@confrere.symbolize_keys).to be true
    end

    it "debug false by default" do
      @confrere = Confrere::Request.new
      expect(@confrere.debug).to be false
    end

    it "sets debug in the constructor" do
      @confrere = Confrere::Request.new(debug: true)
      expect(@confrere.debug).to be true
    end

    it "sets logger in constructor" do
      logger = double(:logger)
      @confrere = Confrere::Request.new(logger: logger)
      expect(@confrere.logger).to eq(logger)
    end

    it "is a Logger instance by default" do
      @confrere = Confrere::Request.new
      expect(@confrere.logger).to be_a Logger
    end

    it "api_environment production by default" do
      @confrere = Confrere::Request.new
      expect(@confrere.api_environment).to be :production
    end

    it "sets api_environment in the constructor" do
      @confrere = Confrere::Request.new(api_environment: :sandbox)
      expect(@confrere.api_environment).to be :sandbox
    end

  end

  describe "supports different environments" do
    before do
      Confrere::APIRequest.send(:public, *Confrere::APIRequest.protected_instance_methods)
    end

    it "has correct api url" do
      @confrere = Confrere::Request.new()
      @request = Confrere::APIRequest.new(builder: @confrere)
      expect(@request.send(:base_api_url)).to eq("https://api.confrere.com/v1/")
    end

  end

  describe "build api url" do
    before do
      Confrere::APIRequest.send(:public, *Confrere::APIRequest.protected_instance_methods)

      @confrere = Confrere::Request.new
    end

    it "doesn't allow empty api username or password" do
      expect {@confrere.try.retrieve}.to raise_error(Confrere::ConfrereError)
    end

  end

  describe "class variables" do
    let(:logger) { double(:logger) }

    before do
      Confrere::Request.username = "42"
      Confrere::Request.password = "hemmelig"
      Confrere::Request.timeout = 15
      Confrere::Request.api_environment = :sandbox
      Confrere::Request.api_endpoint = 'https://confrere.example.org/v1337/'
      Confrere::Request.logger = logger
      Confrere::Request.proxy = "http://1234.com"
      Confrere::Request.symbolize_keys = true
      Confrere::Request.faraday_adapter = :net_http
      Confrere::Request.debug = true
    end

    after do
      Confrere::Request.username = nil
      Confrere::Request.password = nil
      Confrere::Request.timeout = nil
      Confrere::Request.api_environment = nil
      Confrere::Request.api_endpoint = nil
      Confrere::Request.logger = nil
      Confrere::Request.proxy = nil
      Confrere::Request.symbolize_keys = nil
      Confrere::Request.faraday_adapter = nil
      Confrere::Request.debug = nil
    end

    it "set username on new instances" do
      expect(Confrere::Request.new.username).to eq(Confrere::Request.username)
    end

    it "set password on new instances" do
      expect(Confrere::Request.new.password).to eq(Confrere::Request.password)
    end

    it "set timeout on new instances" do
      expect(Confrere::Request.new.timeout).to eq(Confrere::Request.timeout)
    end

    it "set api_environment on new instances" do
      expect(Confrere::Request.api_environment).not_to be_nil
      expect(Confrere::Request.new.api_environment).to eq(Confrere::Request.api_environment)
    end

    it "set api_endpoint on new instances" do
      expect(Confrere::Request.api_endpoint).not_to be_nil
      expect(Confrere::Request.new.api_endpoint).to eq(Confrere::Request.api_endpoint)
    end

    it "set proxy on new instances" do
      expect(Confrere::Request.new.proxy).to eq(Confrere::Request.proxy)
    end

    it "set symbolize_keys on new instances" do
      expect(Confrere::Request.new.symbolize_keys).to eq(Confrere::Request.symbolize_keys)
    end

    it "set debug on new instances" do
      expect(Confrere::Request.new.debug).to eq(Confrere::Request.debug)
    end

    it "set faraday_adapter on new instances" do
      expect(Confrere::Request.new.faraday_adapter).to eq(Confrere::Request.faraday_adapter)
    end

    it "set logger on new instances" do
      expect(Confrere::Request.new.logger).to eq(logger)
    end
  end

  describe "missing methods" do
    it "respond to .method call on class" do
      expect(Confrere::Request.method(:customers)).to be_a(Method)
    end
    it "respond to .method call on instance" do
      expect(Confrere::Request.new.method(:customers)).to be_a(Method)
    end
  end
end
