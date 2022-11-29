# frozen_string_literal: true

RSpec.describe LightService::ValidatedContext do
  it "has a version number" do
    expect(LightService::ValidatedContext::VERSION).not_to be nil
  end
end
