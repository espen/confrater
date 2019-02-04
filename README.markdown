# Confrere Ruby API Wrapper

Confrere is an API wrapper for the [Confrere API](https://developer.confrere.com/).

## Important Notes

Confrere returns a `Confrere::Response` instead of the response body directly. `Confrere::Response` exposes the parsed response `body` and `headers`.

## Installation

    $ gem install confrere

## Authentication

The Confrere API authenticates using username and password which you can retrieve from your Confrere account.

## Usage

First, create a *one-time use instance* of `Confrere::Request`:

```ruby
confrere = Confrere::Request.new(username: "your client id", password: "your secret")
```

***Note*** Only reuse instances of Confrere after terminating a call with a verb, which makes a request. Requests are light weight objects that update an internal path based on your call chain. When you terminate a call chain with a verb, a request instance makes a request and resets the path.

You can set an individual request's `timeout` and `open_timeout` like this:

```ruby
confrere.timeout = 30
confrere.open_timeout = 30
```

You can read about `timeout` and `open_timeout` in the [Net::HTTP](https://ruby-doc.org/stdlib-2.3.3/libdoc/net/http/rdoc/Net/HTTP.html) doc.

Now you can make requests using the resources defined in [the Confrere's docs](https://developer.confrere.com/reference). Resource IDs
are specified inline and a `CRUD` (`create`, `retrieve`, `update`, or `delete`) verb initiates the request.

You can specify `headers`, `params`, and `body` when calling a `CRUD` method. For example:

```ruby
confrere.customers.retrieve(headers: {"SomeHeader": "SomeHeaderValue"}, params: {"query_param": "query_param_value"})
```

Of course, `body` is only supported on `create` and `update` calls. Those map to HTTP `POST` and `PUT` verbs respectively.

You can set `username`, `password`, `api_endpoint`, `timeout`, `open_timeout`, `faraday_adapter`, `proxy`, `symbolize_keys`, `logger`, and `debug` globally:

```ruby
Confrere::Request.username = "your_client_id"
Confrere::Request.password = "your_secret"
Confrere::Request.timeout = 15
Confrere::Request.open_timeout = 15
Confrere::Request.symbolize_keys = true
Confrere::Request.debug = false
```

For example, you could set the values above in an `initializer` file in your `Rails` app (e.g. your\_app/config/initializers/confrere.rb).

Assuming you've set the credentials on Confrere, you can conveniently make API calls on the class itself:

```ruby
Confrere::Request.customers.retrieve
```

***Note*** Substitute an underscore if a resource name contains a hyphen.

Pass `symbolize_keys: true` to use symbols (instead of strings) as hash keys in API responses.

```ruby
confrere = Confrere::Request.new(username: "your_client_id", password: "your_secret", symbolize_keys: true)
```

Confrere's [API documentation](https://developer.confrere.com/reference) is a list of available endpoints.

## Debug Logging

Pass `debug: true` to enable debug logging to STDOUT.

```ruby
confrere = Confrere::Request.new(username: "your_client_id", password: "your_secret", debug: true)
```

### Custom logger

Ruby `Logger.new` is used by default, but it can be overrided using:

```ruby
confrere = Confrere::Request.new(username: "your_client_id", password: "your_secret", debug: true, logger: MyLogger.new)
```

Logger can be also set by globally:

```ruby
Confrere::Request.logger = MyLogger.new
```

## Examples

### Customers

Fetch all customers:

```ruby
confrere.customers.retrieve
```

By default the Confrere API returns 50 results. To set the count to 50:

```ruby
confrere.customers.retrieve(params: {"pagesize": "100"})
```

And to retrieve the next 50 customers:

```ruby
confrere.customers.retrieve(params: {"pagesize": "100", "page": "2"})
```

Query using filters:

```ruby
confrere.customers.retrieve(params: {"filter": "contains(Name, ‘MakePlans’)"})
```

Retrieving a specific customer looks like:

```ruby
confrere.customers(customer_id).retrieve
```

Add a new customer:

```ruby
confrere.customers.create(body: {"Name": "MakePlans AS"})
```

### Fields

Only retrieve ids and names for fetched customers:

```ruby
confrere.customers.retrieve(params: {"select": "Id, Name"})
```

### Error handling

Confrere raises an error when the API returns an error.

`Confrere::ConfrereError` has the following attributes: `title`, `detail`, `body`, `raw_body`, `status_code`. Some or all of these may not be
available depending on the nature of the error. For example:

```ruby
begin
  confrere.customers.create(body: body)
rescue Confrere::ConfrereError => e
  puts "Houston, we have a problem: #{e.message} - #{e.raw_body}"
end
```

### Other

You can set an optional proxy url like this (or with an environment variable CONFRERE_PROXY):

```ruby
confrere.proxy = 'http://your_proxy.com:80'
```

You can set a different [Faraday adapter](https://github.com/lostisland/faraday) during initialization:

```ruby
confrere = Confrere::Request.new(username: "your_client_id", password: "your_secret", faraday_adapter: :net_http)
```

#### Initialization

```ruby
confrere = Confrere::Request.new(username: "your_client_id", password: "your_secret")
```

## Thanks

Thanks to everyone who has [contributed](https://github.com/espen/confrere/contributors) to Confrere's development.

## Credits

Based on [Gibbon](https://github.com/amro/gibbon) by [Amro Mousa](https://github.com/amro).

## Copyright

* Copyright (c) 2010-2017 Espen Antonsen and Amro Mousa. See LICENSE.txt for details.