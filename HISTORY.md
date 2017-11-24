## 0.16.1 ( 2017-11-24 )

* Support Chef 13 ([#51][#51]). No other change.


## 0.16.0 ( 2017-03-14 )

* Remove explicit dependency on rack (let chef-zero deal with it) ([#50][#50])
  Thanks for catching that @jonlives! I introduced the issue in 0.15.0


## 0.15.0 ( 2016-08-03 )

* New (old) feature: Chef 11 is supported again! ([#46][#46]). Thanks @kdaniels!
* Updated development dependencies and set the version of rack to < 2
* Switch to ffi-yajl like Chef


## 0.14.1 ( 2016-07-22 )

* Bug fix: explicitly call the `HealthInspector` module with a root prefix
  ([#46][#46]). This prevents a crash when running knife inspect in some cases


## 0.14.0 ( 2016-04-22 )

* New feature: Allow to deactivate inspection by component ([#34][#34]). Thanks
@kamaradclimber

```
--no-cookbooks --no-data-bags --no-data-bag-items --no-environments --no-roles
```


## 0.13.1 ( 2016-02-16 )

* Don't rely on deprecated auto-inflation of JSON data. Switch to `#from_hash`
instead of `#json_create` for Chef resources


## 0.13.0 ( 2016-02-16 )

* Fixed compatibility with Chef 12.7.2 ([#42][#42])


## 0.12.0 ( 2015-02-05 )

* Bumped Chef compatibility to support Chef 12 ([#36][#36]). This is otherwise
identical to 0.11.1


## 0.11.1 ( 2015-01-26 )

* Bug fix: Use `Gem::Version` to parse Chef's version ([#35][#35]) (thanks
  @docwhat!)


## 0.11.0 ( 2014-10-27 )

* Bug fix: recursive diff would stop if two keys were identical between local
  and server ([#23][#23])


## 0.10.0 ( 2014-10-13 )

* Feature: Support cookbooks that only have a `metadata.json` file but no
  `metadata.rb` (Berkshelf does that) ([#5][#5])
* Feature: Use parallel lib to speed up REST API operations ([#27][#27])

## 0.9.2 ( 2014-08-11 )

* Bug fix: Fixed regression in the regression fix for Chef 10 that broke
knife-inspect with Chef 11
  ([#25][#25])

## 0.9.1 ( 2014-08-11 )

* Bug fix: Fixed regression that broke knife-inspect with Chef 10.32.2
  (and probably previous Chef 10 versions)
  ([#25][#25])
This release was yanked from RubyGems due to a bug. Please download 0.9.2
instead.

## 0.9.0 ( 2014-08-11 )

* Bug fix: update yajl-ruby dependency to 1.2, 1.1 segfaulted in some cases
  ([#22][#22])
* Feature: Make output not use unicode when stdout is not a TTY. (Ben Hughes)
  ([#21][#21])
* Bug fix: fix a bug with git submodules in some cases
  ([#7][#7])

## 0.8.0 ( 2014-01-10 )

* New feature: Support data bags, data bag items, environments and roles inside
  folders.
* Add initial specs for the checklists.
* General cleanup: got rid of some duplicate code and dead code.

## 0.7.1 ( 2014-01-06 )

* Small bug fix: `knife data bag inspect` returned the status code only for
  data bag items, not data bags.

## 0.7.0 ( 2014-01-03 )

> It's alive! Thanks a lot to Ben Marini for starting this project!
> I'm happy to be the new maintainer of knife-inspect, this is an essential
> tool for all users Chef Server users.
>
> -- [Greg Karékinian](https://github.com/gregkare)

* The plugin is now compatible with Chef 11 ([#6][#6])
* Fix inspect for something non-existent ([#2][#2])
* Exit with the proper status (0 for success, 1 for failure) ([#14][#14])
* Remove dependency on thor ([#15][#15])
* Specify version of the yajl-ruby gem (same as Chef)

## 0.6.2 ( 2013-02-27 )

* Be indifferent about symbols and strings for hash keys when diff'ing

## 0.6.0 ( 2012-11-1 )

* Add knife plugins for all existing functionality:
  - knife inspect
  - knife cookbook inspect [COOKBOOK]
  - knife data bag inspect [BAG] [ITEM]
  - knife environment inspect [ENVIRONMENT]
  - knife role inspect [ROLE]

* Lost support for quiet-sucess option (We can add that back, or make a quiet
  options that just returns exit status).

## 0.5.2 ( 2012-10-19 )

* Make loading of Chef Config a little more robust.

## 0.5.1 ( 2012-10-15 )

* Ignore _default environment if it only exists on the server.

## 0.5.0 ( 2012-10-14 )

* Switch to RSpec
* Add some test coverage (still needs much more).
* Add option to suppress terminal output on successful checks.
* Add option to not use ansi color output.
* Make cookbook version comparison use Chef's native version class.

## 0.4.1 ( 2012-09-28 )

* Fix a bug I created in last release when passing no component.

## 0.4.0 ( 2012-09-28 )

* Make `inspect` the default task
* Add ability to specify individual components:

      health_inspector inspect cookbooks

## 0.3.1 ( 2012-09-27 )

* Stop shelling out for knife commands, use Chef API directly for everything.

## 0.3.0 ( 2012-09-26 )

* Add new check for cookbooks: checksum comparison for each file.

## 0.2.1 ( 2012-09-26 )

* Fix 1.8.7 incompatibility introduced in last release (String#prepend).

## 0.2.0 ( 2012-09-25 )

* Add a better diff output.
* Add diff output to data bag items.
* Switch to yajl-ruby to fix JSON parsing issues (Chef uses this also).

## 0.1.0 ( 2012-09-24 )

* Bump Chef dependency version up to 10.14
* Add support for JSON environments.
* Add support for JSON roles.
* Display the diff between JSONs when JSON data doesn't match.

## 0.0.6 ( 2012-05-23 )

* Depend on Chef 0.10.8, since it depends on a later version of the json gem.
  An earlier version of the json gem was throwing incorrect parse errors.

## 0.0.5 ( 2012-04-13 )

* Fix #2, exception when a data bag item json file doesn't exist locally.

## 0.0.4 ( 2012-04-09 )

* Add checks for data bags, data bag items, environments, and roles.

## 0.0.3 ( 2012-03-27 )

* Read cookbook paths from knife config file instead of hardcoding /cookbooks.

## 0.0.2 ( 2012-03-27 )

* Make sure we iterate over actual cookbooks in cookbooks folder.

## 0.0.1 ( 2012-03-27 )

* Initial release.


[#15]: https://github.com/bmarini/knife-inspect/issues/15
[#14]: https://github.com/bmarini/knife-inspect/issues/14
[#6]: https://github.com/bmarini/knife-inspect/issues/6
[#2]: https://github.com/bmarini/knife-inspect/issues/2
[#21]: https://github.com/bmarini/knife-inspect/issues/21
[#22]: https://github.com/bmarini/knife-inspect/issues/22
[#7]: https://github.com/bmarini/knife-inspect/issues/7
[#25]: https://github.com/bmarini/knife-inspect/issues/25
[#5]: https://github.com/bmarini/knife-inspect/issues/5
[#27]: https://github.com/bmarini/knife-inspect/issues/27
[#23]: https://github.com/bmarini/knife-inspect/issues/23
[#35]: https://github.com/bmarini/knife-inspect/issues/35
[#42]: https://github.com/bmarini/knife-inspect/issues/42
[#34]: https://github.com/bmarini/knife-inspect/pull/34
[#46]: https://github.com/bmarini/knife-inspect/pull/46
[#50]: https://github.com/bmarini/knife-inspect/pull/50
[#51]: https://github.com/bmarini/knife-inspect/pull/51
