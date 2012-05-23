## 0.0.6 ( 2012-05-23)

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