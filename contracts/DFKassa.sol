// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DFKassa {
    address public immutable dfk;
    address public protoRewardsReciever;
    bytes32 public currentSecret;

    uint256 public constant PROTOCOL_FEES_REWARD = 30_000;
    uint256 public constant DFK_PAYMENT_DISCOUNT = 10_000;
    uint256 public constant DFK_RECIEVING_CASHBACK = 10_000;

    event NewPayment(
        uint256 indexed payload,
        address indexed to,
        uint256 amount,
        address token,
        uint256 merchantCashback,
        uint256 protocolReward
    );

    constructor(
        address _dfk,
        bytes32 _currentSecret
    ) {
        dfk = _dfk;
        protoRewardsReciever = msg.sender;
        currentSecret = _currentSecret;
    }

    function pay(
        address payable _to,
        address _token,
        uint256 _amount,
        uint256 _payload
    ) public virtual payable {
        require(_amount != 0, "Payment amount cannot be zero");
        require(_to != address(0), "Payment receiver cannot be zero address");

        uint256 _protocolReward;
        uint256 _merchantCashback;

        if (_token == address(0)) {
            require(
                _amount + PROTOCOL_FEES_REWARD * tx.gasprice <= msg.value,
                "Passed value should be greater or equal payment amount + protocol fee"
            );
            payable(_to).transfer(_amount);
            _protocolReward = msg.value - _amount;
        } else {
            uint256 _expectedFee = PROTOCOL_FEES_REWARD;
            if (_token == dfk) {
                _expectedFee -= DFK_PAYMENT_DISCOUNT;
                _merchantCashback = DFK_RECIEVING_CASHBACK * tx.gasprice;
            } else {
                _merchantCashback = 0;
            }
            require(
                _expectedFee * tx.gasprice <= msg.value,
                "Passed value should be greater or equal required protocol fee"
            );
            IERC20 _erc20Contract = IERC20(_token);
            _erc20Contract.transferFrom(msg.sender, _to, _amount);
            _protocolReward = msg.value;
        }

        if (_merchantCashback > 0)
            _to.transfer(_merchantCashback);

        payable(protoRewardsReciever).transfer(_protocolReward - _merchantCashback);

        emit NewPayment(
            _payload,
            _to,
            _amount,
            _token,
            _merchantCashback,
            _protocolReward
        );
    }

    function setProtoRewardsReciever(
        address _newAccount,
        bytes memory _beforeSecret,
        bytes32 _newSecret,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public virtual {
        address _signer = ecrecover(
            bytes32("transfer proto rewards reciever"),
            _v,
            _r,
            _s
        );
        require(_signer == protoRewardsReciever, "Message should be signed by current reciever");
        require(keccak256(_beforeSecret) == currentSecret, "Secrets are not the same");
        currentSecret = _newSecret;
        protoRewardsReciever = _newAccount;
    }
}
