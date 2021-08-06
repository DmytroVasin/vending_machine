# VendingMachine::Machine

module VendingMachine
  class Machine
    def initialize(data)
      @coins = data.coins
      @products = data.products
    end

    def acceptable_coin_nominals
      @coins.each_with_object({}) { |coin, object| object[coin[:name]] = coin[:value] }
    end

    def available_products
      @products.keys
    end

    def add_coins!(nominals)
      nominals.each_pair do |value, quantity|
        coin = find_coin(value)
        coin[:quantity] += quantity
      end

      nominals.sum { |value, quantity| value * quantity }
    end

    def remove_amount!(client_amount)
      client_nominals = Hash.new(0)
      nominals = find_nominals_for(client_amount)

      nominals.each_pair do |value, quantity|
        coin = find_coin(value)
        coin[:quantity] -= quantity

        client_nominals[coin[:name]] += quantity
      end

      client_nominals
    end

    def can_buy_product?(product_name, client_amount)
      product = @products[product_name]

      if !has_product?(product)
        return OpenStruct.new({ success?: false, error: "'#{product[:name]}' is out of stock!" })
      end

      if !has_enough_money_to_by?(product, client_amount)
        return OpenStruct.new({ success?: false, error: "You do not have enough money to by '#{product[:name]}'!" })
      end

      if !can_give_an_exchange?(product, client_amount)
        return OpenStruct.new({ success?: false, error: "Machine can't give an exchange!" })
      end

      OpenStruct.new({ success?: true, error: nil })
    end

    def buy_product!(name, client_amount)
      product = @products[name]

      product[:quantity] -= 1

      client_amount - product[:value]
    end

    private

    def has_product?(product)
      product[:quantity].positive?
    end

    def has_enough_money_to_by?(product, client_amount)
      product[:value] <= client_amount
    end

    def can_give_an_exchange?(product, client_amount)
      odd_amount = client_amount - product[:value]
      return true if odd_amount.zero?

      calculate(odd_amount).any?
    end

    def find_nominals_for(client_amount)
      calculate(client_amount)
    end

    def calculate(value)
      VendingMachine::Exchanger.call(value, @coins)
    end

    def find_coin(value)
      @coins.detect { |coin| coin[:value] == value }
    end
  end
end
