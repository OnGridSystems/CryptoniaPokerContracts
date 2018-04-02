import expectThrow from '../zeppelin-solidity/test/helpers/expectThrow';

var CappedToken = artifacts.require('CryptoniaToken');

contract('CappedToken', function (accounts) {
  const cap = new web3.BigNumber(100000000000);

  let token;

  beforeEach(async function () {
    token = await CappedToken.new();
    await token.adminAddRole(accounts[0], 'minter');
  });

  it('should start with the correct cap', async function () {
    let _cap = await token.cap();

    assert(cap.eq(_cap));
  });

  it('should mint when amount is less than cap', async function () {
    const result = await token.mint(accounts[0], 100);
    assert.equal(result.logs[0].event, 'Mint');
  });

  it('should fail to mint if the ammount exceeds the cap', async function () {
    await token.mint(accounts[0], cap.sub(1));
    await expectThrow(token.mint(accounts[0], 100));
  });

  it('should fail to mint after cap is reached', async function () {
    await token.mint(accounts[0], cap);
    await expectThrow(token.mint(accounts[0], 1));
  });
});
