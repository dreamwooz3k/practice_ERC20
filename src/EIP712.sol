//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EIP712{

    bytes32 private DOMAIN_SEPARATOR;

    string internal name_;
    string internal version_;
    bytes32 private hashedName;
    bytes32 private hashedVer;
    bytes32 private typeHash;
    
    constructor(string memory name, string memory version) {
        name_=name;
        version_=version;
        hashedName = keccak256(bytes(name_));
        hashedVer = keccak256(bytes(version_));     
        typeHash = keccak256( "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
        DOMAIN_SEPARATOR = keccak256(abi.encode(typeHash,hashedName,hashedVer,block.chainid,address(this)));
    }

    function _domainSeparator() public view returns (bytes32) {
        return DOMAIN_SEPARATOR;
    }


    function _toTypedDataHash(bytes32 _structHash) public view returns(bytes32)
    {
        return keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), _structHash));
    }

}