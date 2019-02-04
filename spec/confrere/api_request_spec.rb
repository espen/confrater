require 'spec_helper'
require 'webmock/rspec'

describe Confrere::APIRequest do
  let(:username) { "42" }
  let(:password) { "hemmelig" }

  before do
    @confrere = Confrere::Request.new(username: username, password: password)
    @api_root = "https://api.confrere.com/v1"
  end

  it "surfaces client request exceptions as a Confrere::APIError" do
    exception = Faraday::Error::ClientError.new("the server responded with status 503")
    stub_request(:get, "#{@api_root}/users").with(basic_auth: [username, password]).to_raise(exception)
    expect { @confrere.users.retrieve }.to raise_error(Confrere::APIError)
  end

  it "surfaces an unparseable client request exception as a Confrere::APIError" do
    exception = Faraday::Error::ClientError.new(
      "the server responded with status 503")
    stub_request(:get, "#{@api_root}/users").with(basic_auth: [username, password]).to_raise(exception)
    expect { @confrere.users.retrieve }.to raise_error(Confrere::APIError)
  end

  it "surfaces an unparseable response body as a Confrere::APIError" do
    response_values = {:status => 503, :headers => {}, :body => '[foo]'}
    exception = Faraday::Error::ClientError.new("the server responded with status 503", response_values)
    stub_request(:get, "#{@api_root}/users").with(basic_auth: [username, password]).to_raise(exception)
    expect { @confrere.users.retrieve }.to raise_error(Confrere::APIError)
  end

  context "handle_error" do
    it "includes status and raw body even when json can't be parsed" do
      response_values = {:status => 503, :headers => {}, :body => 'A non JSON response'}
      exception = Faraday::Error::ClientError.new("the server responded with status 503", response_values)
      api_request = Confrere::APIRequest.new(builder: Confrere::Request)
      begin
        api_request.send :handle_error, exception
      rescue => boom
        expect(boom.status_code).to eq 503
        expect(boom.raw_body).to eq "A non JSON response"
      end
    end

    context "when symbolize_keys is true" do
      it "sets title and detail on the error params" do
        response_values = {:status => 422, :headers => {}, :body => '{"title": "foo", "detail": "bar"}'}
        exception = Faraday::Error::ClientError.new("the server responded with status 422", response_values)
        api_request = Confrere::APIRequest.new(builder: Confrere::Request.new(symbolize_keys: true))
        begin
          api_request.send :handle_error, exception
        rescue => boom
          expect(boom.title).to eq "foo"
          expect(boom.detail).to eq "bar"
        end
      end
    end
  end
end
