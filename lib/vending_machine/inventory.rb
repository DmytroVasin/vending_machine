module VendingMachine
  class Inventory
    attr_reader :products, :coins

    def initialize
      @coins = init_coins
      @products = init_products
    end

    # NOTE: ProductName => { price:, quantity:, value:}
    def init_products
      {
        'Coca Cola' => {
          name: 'Coca Cola',
          price: '$2',
          value: 200,
          quantity: 2,
        },
        'Sprite' => {
          name: 'Sprite',
          price: '$2.5',
          value: 250,
          quantity: 2,
        },
        'Fanta' => {
          name: 'Fanta',
          price: '$2.7',
          value: 270,
          quantity: 3,
        },
        'Orange Juice' => {
          name: 'Orange Juice',
          price: '$3',
          value: 300,
          quantity: 1,
        },
        'Water' => {
          name: 'Water',
          price: '$3.25',
          value: 325,
          quantity: 0,
        },
      }
    end

    # NOTE: Nominal => Quantity
    def init_coins
      [
        {
          name: '$0.25',
          quantity: 5,
          value: 25,
        },
        {
          name: '$0.50',
          quantity: 5,
          value: 50,
        },
        {
          name: '$1.00',
          quantity: 5,
          value: 100,
        },
        {
          name: '$2.00',
          quantity: 5,
          value: 200,
        },
        {
          name: '$3.00',
          quantity: 5,
          value: 300,
        },
        {
          name: '$5.00',
          quantity: 5,
          value: 500,
        },
      ]
    end
  end
end
