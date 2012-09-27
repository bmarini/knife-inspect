## 0.2.1 ( 2012-09-26 )

* Fix 1.8.7 incompatibility introduced in last release (String#prepend).

## 0.2.0 ( 2012-09-25 )

* Add a better diff output.
* Add diff output to data bag items.
* Switch to yajl-ruby to fix JSON parsing issues (Chef uses this also).

## 0.1.0 ( 2012-09-24 )

* Bump Chef dependency version up to 10.14
* Add support for JSON environments
* Add support for JSON roles
* Display the diff between JSONs when JSON data doesn't match.

## 0.0.6 ( 2012-05-23 )

* Depend on Chef 0.10.8, since it depends on a later version of the json gem.
  An earlier version of the json gem was throwing incorrect parse errors.

## 0.0.5 ( 2012-04-13 )

* Fix #2, exception when a data bag item json file doesn't exist locally

## 0.0.4 ( 2012-04-09 )

* Add checks for data bags, data bag items, environments, and roles

## 0.0.3 ( 2012-03-27 )

* Read cookbook paths from knife config file instead of hardcoding /cookbooks

## 0.0.2 ( 2012-03-27 )

* Make sure we iterate over actual cookbooks in cookbooks folder

## 0.0.1 ( 2012-03-27 )

* Initial release