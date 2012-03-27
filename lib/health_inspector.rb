# encoding: UTF-8
require "health_inspector/version"
require "health_inspector/color"
require "health_inspector/context"
require "health_inspector/check"
require "health_inspector/inspector"
require "health_inspector/checklists/base"
require "health_inspector/checklists/cookbooks"
require "health_inspector/cli"
require "json"

# TODO:
# * Check if cookbook version is same as on server
# * Check if remote origin not in sync with local
module HealthInspector
end
