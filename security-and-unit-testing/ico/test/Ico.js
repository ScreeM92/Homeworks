const Ico = artifacts.require("Ico");

const increaseTime = function(duration) {
  const id = Date.now()

  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: '2.0',
      method: 'evm_increaseTime',
      params: [duration],
      id: id,
    }, err1 => {
      if (err1) return reject(err1)

      web3.currentProvider.sendAsync({
        jsonrpc: '2.0',
        method: 'evm_mine',
        id: id+1,
      }, (err2, res) => {
        return err2 ? reject(err2) : resolve(res)
      })
    })
  })
}

contract('Ico test', async (accounts) => {
  it("should buy 1 token in presale", async () => {
    let instance = await Ico.deployed();  
	let account = accounts[0];
    let amount = 1000000000000000000;

    let balance = await instance.getTokensCount.call({ from: account});
    let account_starting_balance = balance.toNumber();

    await instance.presale({ from: account, value: amount });
    let balanceNext = await instance.getTokensCount.call({ from: account});
	let account_next_balance = balanceNext.toNumber();

    assert.equal(account_next_balance, 1);
  });

  it("should buy 10 token in presale", async () => {
    let instance = await Ico.deployed();    
	let account = accounts[0];
    let amount = 10000000000000000000;

    let balance = await instance.getTokensCount.call({ from: account});
    let account_starting_balance = balance.toNumber();

    await instance.presale({ from: account, value: amount });
    let balanceNext = await instance.getTokensCount.call({ from: account});
	let account_next_balance = balanceNext.toNumber();

    assert.equal(account_next_balance, account_starting_balance + 10);
  });

  it("should fail buy token in presale with smaller than 1 ETH", async () => {
    let instance = await Ico.deployed();     
	let account = accounts[0];
    let amount = 100000000000000000;

    try {
    	await instance.presale({ from: account, value: amount });
    }
    catch(error) {
    	assert.fail('Expected fail when buy token with smaller than 1 ETH');
    }
  });

  it("should buy 5 tokens in sale", async () => {
    let instance = await Ico.deployed();
	let account = accounts[0];
    let amount = 10000000000000000000;

    await increaseTime(11);

    let balance = await instance.getTokensCount.call({ from: account});
    let account_starting_balance = balance.toNumber();

    await instance.sale({ from: account, value: amount });

    let balanceNext = await instance.getTokensCount.call({ from: account});
	let account_next_balance = balanceNext.toNumber();

    assert.equal(account_next_balance, account_starting_balance + 5);
  });

  it("should buy 10 tokens in sale", async () => {
    let instance = await Ico.deployed();
	  let account = accounts[0];
    let amount = 20000000000000000000;

    await increaseTime(11);

    let balance = await instance.getTokensCount.call({ from: account});
    let account_starting_balance = balance.toNumber();

    await instance.sale({ from: account, value: amount });

    let balanceNext = await instance.getTokensCount.call({ from: account});
	let account_next_balance = balanceNext.toNumber();

    assert.equal(account_next_balance, account_starting_balance + 10);
  });

  it("should fail buy tokens in sale because of it is not round value", async () => {
    let instance = await Ico.deployed();
	let account = accounts[0];
    let amount = 11000000000000000000;

    try {
    	await increaseTime(11);
    	await instance.sale({ from: account, value: amount });
    }
    catch(error) {
    	assert.fail('Expected fail when buy tokens in sale because of it is not round value');
    }
  });

  it("should send 5 tokens to other address", async () => {
    let instance = await Ico.deployed();
	let account = accounts[0];
	let accountTwo = accounts[1];
    let amount = 5;

    await increaseTime(40);

    let balance = await instance.getTokensCount.call({ from: account});
    let account_starting_balance = balance.toNumber();
    let balanceTwo = await instance.getTokensCount.call({ from: accountTwo});
    let account_starting_balance_two = balanceTwo.toNumber();

    await instance.transfer(accountTwo, amount, { from: account });

    let balanceNext = await instance.getTokensCount.call({ from: account});
	let account_next_balance = balanceNext.toNumber();
	let balanceNextTwo = await instance.getTokensCount.call({ from: accountTwo});
	let account_next_balance_two = balanceNextTwo.toNumber();

    assert.equal(account_next_balance, account_starting_balance - 5);
    assert.equal(account_next_balance_two, account_starting_balance_two + 5);
  });

  it("should fail send 50 tokens to other address because of missing", async () => {
    let instance = await Ico.deployed();
	let account = accounts[0];
	let accountTwo = accounts[1];
    let amount = 50;

    await increaseTime(40);

    let balance = await instance.getTokensCount.call({ from: account});
    let account_starting_balance = balance.toNumber();
    let balanceTwo = await instance.getTokensCount.call({ from: accountTwo});
    let account_starting_balance_two = balanceTwo.toNumber();

    try {
    	await instance.transfer(accountTwo, amount, { from: account });
    }
    catch(error) {
		assert.fail('Expected fail when send 50 tokens to other address because of missing');
    }
  });
})