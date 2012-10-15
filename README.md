[![Build Status](https://secure.travis-ci.org/bmarini/health_inspector.png)](http://travis-ci.org/bmarini/health_inspector)

## Summary

`health_inspector` is tool to inspect your chef repo as it compares to what is
on your chef server.

## Usage

    $ gem install health_inspector
    $ cd [chef repo] && health_inspector inspect

Run `health_inspector help` for more options

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
