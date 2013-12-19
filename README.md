# Creep

Automatically scrapes a website, and returns the sitemap as a hash, **[like this](https://gist.github.com/christianbundy/a369dd72aac534fed277/raw/bb0f763a6c02acca8bec86c2e653a61cdb5fd170/scrape)**.

## Installation

```sh
$ gem install 'load'
$ load christianbundy/creep
$ cd creep
$ bundle install
```

## Usage

```sh
$ bin/creep # creeps on https://www.joingrouper.com/
$ bin/creep 'http://example.com'
```

## Documentation

```sh
$ yard server
```

## Testing

```sh
$ rake
```
