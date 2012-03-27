# Health Inspector

A tool to inspect your chef repo as is compares to what is on your chef server

## Usage

    $ gem install health_inspector
    $ cd [chef repo] && health_inspector inspect

Run `health_inspector help` for more options

## What is checks

So far it checks if...

* your chef server has cookbooks you don't have locally
* your chef server is missing cookbooks you have locally
* cookbook versions are not the same between server and local chef repo
* you have uncommitted changes in a cookbook (assuming your cookbook is a git repo)
* you have commits in a cookbook that haven't been pushed to your remote (assuming your cookbook is a git repo)