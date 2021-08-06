require 'spec_helper'

describe VendingMachine::Machine do
  let(:coins) do
    [
      {
        name: "$1.00",
        quantity: 5,
        value: 100,
      },
      {
        name: "$2.00",
        quantity: 0,
        value: 200,
      },
    ]
  end

  let(:products) do
    {
      'Coca Cola' => {
        value: 200,
        quantity: 2,
      },
    }
  end

  let(:data) do
    double(:data, coins: coins, products: products)
  end

  subject { described_class.new(data) }

  describe '#info' do
    it 'return correct values' do
      subject

      expect(coins).to match_array(
        [
          {
            name: "$1.00",
            quantity: 5,
            value: 100,
          },
          {
            name: "$2.00",
            quantity: 0,
            value: 200,
          },
        ]
      )

      expect(products).to eq({
        'Coca Cola' => {
          value: 200,
          quantity: 2,
        },
      })
    end
  end

  describe '#acceptable_coin_nominals' do
    it 'return correct values' do
      expect(subject.acceptable_coin_nominals).to match_array({
        "$1.00" => 100,
        "$2.00" => 200,
      })
    end
  end

  describe '#available_products' do
    it 'return correct values' do
      expect(subject.available_products).to match_array(['Coca Cola'])
    end
  end

  describe '#add_coins!' do
    let(:new_coins) do
      {
        100 => 1,
        200 => 5,
      }
    end

    it 'adds coins' do
      expect(subject.add_coins!(new_coins)).to eq(1100)

      expect(coins).to match_array(
        [
          {
            name: "$1.00",
            quantity: 6,
            value: 100,
          },
          {
            name: "$2.00",
            quantity: 5,
            value: 200,
          },
        ]
      )

      expect(products).to eq({
        'Coca Cola' => {
          value: 200,
          quantity: 2,
        },
      })
    end
  end

  describe '#buy_product!' do
    it 'successfully buy product' do
      expect(subject.buy_product!('Coca Cola', 500)).to eq(300)

      expect(products).to include({
        'Coca Cola' => {
          value: 200,
          quantity: 1,
        },
      })
    end
  end

  describe '#can_buy_product?' do
    context 'valid' do
      let(:coins) do
        [
          {
            name: '$1.00',
            quantity: 1,
            value: 100,
          },
        ]
      end

      it 'successfully buy product' do
        result = subject.can_buy_product?('Coca Cola', 200)

        expect(result.success?).to be_truthy
        expect(result.error).to be_nil
      end
    end

    context 'no echange' do
      let(:coins) do
        [
          {
            name: '$1.00',
            quantity: 1,
            value: 100,
          },
          {
            name: '$2.00',
            quantity: 1,
            value: 200,
          },
        ]
      end

      it 'successfully buy product' do
        result = subject.can_buy_product?('Coca Cola', 250)

        expect(result.success?).to be_falsey
        expect(result.error).to eq("Machine can't give an exchange!")
      end
    end
  end
end
