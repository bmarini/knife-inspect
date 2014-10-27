if RUBY_VERSION > '1.9'
  require 'simplecov'
  require 'coveralls'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/spec/'
  end
end

require 'rubygems'
require 'bundler/setup'
require 'health_inspector'

module HealthInspector
  module SpecHelpers
    def repo_path
      @repo_path ||= File.expand_path('../chef-repo', __FILE__)
    end

    def health_inspector_context
      @health_inspector_context ||= double(
        :repo_path => repo_path,
        :cookbook_path => ["#{repo_path}/cookbooks"]
      )
    end
  end
end

RSpec.configure do |c|
  c.disable_monkey_patching!
  c.expose_dsl_globally = false
  c.include HealthInspector::SpecHelpers
end

RSpec.shared_examples 'a chef model' do
  let(:pairing) do
    described_class.new(health_inspector_context, :name => 'dummy')
  end

  it 'detects if an item does not exist locally' do
    pairing.server = {}
    pairing.local  = nil
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('exists on server but not locally')
  end

  it 'detects if an item does not exist on server' do
    pairing.server = nil
    pairing.local  = {}
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expect(pairing.errors.first).to eq('exists locally but not on server')
  end

  it 'detects if an item does not exist locally or on server' do
    pairing.server = nil
    pairing.local  = nil
    pairing.validate

    expect(pairing.errors.to_a).to eq(['does not exist locally or on server'])
  end
end

RSpec.shared_examples 'a chef model that can be represented in json' do
  let(:pairing) do
    described_class.new(health_inspector_context, :name => 'dummy')
  end

  it 'detects if an item is different' do
    pairing.server = { 'foo' => 'bar' }
    pairing.local  = { 'foo' => 'baz' }
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expected_errors = { 'foo' => { 'server' => 'bar', 'local' => 'baz' } }
    expect(pairing.errors.first).to eq(expected_errors)
  end

  it 'detects if a nested hash is different' do
    pairing.server = { 'foo' => { 'bar' => { 'fizz' => 'buzz' } } }
    pairing.local  = { 'foo' => { 'baz' => { 'fizz' => 'buzz' } } }
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expected_errors = {
      'foo' => {
        'bar' => { 'server' => { 'fizz' => 'buzz' }, 'local' => nil },
        'baz' => { 'server' => nil, 'local' => { 'fizz' => 'buzz' } }
      }
    }
    expect(pairing.errors.first).to eq(expected_errors)
  end

  it 'detects differences when the other keys are identical' do
    pairing.server = { 'name' => 'bar', 'foo' => { 'bar' => { 'fizz' => 'buzz' } } }
    pairing.local  = { 'name' => 'bar', 'foo' => { 'baz' => { 'fizz' => 'buzz' } } }
    pairing.validate

    expect(pairing.errors).not_to be_empty
    expected_errors = {
      'foo' => {
        'bar' => { 'server' => { 'fizz' => 'buzz' }, 'local' => nil },
        'baz' => { 'server' => nil, 'local' => { 'fizz' => 'buzz' } }
      }
    }
    expect(pairing.errors.first).to eq(expected_errors)
  end

  it 'detects if an item is the same' do
    pairing.server = { 'foo' => 'bar' }
    pairing.local  = { 'foo' => 'bar' }
    pairing.validate

    expect(pairing.errors).to be_empty
  end

  it 'detects if an string and symbol keys convert to the same values' do
    pairing.server = { 'foo' => 'bar' }
    pairing.local  = { :foo => 'bar' }
    pairing.validate

    expect(pairing.errors).to be_empty
  end

  it 'detects if matching hashes are the same' do
    pairing.server = { 'foo' => { 'bar' => 'fizz' } }
    pairing.local  = { 'foo' => { 'bar' => 'fizz' } }
    pairing.validate

    expect(pairing.errors).to be_empty
  end

  it 'detects if matching hashes with mismatched symbols and keys are the same' do
    pairing.server = { 'foo' => { 'bar' => 'fizz' } }
    pairing.local  = { :foo => { :bar => 'fizz' } }
    pairing.validate

    expect(pairing.errors).to be_empty
  end

  it 'detects if matching arrays are the same' do
    pairing.server = { 'foo' => ['bar', 'fizz'] }
    pairing.local  = { 'foo' => ['bar', 'fizz'] }
    pairing.validate

    expect(pairing.errors).to be_empty
  end

  it 'detects if matching arrays with hashes are the same' do
    pairing.server = { 'foo' => ['bar', { 'fizz' => 'buzz' }] }
    pairing.local  = { 'foo' => ['bar', { 'fizz' => 'buzz' }] }
    pairing.validate

    expect(pairing.errors).to be_empty
  end

  it 'detects if matching arrays with hashes containing symbols/strings are the same' do
    pairing.server = { 'foo' => ['bar', { 'fizz' => 'buzz' }] }
    pairing.local  = { 'foo' => ['bar', { :fizz => 'buzz' }] }
    pairing.validate

    expect(pairing.errors).to be_empty
  end
end

RSpec.shared_examples 'a knife inspect runner' do
  describe '#run' do
    context 'when passing an item as an argument' do
      let :inspect_runner do
        described_class.new ['some_item']
      end

      let :validator do
        double
      end

      let :item do
        double
      end

      it 'inspects this item' do
        expect(checklist).to receive(:new)
          .with(inspect_runner).and_return validator
        expect(validator).to receive(:load_item)
          .with('some_item').and_return item
        expect(validator).to receive(:validate_item).with(item).and_return true
        expect(inspect_runner).to receive(:exit).with true

        inspect_runner.run
      end
    end

    context 'when not passing arguments' do
      let :inspect_runner do
        described_class.new
      end

      it 'inspects all the items' do
        expect(checklist).to receive(:run).with(inspect_runner).and_return true
        expect(inspect_runner).to receive(:exit).with true

        inspect_runner.run
      end
    end
  end
end
