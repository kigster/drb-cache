# DRb::Cache

`DRb::Cache` is a rather simple caching library that works across multiple ruby processes running one one or more hosts. The server process can be started on demand if its not already running, and if the URL points to the localhost.

The cache is stored entirely in memory of the server process, and is cleared upon server process shutdown.

You can think of `DRb::Cache` as an in-memory hash that can be used for caching things, except that the code running in another ruby VM process can access it as well.

In other words, `DRb::Cache` is kind of like `memcached` without the need to install any additional services, that's started as needed, and is implemented in pure ruby. Another corollary of the above is that `memcached` is much much faster, and is still the recommended way to go if you need a high-performance cache.

## Motivation

  1. Sometimes it can be useful to be able to cache data *between multiple ruby processes* residing on the same host. And yet, it is difficult to achieve quickly or in a cross-platform way, without resorting to using external native libraries such a [`localmemcache`](https://github.com/sck/localmemcache) gem, or system services such as [`memcached`](https://memcached.org/) or [`redis`](http://redis.io/).

  2. Sometimes *raw performance is not the top factor* in choosing how to cache data. For example, caching user input does not require blazing speed for cache query.

If you are looking for a pure ruby implementation of multi-process caching .of a that does not have any external dependencies, and yet provides


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'drb-cache'
```

And then execute `bundle`, or install it yourself as:

    $ gem install drb-cache

## Usage

You can use the library either via the command line interface and the provided executable `drb-cache`, or via ruby.

### Ruby

In ruby, caching requires two phases:

 1. start a new server (or ensure one is already running).
 2. create a client instance and use it to use the cache.

You can use the `DRb::Cache::Client` class to do all of the above, or you can additionally use `DRb::Cache::Server` to offer more granular access to managing the server process.

#### Example

Below we are using a global ruby variable to store the reference to the cache client _within the current ruby process_, but we could have also used a constant, or — perhaps the recommended way — is to use ruby's `Singleton` module to wrap around the cache

```ruby
require 'drb/cache/client'
# Create a client and connect to an existing server,
# or have the client start a server implicitly.
$cache_client = DRb::Cache::Client.new(
  host: '127.0.0.1',
  port: 9999
).freeze

$cache_client.server          # => <DRb::Cache::Server#23414234>
$cache_client.server.running? # => true

$cache_client[:foo] = :bar
$cache_client[:foo]           # => :bar
```

#### Explictly Start the Server Process

```ruby
require 'drb/cache/server'

# to ensure we start a local server
$cache_server = DRb::Cache::Server.new(port: 9999)

$cache_server.running? # => false
$cache_server.start    # => true
$cache_server.running? # => true

# now we can create a client by passing in the server
$cache_client = DRb::Cache::Client(server: $cache_server)
$cache_client[:foo]    # => :bar
```

### CLI


```bash
$ gem install drb-cache
$ drb-cache --at 127.0.0.1:8000
$ drb-cache --at 127.0.0.1:8000 --expire-in 60 foo=bar pi=3.1415926
$ drb-cache --at 127.0.0.1:8000 --get foo x
foo=bar
pi=3.1415926
$ sleep 60
$ drb-cache --client --server 127.0.0.1:8000 --get foo
$
```

Command line usage is such that it could be possible to expose cached data as shell variables. For example, one can store shared environment in the cache, and evaluate the `drb-cache ... --get var1 var2 ` in a sub-shell, which presumably needs access to these variables.


You can also use a shorthand version of all options:

```bash
$ gem install drb-cache
$ drb-cache '@127.0.0.1:8000'
$ drb-cache '@127.0.0.1:8000' foo=bar{10} hi=lo
$ sleep 11
$ drb-cache '@127.0.0.1:8000' foo hi
lo
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/drb-cache.

## Acknowledgements

This library started as a fork of the [`coin`](https://github.com/hopsoft/coin) ruby gem, and owes both the inspiration and some of its code the `coin`'s original author [Nathan Hopkins](https://github.com/hopsoft).
