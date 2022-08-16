// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import { FlashLoanReceiverBase } from "./FlashloanReceiverBase.sol";
// import { ILendingPool, ILendingPoolAddressesProvider, IERC20Joe, IMockArbitrage } from "./Interfaces.sol";
import { ILendingPool, ILendingPoolAddressesProvider, IERC20 } from "./Interfaces.sol";
import { IJoeRouter01 } from "../interfaces/traderjoe/IJoeRouter01.sol"; 
import { IPangolinRouter } from "../interfaces/pangolin/IPangolinRouter.sol";
import { IERC20Joe } from "../interfaces/traderjoe/IERC20.sol"; 
import { SafeMath } from "./Libraries.sol";
import { Withdrawable } from "./Withdrawable.sol";
// import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
// import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract FlashloanDemo is FlashLoanReceiverBase, Withdrawable {

    // event UpdatedArbitrageContract (address oldArbitrageContract, address newArbitrageContract);
    
    // IMockArbitrage arbitrageContract;
    IJoeRouter01 public immutable joeRouter;
    IPangolinRouter public immutable pangolinRouter;

    // constructor(address _addressProvider, address _arbitrageContract) FlashLoanReceiverBase(_addressProvider) public {
    //     arbitrageContract = IMockArbitrage(_arbitrageContract);
    // }
    constructor(address _aaveLPAddressProvider, address _joeRouterAddress, address _pangolinRouterAddress) FlashLoanReceiverBase(_aaveLPAddressProvider) public {
        joeRouter = IJoeRouter01(_joeRouterAddress);
        pangolinRouter = IPangolinRouter(_pangolinRouterAddress);
    }

    /**
     * @dev This function must be called only be the LENDING_POOL and takes care of repaying
     * active debt positions, migrating collateral and incurring new V2 debt token debt.
     *
     * @param assets The array of flash loaned assets used to repay debts.
     * @param amounts The array of flash loaned asset amounts used to repay debts.
     * @param premiums The array of premiums incurred as additional debts.
     * @param initiator The address that initiated the flash loan, unused.
     * @param params The byte array containing, in this case, the arrays of aTokens and aTokenAmounts.
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {
        
        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //
        _swap(amounts, params);

        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.
        // arbitrageContract.takeArbitrage(assets[0]);
        
        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = SafeMath.add(amounts[i], premiums[i]);
            // uint amountOwing = amounts[i].add(premiums[i]);

            IERC20Joe(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

        return true;
    }

    function _swap(uint256[] calldata amounts, bytes calldata params) internal {
        (bool _buyJoe, address _token0, address _token1) = abi.decode(params, (bool, address, address));
        IERC20Joe token0 = IERC20Joe(_token0);
        IERC20Joe token1 = IERC20Joe(_token1);
        
        address[] memory path0 = new address[](2);
        path0[0] = _token0;
        path0[1] = _token1;

        address[] memory path1 = new address[](2);
        path1[0] = _token1;
        path1[1] = _token0;

        if (_buyJoe) {
            token0.approve(address(joeRouter), amounts[0]);
            // joeRouter.swapExactAVAXForTokens{value: amounts[0]}(0, path0, address(this), block.timestamp + 60);
            joeRouter.swapExactTokensForTokens(amounts[0], 0, path0, address(this), block.timestamp + 60);
            uint256 amountReceived1 = token1.balanceOf(address(this));
            token1.approve(address(pangolinRouter), amountReceived1);
            // uint256[] memory amountReceived2 = pangolinRouter.swapExactTokensForAVAX(amountReceived1[0], 0, pangolinPath, address(this), block.timestamp + 60);
            // pangolinRouter.swapExactTokensForAVAX(amountReceived1, 0, path1, address(this), block.timestamp + 60);
            pangolinRouter.swapExactTokensForTokens(amountReceived1, 0, path1, address(this), block.timestamp + 60);

        }
        else {
            token0.approve(address(pangolinRouter), amounts[0]);
            // pangolinRouter.swapExactAVAXForTokens{value: amounts[0]}(0, path0, address(this), block.timestamp + 60);
            pangolinRouter.swapExactTokensForTokens(amounts[0], 0, path0, address(this), block.timestamp + 60);
            uint256 amountReceived1 = token1.balanceOf(address(this));
            token1.approve(address(joeRouter), amountReceived1);
            // uint256[] memory amountReceived2 = joeRouter.swapExactTokensForAVAX(amountReceived1[0], 0, path1, address(this), block.timestamp + 60);
            // joeRouter.swapExactTokensForAVAX(amountReceived1, 0, path1, address(this), block.timestamp + 60);
            joeRouter.swapExactTokensForTokens(amountReceived1, 0, path1, address(this), block.timestamp + 60);
        }
    }

    function _flashloan(address[] memory assets, uint256[] memory amounts, bytes memory params) internal {
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        // bytes memory params = "";
        uint16 referralCode = 0;

        uint256[] memory modes = new uint256[](assets.length);

        // 0 = no debt (flash), 1 = stable, 2 = variable
        for (uint256 i = 0; i < assets.length; i++) {
            modes[i] = 0;
        }

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    /*
     *  Flash loan wei amount worth of `_asset`
     */
    function flashloan(address _asset, uint256 _amount, bool _buyJoe, address _token0, address _token1) public onlyOwner {
        bytes memory params = abi.encode(_buyJoe, _token0, _token1);
        uint amount = _amount;

        address[] memory assets = new address[](1);
        assets[0] = _asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        _flashloan(assets, amounts, params);
    }

    // function setArbitrageContract (address _newArbitrageContract) external {
    //     address _previousArbitrageContract = address(arbitrageContract);
    //     arbitrageContract = IMockArbitrage(_newArbitrageContract);
    //     emit UpdatedArbitrageContract (_previousArbitrageContract, _newArbitrageContract);
    // }
}