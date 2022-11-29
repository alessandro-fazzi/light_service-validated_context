# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe 'An action with validated promised keys' do
  context 'when validating presence of a string' do
    let(:result) { action.execute }

    context 'when the string is not in context' do
      let(:action) { ActionPromisingStrictStringButItDoesNot }

      it 'raises exception' do
        expect { result }
          .to raise_error(LightService::PromisedKeysNotInContextError)
          .with_message('promised :email to be in the context during ActionPromisingStrictStringButItDoesNot')
      end
    end

    context 'when the string is in context' do
      let(:action) { ActionPromisingStrictString }

      it 'succeeds' do
        expect(result).to be_success
      end
    end

    context 'when the string has a default value' do
      let(:action) { ActionPromisingStrictStringWithDefault }

      context 'when the string is not in context' do
        it 'succeeds' do
          expect(result).to be_success
        end

        it 'is set to the default value' do
          expect(result.email).to eq('default@example.com')
        end
      end
    end

    context 'when the string has a coercion' do
      let(:action) { ActionPromisingCoercibleString }

      context 'when a symbol is in context instead of a string' do
        it 'succeeds' do
          expect(result).to be_success
        end

        it 'is coerced to the required type' do
          expect(result.email).to eq('symbol@example.com')
        end
      end
    end

    context 'when a non-coercible value is in context' do
      let(:action) { ActionPromisingCoercibleInteger }

      it 'raises exception' do
        expect { result }
          .to raise_error(LightService::PromisedKeysNotInContextError)
          .with_message('invalid value for Integer(): "fourtytwo"')
      end
    end

    context 'when the value is constrained and the constrain is not respected' do
      let(:action) { ActionPromisingCoercibleIntegerWithIgnoredConstain }

      it 'raises exception' do
        expect { result }
          .to raise_error(LightService::PromisedKeysNotInContextError)
          .with_message('"42" violates constraints (lteq?(40, 42) failed)')
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
