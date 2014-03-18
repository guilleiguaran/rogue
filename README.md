# Rogue

_Minimal HTTP server for Rack applications powered by the superpowers of others_

![Rogue by Marvel Comics](http://img1.wikia.nocookie.net/__cb20110918173744/doblaje/es/images/7/75/Rogue2.gif)

## Description

Rogue is a minimal and fast HTTP 1.1 server for Rack applications.

Rogue is powered by:
- [EventMachine](https://github.com/eventmachine/eventmachine)
- Ryan Dahl's [http-parser](https://github.com/joyent/http-parser) (based in nginx parser)
- [Rack](https://github.com/rack/rack). 

Rogue is highly inspired in [Thin](https://github.com/macournoyer/thin)

## Installation

    $ gem install rogue


## Usage

### Rails 

Add Light to your Gemfile:

```ruby
gem "rogue"
```

Run your application with Rogue:

    rails s rogue

### Sinatra

Configure Sinatra to use Rogue:

```ruby
configure { set :server, :rogue }
```

### Rack

Run rackup using rogue:

    $ rackup -s rogue
 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Copyright

Copyright (c) 2014 Guillermo Iguaran. See LICENSE for further details.
