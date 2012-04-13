# Instruments

Instruments enables out-of-the-box instrumentation on database & HTTP
activities. Instruments supports the following libraries:

* sinatra
* sequel
* excon

## Installation

Add this line to your application's Gemfile:

gem 'instruments'

And then execute:

$ bundle

Or install it yourself as:

$ gem install instruments

## Usage

Provide Instruments with an object (or module) and a method
and it will call the method passing a Hash containing the
instrumentation data for each time instruments records a metric.

### Sinatra

#### Modular Application

```ruby
require "sinatra/base"
require "instruments"
Instruments.defaults = {
  :logger => Kernel,
  :method => :puts
}

class API < Sinatra::Base
  register Sinatra::Instruments
  instrument_routes

  get "/hello/:name" do
    params[:name]
  end
end
```

#### Classic Application

```ruby
require "sinatra"
require "instruments"
Instruments.defaults = {
  :logger => Kernel,
  :method => :puts
}

instrument_routes
get "/hello/:name" do
  params[:name]
end
```

When you hit this endpoint, you will see the following
in your log stream:

```
lib=sinatra action="http-request" method="get" route="/hello/:name" status=200 elapsed=0.001
```

### Sequel

```ruby
require "sequel"
require "instruments"

db = Sequel.connect(ENV["DATABASE_URL"])
db.execute("select 1")
```

Will produce:

```
lib=sequel action=select elapsed_time=0.1 sql="select 1"
```

### Excon

```ruby
require "excon"
require "instruments"

conn = Excon.new("https://www.heroku.com")
conn.get
```

Will produce:

```
lib=excon action=http-request elapsed=0
```

## TODO

* rest-client
* queue_classic
* redis

## Links

* https://github.com/sinatra/sinatra/issues/499
* https://github.com/jeremyevans/sequel/pull/465

## Contributors

* @konstantinhaase
* @mmcgrana
* @nzoschke
* @jeremyevans

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
