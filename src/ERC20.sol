// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712{
    mapping(address=>uint256) private balances;
    mapping(address=>mapping(address=>uint256)) private allowances;
    uint256 private _totalSupply;

    bytes32 private constant _PERMIT_TYPEHASH =  keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    string private constant _VERSION = "V1";

    string private _name;
    string private _symbol;
    uint8 private _decimal;

    address private real_owner;

    bool private _pause;

    bytes32 private _previoushash;

    mapping(address => uint256) private _nonces;
    uint256 private nonce;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    modifier check(bool _check)
    {
        require(!_check);
        _;
    }

    constructor(string memory name, string memory symbol) EIP712(name, _VERSION)
    {
        _name=name;
        _symbol=symbol;
        _decimal=18;
        _pause=false;
        real_owner=msg.sender;
        _mint(msg.sender,100 ether);   
    }
    

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimal;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) external check(_pause) returns (bool success) {
        require(balances[msg.sender] >= _value, "value exceeds balance");
        require(msg.sender != address(0), "transfer to the zero address");
        require(_to != address(0), "transfer from the zero address");

        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) external check(_pause) returns (bool suceess) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_from != address(0), "transfer from the zero address");
        require(_to != address(0), "transfer to the zero address");

        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "insufficient allowance");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }
        require(balances[_from] >= _value, "value exceeds balance");

        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
        }
        emit Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public check(_pause) returns (bool success) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_spender != address(0), "transfer to the zero address");

        unchecked {
            allowances[msg.sender][_spender]= _value;
        }
        emit Approval(msg.sender, _spender , _value);
    }

    function _approve(address _owner, address _spender, uint256 _value) private {
        allowances[_owner][_spender]=_value;
        emit Approval(_owner, _spender, _value);
    }
    function allowance(address _owner, address _spender) public returns (uint256) {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_owner != address(0), "trnasfer from the zero address");
        require(_spender != address(0), "transfer to the zero address");
        
        return allowances[_owner][_spender];
    }


    function _mint(address _owner, uint256 _eth) public check(_pause) returns (bool success)
    {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_owner != address(0), "transfer from the zero address");

        balances[_owner]+=_eth;
        _totalSupply+=_eth;
    }

    function _burn(address _owner, uint256 _eth) public check(_pause) returns (bool success)
    {
        require(msg.sender != address(0), "transfer from the zero address");
        require(_owner != address(0), "transfer from the zero address");
        require(balances[_owner] >= _eth, "transfer from the balances notthing");

        balances[_owner]-=_eth;
        _totalSupply-=_eth;
    }

    function pause() public
    {
        require(real_owner==msg.sender);
        _pause=!_pause;
    }

    function nonces(address _addr) public returns (uint256 _nonce)
    {
        return _nonces[_addr];
    }

    function permit(
        address _owner, 
        address _spender, 
        uint256 _amount, 
        uint256 _deadline, 
        uint8 v, 
        bytes32 r, 
        bytes32 s) external
    {
        require(block.timestamp <= _deadline, "ERC20Permit: expired deadline");

        bytes32 structhash=keccak256(abi.encode(_PERMIT_TYPEHASH, _owner, _spender, _amount, _nonces[_owner]++, _deadline));

        bytes32 _hash=_toTypedDataHash(structhash);
        address recoverdAddress = ecrecover(_hash, v, r, s);

        require(recoverdAddress == _owner, "INVALID_SIGNER");
        _approve(_owner, _spender, _amount);

    }
}