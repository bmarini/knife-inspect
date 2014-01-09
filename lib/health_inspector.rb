# encoding: UTF-8
require "health_inspector/version"
require "health_inspector/color"
require "health_inspector/context"
require "health_inspector/pairing"
require "health_inspector/checklists/base"
require "health_inspector/checklists/cookbooks"
require "health_inspector/checklists/data_bags"
require "health_inspector/checklists/data_bag_items"
require "health_inspector/checklists/environments"
require "health_inspector/checklists/roles"
require 'chef/rest'
require 'chef/version'

module HealthInspector
end
