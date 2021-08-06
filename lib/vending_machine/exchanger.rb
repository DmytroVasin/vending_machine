# This is a basic coin algorithm - main goal is to
# return minimum amount of coins possible for provided amount;
#
# Input:
# amount: 150
# coins: {25=>6, 50=>0, 100=>5, 200=>5, 300=>5, 500=>5}
#
# Returns:
# Nominal -> Quantity
# { 100 => 1, 25 => 2 }
# {}
#
# NOTE: When algo can't convert amount to coins - we return empty hash!

# VendingMachine::Exchanger

module VendingMachine
  class Exchanger
    def self.call(...)
      self.new(...).call
    end

    def initialize(amount, coins)
      @amount = amount
      @available_coins = convert_input(coins)
      @coins_memo = { 0 => [] }
    end

    def call
      result = calculate_exchange(@available_coins, @amount)

      convert_result(result)
    end

    private

    def calculate_exchange(available_coins, amount)
      return nil if amount.negative?
      return @coins_memo[amount] if @coins_memo.key?(amount)

      min_coins_count = Float::INFINITY
      min_coins_array = nil

      available_coins.each_key do |nominal|
        next if available_coins[nominal].zero?

        available_coins[nominal] -= 1
        local_coins_array = calculate_exchange(available_coins, amount - nominal)
        available_coins[nominal] += 1

        next if local_coins_array.nil?
        next if local_coins_array.size >= min_coins_count

        min_coins_count = local_coins_array.size
        min_coins_array = local_coins_array + [nominal]
      end

      @coins_memo[amount] = min_coins_array
      @coins_memo[amount]
    end

    def convert_input(coins)
      coins.each_with_object({}) { |coin, hash| hash[coin[:value]] = coin[:quantity] }
    end

    def convert_result(result)
      (result || []).tally # {100 => 2, 200 => 3}
    end
  end
end
