pragma solidity ^0.4.9;


contract ERC23 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function transferToContract(address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract ERC23Asset is ERC23
{
    mapping (address => uint256) balances;
    mapping (address => bool) master;

    modifier onlyMaster {
        if (!master[msg.sender])
            throw;
        _;
    }
    event Burned(address indexed from, address indexed asset, uint value);
    event Minted(address indexed minter, address indexed asset, uint value);

    function()
    {
      throw;
    }
    function tokenFallback(address _address, uint _uint)
    {
      throw;
    }

    function Mint(address _receiver, uint _value) onlyMaster{
      totalSupply+=_value;
      balances[_receiver]+=_value;
      Minted(address(this), _receiver, _value);
    }

    function Burn(address _burner, uint _value) onlyMaster{
      totalSupply-=_value;
      balances[_burner]-=_value;
      Burned(_burner, address(this), _value);
    }
}

//Contract that is minting and burning cryptocurrency tokens

contract Eternity {
    
    modifier onlyOwner {
        if (msg.sender != owner)
            throw;
        _;
    }

  event Deposit(address indexed from, address indexed asset, uint value);
  event Withdraw(address indexed from, address indexed asset, uint value);
  event MarketAdded(address indexed asset, string indexed name);
  event MarketRemoved(address indexed asset, string indexed name);


//mapping digitalAssetBalance(tokenContract => (userAddress => userBalance));
  mapping (address => mapping (address => uint)) public digitalAssetBalance;

//mapping of supported digital currency assets addresses
  mapping (address => bool) public digitalAssetSupported;

//mapping currency token asset => name
  mapping (address => string) assetTokenName;
  mapping (string => address) assetTokenContract;

//index for last asset added
//  uint last_index=0;

    address owner;
    
    function Eternity()
    {
        owner=msg.sender;
    }

  function tokenFallback(address _from, uint _value){
    
        if(digitalAssetSupported[msg.sender])
        {
           digitalAssetBalance[msg.sender][_from]+=_value;
           Deposit(_from, msg.sender, _value);
        }

        else{ throw; }
    }

    /* ERC24 extended*/

    /*
    *function tokenFallback(address _from, uint _value, bytes _data)
    *{
    *    if(digitalAssetSupported[msg.sender])
    *    {
    *       digitalAssetBalance[msg.sender][_from]+=_value;
    *       Eternity tmp = Eternity(address(this));
    *       tmp.delegatecall(bytes4(sha3(_data)));
    *    }
    *
    *    else{ throw; }
    *}
    */

    //function exchangeTokensToCurrencyOrigin(string _name)
    //{
    //  if(digitalAssetBalance[])
    //}

    function exchangeTokensToCurrency(address _address, uint _value)
    {
      if((digitalAssetSupported[_address])&&(digitalAssetBalance[_address][msg.sender]>=_value))
      {
        burnToken(msg.sender, _address, _value);
      }
    }

    function exchangeTokensToCurrencyByName(string _name, uint _value)
    {
      address _token = assetTokenContract[_name];
      if((digitalAssetSupported[_token])&&(digitalAssetBalance[_token][msg.sender]>=_value))
      {
        burnToken(msg.sender, _token, _value);
      }
    }


    function withdrawToken(address _token, uint _value) returns (bool ok)
    {
      if((digitalAssetSupported[_token])&&(digitalAssetBalance[_token][msg.sender]>=_value))
      {
        ERC23Asset asset = ERC23Asset(_token);
        asset.transfer(msg.sender, _value);
        digitalAssetBalance[_token][msg.sender]-=_value;
        Withdraw(msg.sender, _token, _value);
        return true;
      }
      throw;
    }


    function withdrawTokenByName(string _name, uint _value) returns (bool ok)
    {
      address _token = assetTokenContract[_name];
      if((digitalAssetSupported[_token])&&(digitalAssetBalance[_token][msg.sender]>=_value))
      {
        ERC23Asset asset = ERC23Asset(_token);
        asset.transfer(msg.sender, _value);
        digitalAssetBalance[_token][msg.sender]-=_value;
        Withdraw(msg.sender, _token, _value);
        return true;
      }
      throw;
    }


    function burnToken(address _burner, address _token, uint _value) private
    {
        ERC23Asset asset = ERC23Asset(_token);
        asset.Burn(_burner, _value);
        digitalAssetBalance[_burner][msg.sender]-=_value;
    }

    function addAsset(address _address, string _name) onlyOwner{
      digitalAssetSupported[_address]=true;
      assetTokenName[_address]=_name;
      assetTokenContract[_name]=_address;

      MarketAdded(_address, _name);
    }

    function removeAsset(address _address) onlyOwner{
      digitalAssetSupported[_address]=false;

      MarketRemoved(_address, assetTokenName[_address]);
        delete(assetTokenContract[assetTokenName[_address]]);
      assetTokenName[_address]="";
    }

    function mintToken(address _receiver, address _token, uint _value) onlyOwner returns (bool ok)  {
      if(digitalAssetSupported[_token])
      {
        ERC23Asset asset = ERC23Asset(_token);
        asset.Mint(_receiver, _value);
        return true;
      }

      throw;
    }
}