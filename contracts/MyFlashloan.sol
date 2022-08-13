// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6;

import { FlashLoanReceiverBase } from "./FlashloanReceiverBase.sol";
// import { ILendingPool, ILendingPoolAddressesProvider, IERC20, IMockArbitrage } from "./Interfaces.sol";
import { ILendingPool, ILendingPoolAddressesProvider, IERC20 } from "./Interfaces.sol";
import { IJoeRouter02 } from "../interfaces/traderjoe/IJoeRouter02.sol"; 
import { SafeMath } from "./Libraries.sol";
import { Withdrawable } from "./Withdrawable.sol";
// import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
// import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';

contract FlashloanDemo is FlashLoanReceiverBase, Withdrawable {

    event UpdatedArbitrageContract (address oldArbitrageContract, address newArbitrageContract);
    
    // IMockArbitrage arbitrageContract;
    IJoeRouter02 public immutable joeRouter;

    // constructor(address _addressProvider, address _arbitrageContract) FlashLoanReceiverBase(_addressProvider) public {
    //     arbitrageContract = IMockArbitrage(_arbitrageContract);
    // }
    constructor(address _aaveLPAddressProvider, IJoeRouter02 _joeRouterAddress) FlashLoanReceiverBase(_aaveLPAddressProvider) public {
        joeRouter = IJoeRouter02(_joeRouterAddress);
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
        
        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.
        // arbitrageContract.takeArbitrage(assets[0]);
        
        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

        return true;
    }

    function _flashloan(address[] memory assets, uint256[] memory amounts) internal {
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        bytes memory params = "";
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
    function flashloan(address _asset, uint256 _amount) public onlyOwner {
        bytes memory data = "";
        uint amount = _amount;

        address[] memory assets = new address[](1);
        assets[0] = _asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;

        _flashloan(assets, amounts);
    }

    // function setArbitrageContract (address _newArbitrageContract) external {
    //     address _previousArbitrageContract = address(arbitrageContract);
    //     arbitrageContract = IMockArbitrage(_newArbitrageContract);
    //     emit UpdatedArbitrageContract (_previousArbitrageContract, _newArbitrageContract);
    // }
}