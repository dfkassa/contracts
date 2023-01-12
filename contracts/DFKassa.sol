// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity =0.8.17;

import "./interfaces/IConfigureMe.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IDFKassa.sol";
import "./interfaces/ITracker.sol";
import "./interfaces/ITreasury.sol";

contract DFKassa is IDFKassa {
    address public router;

    Payment[] private __payments;

    constructor(address _router) {
        router = _router;
    }

    receive() external payable {}

    function payments(
        uint256 _index
    ) external view override returns (Payment memory) {
        return __payments[_index];
    }

    function pay(
        address _to,
        address _token,
        uint256 _amount,
        uint256 _payload
    ) public payable {
        require(_amount != 0, "Payment amount cannot be zero");
        require(_to != address(0), "Payment receiver cannot be zero address");

        IRouter _routerContract = IRouter(router);
        IConfigureMe _configContract = IConfigureMe(_routerContract.config());
        ITracker _trackerContract = ITracker(_routerContract.tracker());

        uint256 _visitorTxFee = _configContract.visitorTxGasFee() * tx.gasprice;

        if (_token == _routerContract.dfk()) {
            _visitorTxFee -= _configContract.dfkPaymentFeesDiscount();
        }
        require(
            msg.value >= _visitorTxFee,
            "Provide protocol fee to complete the payment"
        );

        if (_token == address(0)) {
            require(
                _amount + _visitorTxFee <= msg.value,
                "Payment amount + protocol fee should be less or equal passed value"
            );
            payable(_to).transfer(_amount);
            _visitorTxFee += msg.value - _visitorTxFee - _amount;
        } else {
            IERC20 _erc20Contract = IERC20(_token);
            _erc20Contract.transferFrom(msg.sender, _to, _amount);
            _visitorTxFee += msg.value - _visitorTxFee;
        }

        payable(address(this)).transfer(_visitorTxFee);
        _trackerContract.increaseTotalCollectedFees(_visitorTxFee);

        Payment memory newPayment = Payment({
            from: msg.sender,
            to: _to,
            token: _token,
            amount: _amount,
            payload: _payload,
            ts: block.timestamp,
            protocolFee: _visitorTxFee

        });
        __payments.push(newPayment);
        _mintVMDFKRewards(__payments[__payments.length - 1]);
        // userPayments[msg.sender].push(paymentsCount);

        emit NewPayment(newPayment);
    }

    function collectFees(address _reciever, uint256 _epoch) public virtual override {
        IRouter _routerContract = IRouter(router);
        ITracker _trackerContract = ITracker(_routerContract.tracker());

        uint256 _amountToWithdraw = _trackerContract.userAvailableFees(_epoch, _reciever);
        payable(_reciever).transfer(_amountToWithdraw);
    }

    function _mintVMDFKRewards(Payment memory _payment) private {
        IRouter _routerContract = IRouter(router);
        IConfigureMe _configContract = IConfigureMe(_routerContract.config());
        ITracker _trackerContract = ITracker(_routerContract.tracker());
        ITreasury _trausuryContract = ITreasury(_routerContract.treasury());

        uint256 vPointsMint = 1 ether;
        uint256 mPointsMint = 1 ether;

        vPointsMint += _trausuryContract.userExtraVMDFK(_payment.from);
        mPointsMint += _trausuryContract.userExtraVMDFK(_payment.to);

        if (_payment.token == _routerContract.dfk()) {
            vPointsMint += _configContract.dfkPaymentExtraVDFKPoints();
            mPointsMint += _configContract.dfkReceivingExtraMDFKPoints();
        }

        _trackerContract.mintVPoints(_payment.from, vPointsMint);
        _trackerContract.mintMPoints(_payment.to, mPointsMint);
    }

}
