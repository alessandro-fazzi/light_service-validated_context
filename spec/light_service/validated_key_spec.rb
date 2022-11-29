# frozen_string_literal: true

RSpec.describe LightService::Context::ValidatedKey do
  before do
    subject.label = 'foo'
    subject.type = 'baz'
  end

  it 'is globally aliased as VK' do
    expect(subject.class).to be(VK)
  end

  it "is a Struct" do
    expect(subject).to be_a Struct
  end

  it "has label and type attributes" do
    aggregate_failures do
      expect(subject.label).to eq('foo')
      expect(subject.type).to eq('baz')
    end
  end

  context "#to_sym" do
    it "returns the label as symbol" do
      expect(subject.to_sym).to eq(:foo)
    end
  end

  context "#to_s" do
    it "returns the label as string" do
      expect(subject.to_s).to eq('foo')
    end
  end
end
