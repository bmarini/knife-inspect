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

You can use it with your favorite Continuous Integration tool, it returns 0
when everything is in sync or 1 if it's not.

## Frequently Asked Questions

### How is it different [from knife diff](http://docs.opscode.com/knife_diff.html)?

* It returns the proper return code, so you can [use it with a Continuous Integration tool](https://blog.5apps.com/2014/01/07/using-travis-to-make-sure-your-chef-repo-and-server-are-in-sync.html)
* `knife diff` seems to expect local roles to be json files, knife-inspect supports both JSON and Ruby.
* It's my personal opinion, but I think the output from knife-inspect is more readable. Also I don't understand some of the errors I'm getting with `knife diff` (`Only in .: clients` for example)
* I actually didn't know there was a built-in `knife diff` command.

## Contributors

(in alphabetical order)

* Adam Sinnett ([@quandrum](https://github.com/quandrum))
* Eric Saxby ([@sax](https://github.com/sax))
* Dan Buch ([@meatballhat](@https://github.com/meatballhat))
* Kirt Fitzpatrick ([@kirtfitzpatrick](https://github.com/kirtfitzpatrick))

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Do not bump the version number
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
