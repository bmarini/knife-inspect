[![Build Status](https://secure.travis-ci.org/bmarini/health_inspector.png)](http://travis-ci.org/bmarini/health_inspector)

## Summary

`health_inspector` is a knife plugin that inspects your chef repo as it
compares to what is on your chef server. You can inspect your entire repo,
or individual components.

## Usage

    $ gem install health_inspector
    $ cd [chef repo]

## Knife Ccmmands

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
