module Confrater
  class APIRequest

    def initialize(builder: nil)
      @request_builder = builder
    end

    def post(params: nil, headers: nil, body: nil)
      ensure_credentials

      begin
        response = self.rest_client.post do |request|
          configure_request(request: request, params: params, headers: headers, body: MultiJson.dump(body))
        end
        parse_response(response)
      rescue => e
        handle_error(e)
      end
    end

    def patch(params: nil, headers: nil, body: nil)
      ensure_credentials

      begin
        response = self.rest_client.patch do |request|
          configure_request(request: request, params: params, headers: headers, body: MultiJson.dump(body))
        end
        parse_response(response)
      rescue => e
        handle_error(e)
      end
    end

    def put(params: nil, headers: nil, body: nil)
      ensure_credentials

      begin
        response = self.rest_client.put do |request|
          configure_request(request: request, params: params, headers: headers, body: MultiJson.dump(body))
        end
        parse_response(response)
      rescue => e
        handle_error(e)
      end
    end

    def get(params: nil, headers: nil)
      ensure_credentials

      begin
        response = self.rest_client.get do |request|
          configure_request(request: request, params: params, headers: headers)
        end
        parse_response(response)
      rescue => e
        handle_error(e)
      end
    end

    def delete(params: nil, headers: nil)
      ensure_credentials

      begin
        response = self.rest_client.delete do |request|
          configure_request(request: request, params: params, headers: headers)
        end
        parse_response(response)
      rescue => e
        handle_error(e)
      end
    end

    protected

    # Convenience accessors

    def username
      @request_builder.username
    end

    def password
      @request_builder.password
    end

    def api_endpoint
      @request_builder.api_endpoint
    end

    def api_environment
      @request_builder.api_environment
    end

    def timeout
      @request_builder.timeout
    end

    def open_timeout
      @request_builder.open_timeout
    end

    def proxy
      @request_builder.proxy
    end

    def adapter
      @request_builder.faraday_adapter
    end

    def symbolize_keys
      @request_builder.symbolize_keys
    end

    # Helpers

    def handle_error(error)
      error_params = {}

      begin
        if error.is_a?(Faraday::ClientError) && error.response
          error_params[:status_code] = error.response[:status]
          error_params[:raw_body] = error.response[:body]

          parsed_response = MultiJson.load(error.response[:body], symbolize_keys: symbolize_keys)

          if parsed_response
            error_params[:body] = parsed_response

            title_key = symbolize_keys ? :title : "title"
            detail_key = symbolize_keys ? :detail : "detail"

            error_params[:title] = parsed_response[title_key] if parsed_response[title_key]
            error_params[:detail] = parsed_response[detail_key] if parsed_response[detail_key]
          end

        end
      rescue MultiJson::ParseError
      end

      error_to_raise = APIError.new(error.message, error_params)

      raise error_to_raise
    end

    def configure_request(request: nil, params: nil, headers: nil, body: nil)
      if request
        request.params.merge!(params) if params
        request.headers['Content-Type'] = 'application/json'
        request.headers.merge!(headers) if headers
        request.body = body if body
        request.options.timeout = self.timeout
        request.options.open_timeout = self.open_timeout
      end
    end

    def rest_client
      Faraday.new(self.api_url, proxy: self.proxy, ssl: { version: "TLSv1_2" }) do |faraday|
        faraday.response :raise_error
        faraday.adapter adapter
        if @request_builder.debug
          faraday.response :logger, @request_builder.logger, bodies: true
        end
        faraday.request :authorization, :basic, self.username, self.password
      end
    end

    def parse_response(response)
      parsed_response = nil

      if response.body && !response.body.empty?
        if /json/.match(response.headers['content-type'])
          begin
            headers = response.headers
            body = MultiJson.load(response.body, symbolize_keys: symbolize_keys)
            parsed_response = Response.new(headers: headers, body: body)
          rescue MultiJson::ParseError
            error_params = { title: "UNPARSEABLE_RESPONSE", status_code: 500 }
            error = APIError.new("Unparseable response: #{response.body}", error_params)
            raise error
          end
        elsif /text/.match(response.headers['content-type'])
          headers = response.headers
          body = response.body
          parsed_response = Response.new(headers: headers, body: body)
        else
          error_params = { title: "UNPARSEABLE_RESPONSE_TYPE", status_code: 500 }
          error = APIError.new("Unparseable response: #{response.body}", error_params)
          raise error
        end
      end

      parsed_response
    end

    def ensure_credentials
      username = self.username
      password = self.password
      unless username && password
        raise Confrater::ConfrereError, "You must set credentials prior to making a call"
      end
    end

    def api_url
      base_api_url + @request_builder.path
    end

    def base_api_url
      case @request_builder.api_environment
      when :production
        "https://api.confrere.com/v1/"
      end
    end
  end
end
