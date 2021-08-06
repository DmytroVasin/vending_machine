## Title:
Virtual vending machine application which emulates the goods buying operations and change calculation.

### Features of vending machine:
- Allow user to select a product from a provided machine's inventory
- Allow user to insert coins into a vending machine
- Once the product is selected and the appropriate amount of coins inserted - it returns the product
- It return change (coins) if inserted too much
- Change is returned with the minimum amount of coins possible (Algorithm)
- It notify the customer when the selected product is out of stock
- It return inserted coins in case it does not have enough change

## To run programm:
`bin/vm`

## To run tests:
`rspec spec`

## To create a gem:
`rake install`

### Implmentation tricks:
Inside `Inventory` we do next:

1. I used HashTable to be able to have an access in O(1)
2. Add `value` (Integer) field. In a such way we do not need to use float numbers in exchange algo. (Moreover, usage of float numbers in price calculation is restricted.)

### Possible improvments:
1. Data tranfering format between Services is not specified.
1. Incorrect data structure was picked for keeping coins. Because of that we receive N+1 request per each Coin
2. Exchange Algo works with specific (non optimal structure - Hash)
3. Tests have alot of duplicated lines!
4. Client can't add money inside buying process.


### How to bundle it:
To pack:
`git bundle create vending_machine.bundle HEAD master`

To Re-pack:
`git clone vending_machine.bundle -b master directory-name`
