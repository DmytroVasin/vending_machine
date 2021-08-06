# VendingMachine::Display

module VendingMachine
  class Display
    def initialize(prompt = TTY::Prompt.new)
      @prompt = prompt
    end

    def choose_coins(coin_nominals)
      client_coins = Hash.new(0)

      @prompt.say('Please insert coins nominal and quantity')

      loop do
        coin_nominal = @prompt.select('Insert coin nominal:', coin_nominals, cycle: true)
        coin_quantity = @prompt.slider('Insert coins quantity:', min: 1, max: 15, step: 1, default: 1)

        client_coins[coin_nominal] += coin_quantity

        break if @prompt.no?("Do you have more coins?")
      end

      client_coins
    end

    def select_product(available_products)
      @prompt.select('Choose a product:', available_products)
    end

    def quit?
      @prompt.yes?('Do you want to quit?')
    end

    def bye
      @prompt.say('Good luck!')
    end

    def ok(name)
      @prompt.ok("You've bought a: '#{name}'")
    end

    def warn(message)
      @prompt.warn(message)
    end

    def give_back_coins(coins)
      return if coins.empty?

      @prompt.ok('Here is your coins:')
      coins.each_pair do |nominal, quantity|
        @prompt.ok("Nominal: #{nominal} x Quantity: #{quantity}")
      end
    end
  end
end
