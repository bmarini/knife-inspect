[![Gem Version](https://badge.fury.io/rb/knife-inspect.png)](http://badge.fury.io/rb/knife-inspect)
[![Build Status](https://secure.travis-ci.org/bmarini/knife-inspect.png)](http://travis-ci.org/bmarini/knife-inspect)
[![Code Climate](https://codeclimate.com/github/bmarini/knife-inspect.png)](https://codeclimate.com/github/bmarini/knife-inspect)
[![Coverage Status](https://coveralls.io/repos/bmarini/knife-inspect/badge.png)](https://coveralls.io/r/bmarini/knife-inspect)

## Summary

`knife-inspect` is a knife plugin that inspects your chef repo as it
compares to what is on your chef server. You can inspect your entire repo,
or individual components.

## Usage

    $ gem install knife-inspect
    $ cd [chef repo]

## Knife Commands

    knife inspect

    knife cookbook inspect
    knife cookbook inspect [COOKBOOK]

    knife data bag inspect
    knife data bag inspect [BAG]
    knife data bag inspect [BAG] [ITEM]

    knife environment inspect
    knife environment inspect [ENVIRONMENT]

    knife role inspect
    knife role inspect [ROLE]

## What it does

So far it checks if...

* your cookbooks are in sync
* you have uncommitted changes in a cookbook (assuming your cookbooks are in
  their own git repos)
* you have commits in a cookbook that haven't been pushed to your remote
  (assuming your cookbooks are in their own git repos)
* your data bags are in sync
* your data bag items are in sync
* your environments are in sync
* your roles are in sync

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Do not bump the version number
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
