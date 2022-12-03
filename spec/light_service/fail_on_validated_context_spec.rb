# frozen_string_literal: true

RSpec.describe 'An action required to fail instead of raise on validation error' do
  let(:action) { ActionFailInsteadOfRaise }
  let(:result) { action.execute(args) }

  it 'implements FailOnValidationError interface' do
    aggregate_failures do
      expect(action.fail_on_validation_error?).to be true
      expect(action.throw_on_validation_error?).to be false
    end
  end

  context 'when expected keys are not in context' do
    let(:args) { {} }

    it 'does not raise exception' do
      expect { result }
        .to_not raise_error
    end

    it 'populates the error message with validation errors' do
      expect(result.message)
        .to eq('[ActionFailInsteadOfRaise][:foo] Undefined violates constraints (type?(String, Undefined) failed)')
    end
  end
end
