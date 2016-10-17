# DRb::Cache

`DRb::Cache` is a caching gem that supports caching across multiple ruby processes, by using a client-server caching, with the server component started on demand as needed (and running for a configurable amount of time before shutting down). The cache is stored entirely in memory of the server process, and is, therefore, wiped out upon server shutdown. 

The cache itself is a hash-like implementation of an LRU cache with optional time expiration for the cached values.

## Why?

  1. Sometimes it can be useful to be able to cache data *between multiple ruby processes* residing on the same host. And yet, it is difficult to achieve quickly or in a cross-platform way, without resorting to using external native libraries such a [`localmemcache`](https://github.com/sck/localmemcache) gem, or system services such as [`memcached`](https://memcached.org/) or [`redis`](http://redis.io/). 

  2. Sometimes *raw performance is not the top factor* in choosing how to cache data. For example, caching user input does not require blazing speed for cache query.
 
For the use-case where we desire a pure ruby implementation that does not require installing additional services, and yet provides out-of-the-box multi-process caching, this library should hit the spot.

## Acknowledgements

This library started as a fork of the [`Coin`](https://github.com/hopsoft/coin) ruby gem, and owes both inspiration and code to its author [Nathan Hopkins](https://github.com/hopsoft).
 
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
 
#### Recommended

```ruby
  require 'drb/cache/client'
  
  # Create a client and connect to an existing server,
  # or have the client start a server implicitly.
  $cache = DRb::Cache::Client.new(
    host: '127.0.0.1', 
    port: 9999    
  )
  
  $cache.server          # => <DRb::Cache::Server#23414234>  
  $cache.server.running? # => true
  
  $cache[:foo] = :bar
  $cache[:foo]           # => :bar

```
 
#### Explictly Start the Server Process

```ruby
  require 'drb/cache/server'
  
  # to ensure we start a local server
  $cache_server = DRb::Cache::Server.new(port: 9999)
    
  $cache_server.running? # => false
  $cache_server.start    # => true
  $cache_server.running? # => true
  
  $cache = DRb::Cache::Client(server: $cache_server)
  $cache[:foo]           # => :bar
```



### CLI



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/drb-cache.

