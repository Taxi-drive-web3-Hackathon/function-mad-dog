// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/// @notice Simple single owner authorization mixin.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)
abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnershipTransferred(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner) {
        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;

        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

interface ICCIPAdapter {
  function send(
      address _token, 
      uint256 _amount, 
      address _to, 
      uint64 _destinationChainSelector
  ) external returns (bytes32);
  function getLinkBalance() external view returns (uint256);
  function allowlistedChains(uint64 _chainId) external view returns (bool);
}

interface IVault {
  function deposit(address _token, uint256 _amount) external;
  function pay(address _token, uint256 _amount, address _to) external;
  function withdraw(address _token, uint256 _amount) external;
  function getBalance(address _token) external view returns (uint256);
}

contract PinGo is Owned {
    struct VaultData {
        bool active;
        address token;
        address vault;
    }

    uint64 public constant CCIP_CURRENT_CHAIN = 12532609583862916517;
    ICCIPAdapter public adapter;
    mapping(uint8 => VaultData) public vaults;
    mapping(bytes32 => bool) public requests;
    mapping(uint8 => address) public receivers;

    event ExecuteTransfer(address indexed vault, uint256 amount, address receiver);
    event ExecuteCCIP(bytes32 requestId, address indexed vault, uint256 amount, address receiver);

    constructor(address _adapter) Owned(msg.sender) {
        adapter = ICCIPAdapter(_adapter);
    }

    function addReceiver(uint8 id, address receiver) public onlyOwner {
        receivers[id] = receiver;
    }

    function removeReceiver(uint8 id) public onlyOwner {
        delete receivers[id];
    }

    function addVault(uint8 id, address token, address vault) public onlyOwner {
        vaults[id] = VaultData(true, token, vault);
    }

    function removeVault(uint8 id) public onlyOwner {
        delete vaults[id];
    }

    function getBalance(uint8 id, address token) public view returns (uint256) {
        return ERC20(token).balanceOf(vaults[id].vault);
    }

    function execute(
        bytes32 requestId,
		bytes memory response,
		bytes memory err
    ) public {
        require(requests[requestId] == false, "Request already processed");
        requests[requestId] = true;

        (uint8 id, uint8 receiverId, uint64 chainId, uint256 amount) = abi.decode(response,
            (uint8, uint8, uint64, uint256));

        address receiver = receivers[receiverId];
        IVault vaultContract = IVault(vaults[id].vault);
        ERC20 token = ERC20(vaults[id].token);

        require(vaults[id].active != true && address(vaults[id].vault) != address(0), "User not active");
        require(getBalance(id, vaults[id].token) > 0, "Insufficient balance");
        require(receiver != address(0), "Receiver not found");

        if (chainId == CCIP_CURRENT_CHAIN) {
            vaultContract.pay(vaults[id].token, amount, receiver);
            emit ExecuteTransfer(address(vaultContract), amount, receiver);
            return;
        }

        require(ICCIPAdapter(address(adapter)).allowlistedChains(chainId), "Destination chain is not allowlisted");
        vaultContract.pay(address(token), amount, address(this));
        token.approve(address(adapter), amount);
        bytes32 ccipRequest = ICCIPAdapter(address(adapter)).send(address(token), amount, receiver, chainId);

        emit ExecuteCCIP(ccipRequest, address(vaultContract), amount, receiver);
    }
}
