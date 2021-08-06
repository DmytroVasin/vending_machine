# VendingMachine::Bot

module VendingMachine
  class Bot
    def self.start!(inventory = nil, client_amount = 0)
      self.new(inventory).run(client_amount)
    end

    def initialize(inventory = nil)
      @inventory = inventory || VendingMachine::Inventory.new
      @machine = VendingMachine::Machine.new(@inventory)
      @display = VendingMachine::Display.new
    end

    def run(client_amount)
      client_amount = ask_to_insert_coins!(client_amount)
      product_name = ask_to_select_product!

      result = @machine.can_buy_product?(product_name, client_amount)
      if result.success?
        client_amount = @machine.buy_product!(product_name, client_amount)

        @display.ok(product_name)
      else
        @display.warn(result.error)
      end

      attempt_to_re_run!(client_amount)
    end

    private

    def attempt_to_re_run!(client_amount)
      if @display.quit?
        client_nominals = @machine.remove_amount!(client_amount)
        @display.give_back_coins(client_nominals)
        @display.bye

        return
      end

      VendingMachine::Bot.start!(@inventory, client_amount)
    end

    def ask_to_select_product!
      @display.select_product(@machine.available_products)
    end

    def ask_to_insert_coins!(client_amount)
      return client_amount unless client_amount.zero?

      nominals = @display.choose_coins(@machine.acceptable_coin_nominals)

      @machine.add_coins!(nominals)
    end
  end
end
