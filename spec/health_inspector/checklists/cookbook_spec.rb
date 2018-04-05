require 'spec_helper'

RSpec.describe HealthInspector::Checklists::Cookbook do
  let(:pairing) do
    described_class.new(health_inspector_context, :name => 'cookbook_one')
  end

  it 'detects if an item does not exist locally' do
    pairing.server = '0.0.1'
    pairing.local  = nil
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('exists on server but not locally')
  end

  it 'detects if an item does not exist on server' do
    pairing.server = nil
    pairing.local  = '0.0.1'
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('exists locally but not on server')
  end

  it 'detects if an item is different' do
    pairing.server = '0.0.1'
    pairing.local  = '0.0.2'
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('chef server has 0.0.1 but local version is 0.0.2')
  end

  it 'detects if an item is the same' do
    cookbook_version = double('Chef::CookbookVersion')
    if Gem::Version.new(Chef::VERSION) < Gem::Version.new('13.0.0')
      allow(cookbook_version).to receive(:manifest).and_return({
        attributes: [],
        definitions: [],
        files: [],
        libraries: [],
        providers: [],
        recipes: [{ "path" => "recipes/default.rb", "checksum" => "d41d8cd98f00b204e9800998ecf8427e" }],
        root_files: [{"path" => "metadata.rb", "checksum" => "feaa135db12fdc37c3cd155d16f80b5f"}],
        resources: [],
        templates: []
      })
    else
      allow(cookbook_version).to receive(:files_for).with(:attributes).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:definitions).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:files).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:libraries).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:providers).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:recipes).and_return([{ "path" => "recipes/default.rb", "checksum" => "d41d8cd98f00b204e9800998ecf8427e" }])
      allow(cookbook_version).to receive(:files_for).with(:root_files).and_return([{"path" => "metadata.rb", "checksum" => "feaa135db12fdc37c3cd155d16f80b5f"}])
      allow(cookbook_version).to receive(:files_for).with(:resources).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:templates).and_return([])
    end
    expect(Chef::CookbookVersion).to receive(:load)
      .with('cookbook_one', '0.0.1')
      .and_return(
        cookbook_version
    )
    expect(pairing).to receive(:validate_changes_on_the_server_not_in_the_repo)
    pairing.server = '0.0.1'
    pairing.local  = '0.0.1'
    pairing.validate

    expect(pairing.errors).to be_empty
  end

  it 'detects if an item is not on the server' do
    cookbook_version = double('Chef::CookbookVersion')

    if Gem::Version.new(Chef::VERSION) < Gem::Version.new('13.0.0')
      allow(cookbook_version).to receive(:manifest).and_return({
        attributes: [],
        definitions: [],
        files: [],
        libraries: [],
        providers: [],
        recipes: [],
        root_files: [{"path" => "metadata.rb", "checksum" => "feaa135db12fdc37c3cd155d16f80b5f"}],
        resources: [],
        templates: []
      })
    else
      allow(cookbook_version).to receive(:files_for).with(:attributes).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:definitions).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:files).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:libraries).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:providers).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:recipes).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:root_files).and_return([{"path" => "metadata.rb", "checksum" => "feaa135db12fdc37c3cd155d16f80b5f"}])
      allow(cookbook_version).to receive(:files_for).with(:resources).and_return([])
      allow(cookbook_version).to receive(:files_for).with(:templates).and_return([])
    end
    expect(Chef::CookbookVersion).to receive(:load)
      .with('cookbook_one', '0.0.1')
      .and_return(
        cookbook_version
    )
    expect(pairing).to receive(:validate_changes_on_the_server_not_in_the_repo)
    pairing.server = '0.0.1'
    pairing.local  = '0.0.1'
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq("has a checksum mismatch between server and repo in\n    recipes/default.rb does not exist on the server")
  end
end
