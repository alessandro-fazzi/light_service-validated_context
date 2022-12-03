# frozen_string_literal: true

RSpec.describe LightService::Context::ValidatedKey do
  subject(:validated_key) { described_class.new('foo', 'baz') }

  it 'is globally aliased as VK' do
    expect(validated_key.class).to be(VK)
  end

  it "has label and type attributes" do
    aggregate_failures do
      expect(validated_key.label).to eq('foo')
      expect(validated_key.type).to eq('baz')
    end
  end

  context "#to_sym" do
    it "returns the label as symbol" do
      expect(validated_key.to_sym).to eq(:foo)
    end
  end

  context "#to_s" do
    it "returns the label as string" do
      expect(validated_key.to_s).to eq('foo')
    end
  end
end
