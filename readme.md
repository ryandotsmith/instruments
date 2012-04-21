# Instruments

Instruments enables out-of-the-box instrumentation on database & HTTP
activities. Instruments supports the following libraries:

* sinatra
* sequel
* excon
* queue_classic

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
  :method => :puts,
  :default_data => {:app => "your-app-name"}
}

class API < Sinatra::Base
  register Sinatra::Instrumentation
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
* redis

## Links

* https://github.com/sinatra/sinatra/issues/499
* https://github.com/jeremyevans/sequel/pull/465

## Contributors

* @konstantinhaase
* @mmcgrana
* @nzoschke
* @jeremyevans
