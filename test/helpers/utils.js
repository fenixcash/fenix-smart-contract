module.exports = {
  assert_throw: async promise => {
    try {
      await promise
    } catch (error) {
      const invalidJump = error.message.search('invalid JUMP') >= 0
      const invalidOpcode = error.message.search('invalid opcode') >= 0
      const outOfGas = error.message.search('out of gas') >= 0
      assert(invalidJump || invalidOpcode || outOfGas, "Expected throw, got '" + error + "' instead")
      return
    }
    assert.fail('Expected throw not received')
  }
};

exports.promisify = (inner) =>
  new Promise((resolve, reject) =>
    inner((err, res) => {
      if (err) { reject(err) }
      resolve(res);
    })
);

exports.getBalance = (account, at) => promisify(cb => web3.eth.getBalance(account, at, cb));