require 'spec_helper'

describe VendingMachine::Exchanger do
  subject { described_class.call(amount, coins) }

  describe 'check request/response' do
    let(:coins) do
      [
        {
          value: 2,
          quantity: 5,
        },
        {
          value: 1,
          quantity: 5,
        },
      ]
    end

    context 'on success' do
      context 'enough money' do
        let(:amount) { 5 }

        it 'returns correct object' do
          expect(subject).to eq({ 2 => 2, 1 => 1 })
        end
      end

      context 'zero amount' do
        let(:amount) { 0 }

        it 'returns correct object' do
          expect(subject).to be_empty
        end
      end
    end

    context 'on failure' do
      context 'not enough money' do
        let(:amount) { 50 }

        it 'returns correct object' do
          expect(subject).to be_empty
        end
      end

      context 'negative amount' do
        let(:amount) { -1 }

        it 'returns correct object' do
          expect(subject).to be_empty
        end
      end
    end
  end

  describe 'check algorithm' do
    let(:coins) do
      [
        {
          value: 1,
          quantity: 5,
        },
        {
          value: 2,
          quantity: 5,
        },
        {
          value: 5,
          quantity: 5,
        },
      ]
    end

    context 'for 2' do
      let(:amount) { 2 }

      it 'success' do
        expect(subject).to eq({ 2 => 1 })
      end
    end

    context 'for 10' do
      let(:amount) { 10 }

      it 'success' do
        expect(subject).to eq({ 5 => 2 })
      end
    end

    context 'for 8' do
      let(:amount) { 8 }

      it 'success' do
        expect(subject).to eq({ 5 => 1, 2 => 1, 1 => 1 })
      end
    end

    context 'for 20' do
      let(:amount) { 15 }

      it 'success' do
        expect(subject).to eq({ 5 => 3 })
      end
    end
  end
end
