require 'spec_helper'

describe VendingMachine::Bot do
  let(:machine_products) do
    {
      'Coca Cola' => {
        name: 'Coca Cola',
        price: "$0.5",
        value: 50,
        quantity: 2,
      },
      'Sprite' => {
        name: 'Sprite',
        price: "$2.00",
        value: 200,
        quantity: 2,
      },
      'Water' => {
        name: 'Water',
        price: "$1.00",
        value: 100,
        quantity: 0,
      },
      'Ionic Water' => {
        name: 'Ionic Water',
        price: "$0.90",
        value: 90,
        quantity: 1,
      },
    }
  end

  let(:machine_coins) do
    [
      {
        name: "$0.25",
        quantity: 5,
        value: 25,
      },
      {
        name: "$0.50",
        quantity: 5,
        value: 50,
      },
      {
        name: "$1.00",
        quantity: 5,
        value: 100,
      },
    ]
  end

  let(:coin_nominals) do
    {
      "$0.25" => 25,
      "$0.50" => 50,
      "$1.00" => 100,
    }
  end

  let(:inventory) do
    OpenStruct.new({
      products: machine_products,
      coins: machine_coins,
    })
  end

  let(:initial_coins) { 0 } # TODO: CHECK!
  let(:prompt_double) { double }

  before do
    allow(TTY::Prompt).to receive(:new).and_return(prompt_double)
    allow(prompt_double).to receive(:say).with("Please insert coins nominal and quantity")
  end

  subject { described_class.new(inventory).run(initial_coins) }

  describe '#run' do
    context 'complete e2e' do
      it 'success case' do
        expect(prompt_double).to receive(:select).with('Insert coin nominal:', coin_nominals, anything).and_return(coin_nominals['$1.00'])
        expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(3)
        expect(prompt_double).to receive(:no?).with('Do you have more coins?').and_return(true)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Coca Cola')

        expect(prompt_double).to receive(:ok).with("You've bought a: 'Coca Cola'")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(true)

        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with('Nominal: $1.00 x Quantity: 2')
        expect(prompt_double).to receive(:ok).with('Nominal: $0.50 x Quantity: 1')
        expect(prompt_double).to receive(:say).with('Good luck!')

        expect(machine_products['Coca Cola'][:quantity]).to eq(2)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 5, value: 100 },
          ]
        )

        subject

        expect(machine_products['Coca Cola'][:quantity]).to eq(1)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 4, value: 50 },
            { name: "$1.00", quantity: 6, value: 100 },
          ]
        )
      end
    end

    context 'when product is out of stock' do
      it 'warn message' do
        expect(prompt_double).to receive(:select).with('Insert coin nominal:', coin_nominals, anything).and_return(coin_nominals['$1.00'])
        expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(3)
        expect(prompt_double).to receive(:no?).with('Do you have more coins?').and_return(true)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Water')

        expect(prompt_double).to receive(:warn).with("'Water' is out of stock!")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(true)

        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with('Nominal: $1.00 x Quantity: 3')
        expect(prompt_double).to receive(:say).with('Good luck!')

        subject

        expect(machine_products['Coca Cola'][:quantity]).to eq(2)
        expect(machine_products['Sprite'][:quantity]).to eq(2)
        expect(machine_products['Water'][:quantity]).to eq(0)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 5, value: 100 },
          ]
        )
      end
    end

    context 'when client does not have enough money' do
      it 'warn message' do
        expect(prompt_double).to receive(:select).with('Insert coin nominal:', coin_nominals, anything).and_return(coin_nominals['$1.00'])
        expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(1)
        expect(prompt_double).to receive(:no?).with('Do you have more coins?').and_return(true)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Sprite')

        expect(prompt_double).to receive(:warn).with("You do not have enough money to by 'Sprite'!")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(true)

        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with('Nominal: $1.00 x Quantity: 1')
        expect(prompt_double).to receive(:say).with('Good luck!')

        subject

        expect(machine_products['Coca Cola'][:quantity]).to eq(2)
        expect(machine_products['Sprite'][:quantity]).to eq(2)
        expect(machine_products['Water'][:quantity]).to eq(0)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 5, value: 100 },
          ]
        )
      end
    end

    context "Machine can't give exchange" do
      it 'warn message' do
        expect(prompt_double).to receive(:select).with('Insert coin nominal:', coin_nominals, anything).and_return(coin_nominals['$1.00'])
        expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(1)
        expect(prompt_double).to receive(:no?).with('Do you have more coins?').and_return(true)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Ionic Water')

        expect(prompt_double).to receive(:warn).with("Machine can't give an exchange!")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(true)

        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with('Nominal: $1.00 x Quantity: 1')
        expect(prompt_double).to receive(:say).with('Good luck!')

        subject

        expect(machine_products['Coca Cola'][:quantity]).to eq(2)
        expect(machine_products['Sprite'][:quantity]).to eq(2)
        expect(machine_products['Water'][:quantity]).to eq(0)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 5, value: 100 },
          ]
        )
      end
    end

    context "Machine returns exchange when client inserted too much" do
      it 'successfully buy product with odd coins' do
        expect(prompt_double).to receive(:select).with('Insert coin nominal:', coin_nominals, anything).and_return(coin_nominals['$1.00'])
        expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(10)
        expect(prompt_double).to receive(:no?).with('Do you have more coins?').and_return(true)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Coca Cola')

        expect(prompt_double).to receive(:ok).with("You've bought a: 'Coca Cola'")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(true)

        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with('Nominal: $1.00 x Quantity: 9')
        expect(prompt_double).to receive(:ok).with('Nominal: $0.50 x Quantity: 1')
        expect(prompt_double).to receive(:say).with('Good luck!')

        expect(machine_products['Coca Cola'][:quantity]).to eq(2)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 5, value: 100 },
          ]
        )

        subject

        expect(machine_products['Coca Cola'][:quantity]).to eq(1)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 4, value: 50 },
            { name: "$1.00", quantity: 6, value: 100 },
          ]
        )
      end
    end

    context "Machine returns exchange with another nominals" do
      it 'successfully buy product with odd coins' do
        expect(prompt_double).to receive(:select).with('Insert coin nominal:', coin_nominals, anything).and_return(coin_nominals['$0.25'])
        expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(6)
        expect(prompt_double).to receive(:no?).with('Do you have more coins?').and_return(true)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Sprite')

        expect(prompt_double).to receive(:warn).with("You do not have enough money to by 'Sprite'!")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(true)

        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with('Nominal: $1.00 x Quantity: 1')
        expect(prompt_double).to receive(:ok).with('Nominal: $0.50 x Quantity: 1')
        expect(prompt_double).to receive(:say).with('Good luck!')

        expect(machine_products['Coca Cola'][:quantity]).to eq(2)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 5, value: 100 },
          ]
        )

        subject

        expect(machine_products['Coca Cola'][:quantity]).to eq(2)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 11, value: 25 },
            { name: "$0.50", quantity: 4, value: 50 },
            { name: "$1.00", quantity: 4, value: 100 },
          ]
        )
      end
    end
  end

  describe 'multistep e2e' do
    context "Machine returns exchange after 2 buy" do
      it 'successfully buy 2 products' do
        expect(prompt_double).to receive(:select).with('Insert coin nominal:', coin_nominals, anything).and_return(coin_nominals['$1.00'])
        expect(prompt_double).to receive(:slider).with('Insert coins quantity:', anything).and_return(5)
        expect(prompt_double).to receive(:no?).with('Do you have more coins?').and_return(true)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Sprite')

        expect(prompt_double).to receive(:ok).with("You've bought a: 'Sprite'")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(false)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Sprite')

        expect(prompt_double).to receive(:ok).with("You've bought a: 'Sprite'")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(false)

        expect(prompt_double).to receive(:select).with('Choose a product:', machine_products.keys).and_return('Sprite')

        expect(prompt_double).to receive(:warn).with("'Sprite' is out of stock!")
        expect(prompt_double).to receive(:yes?).with("Do you want to quit?").and_return(true)

        expect(prompt_double).to receive(:ok).with('Here is your coins:')
        expect(prompt_double).to receive(:ok).with('Nominal: $1.00 x Quantity: 1')
        expect(prompt_double).to receive(:say).with('Good luck!')

        expect(machine_products['Sprite'][:quantity]).to eq(2)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 5, value: 100 },
          ]
        )

        subject

        expect(machine_products['Sprite'][:quantity]).to eq(0)
        expect(machine_coins).to match_array(
          [
            { name: "$0.25", quantity: 5, value: 25 },
            { name: "$0.50", quantity: 5, value: 50 },
            { name: "$1.00", quantity: 9, value: 100 },
          ]
        )
      end
    end
  end
end
