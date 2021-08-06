require 'spec_helper'

describe VendingMachine::Display do
  let(:prompt_double) { double }

  subject { described_class.new(prompt_double) }

  context '#choose_coins' do
    let(:nominals) { [50, 20, 10] }

    it 'successfully chose' do
      expect(prompt_double).to receive(:say)
      expect(prompt_double).to receive(:select).with('Insert coin nominal:', nominals, anything).and_return(50)
      expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(3)
      expect(prompt_double).to receive(:no?).with("Do you have more coins?").and_return(true)

      expect(subject.choose_coins(nominals)).to eq({ 50 => 3 })
    end
  end

  context '#select_product' do
    let(:products) { ['N1', 'N2'] }

    it 'receive correct params' do
      expect(prompt_double).to receive(:select).with('Choose a product:', products)

      subject.select_product(products)
    end
  end

  context '#give_back_coins' do
    context 'with no coins' do
      let(:coins) { {} }

      it 'do nothing' do
        expect(prompt_double).to_not receive(:ok)

        subject
      end
    end

    context 'with several coins' do
      let(:coins) { { 1 => 2, 2 => 2 } }

      it 'do nothing' do
        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with("Nominal: 1 x Quantity: 2")
        expect(prompt_double).to receive(:ok).with("Nominal: 2 x Quantity: 2")

        subject.give_back_coins(coins)
      end
    end
  end
end
