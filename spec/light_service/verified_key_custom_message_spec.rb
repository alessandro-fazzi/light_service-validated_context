# frozen_string_literal: true

RSpec.describe 'A failed action with custom validation message on its key' do
  let(:args) { { :integer => 'string' } }
  let(:result) { action.execute(args) }

  context 'when custom message is a string' do
    let(:action) { ActionWithCustomValidationMessage }

    it 'populates message with custom error' do
      expect { result }
        .to raise_error(LightService::ExpectedKeysNotInContextError)
        .with_message('Custom validation message')
    end
  end

  context 'when custom message is a symbol' do
    let(:action) { ActionWithCustomValidationMessageI18n }

    it 'populates message with custom error' do
      expect { result }
        .to raise_error(LightService::ExpectedKeysNotInContextError)
        .with_message('Custom validation message from i18n')
    end
  end

  context 'when action is required to fail on validation errors' do
    let(:action) { ActionWithCustomValidationMessageNoRaise }
    it 'populates message with custom error' do
      expect(result.message).to eq('Custom validation message')
    end
  end
end
