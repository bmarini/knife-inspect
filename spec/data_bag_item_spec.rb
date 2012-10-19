require 'spec_helper'

describe HealthInspector::Checklists::DataBagItem do
  it_behaves_like "a chef model"
  it_behaves_like "a chef model that can be respresented in json"
end
