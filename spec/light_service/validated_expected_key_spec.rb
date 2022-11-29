# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe 'An action with validated expected keys' do
  let(:result) { action.execute(args) }

  context 'when validating presence of a string' do
    let(:action) { ActionExpectingStrictString }

    context 'when the string is not in context' do
      let(:args) { {} }

      it 'raises exception' do
        expect { result }
          .to raise_error(LightService::ExpectedKeysNotInContextError)
          .with_message('expected :email to be in the context during ActionExpectingStrictString')
      end
    end

    context 'when the string is in context' do
      let(:args) { { :email => 'foo@example.com' } }

      it 'succeeds' do
        expect(result).to be_success
      end
    end

    context 'when the string has a default value' do
      let(:action) { ActionExpectingStrictStringWithDefault }

      context 'when the string is not in context' do
        let(:args) { {} }

        it 'succeeds' do
          expect(result).to be_success
        end

        it 'is set to the default value' do
          expect(result.email).to eq('default@example.com')
        end
      end
    end

    context 'when the string has a coercion' do
      let(:action) { ActionExpectingCoercibleString }

      context 'when a symbol is in context instead of a string' do
        let(:args) { { :email => :'symbol@example.com' } }

        it 'succeeds' do
          expect(result).to be_success
        end

        it 'is coerced to the required type' do
          expect(result.email).to eq('symbol@example.com')
        end
      end

      context 'when a non-coercible value is in context' do
        let(:action) { ActionExpectingCoercibleInteger }
        let(:args) { { :number => 'fourtytwo' } }

        it 'raises exception' do
          expect { result }
            .to raise_error(LightService::ExpectedKeysNotInContextError)
            .with_message('invalid value for Integer(): "fourtytwo"')
        end
      end
    end
  end

  context 'when validating it is a specific class' do
    let(:action) { ActionExpectingCustomClass }

    context 'with an object of another class' do
      let(:args) { { :klass => (FooClass = Class.new).new } }

      it 'raises excpeption' do
        expect { result }
          .to raise_error(LightService::ExpectedKeysNotInContextError)
          .with_message(/violates constraints \(type\?\(CustomClass, #<FooClass:[^>]*>\) failed\)/)
      end
    end

    context 'with an object of the expected class' do
      let(:args) { { :klass => ::CustomClass.new } }

      it 'succeeds' do
        expect(result).to be_success
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
