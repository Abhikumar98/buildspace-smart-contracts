pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Web3GiftsNFT is Ownable, ERC721, ERC721Enumerable, ERC721URIStorage {
    string public contract_metadata;
    using Counters for Counters.Counter;
    Counters.Counter public _tokenIDs;

    struct Gift {
        uint256 tokenID;
        uint256 amount;
        bool redeemed;
        address from;
        uint256 redeem_at;
    }

    mapping(uint256 => Gift) private gifts;
    mapping(address => uint256[]) private ownerGifts;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _metadata
    ) ERC721(_name, _symbol) {
        contract_metadata = _metadata;
    }

    function contractURI() public view returns (string memory) {
        return contract_metadata;
    }

    function mint(string memory uri, address ownerAddress, uint256 redeem_at) public payable returns (uint256) {
        require(msg.value > 0, "Gift cannot be worth 0 ETH");

        _tokenIDs.increment();
        uint256 newID = _tokenIDs.current();

        Gift memory newGift = Gift({
            tokenID: newID,
            amount: msg.value,
            redeemed: false,
            redeem_at: redeem_at,
            from: msg.sender
        });

        gifts[newID] = newGift;
        ownerGifts[ownerAddress].push(newID);

        _safeMint(msg.sender, newID);
        _setTokenURI(newID, uri);

        transferToken(msg.sender, ownerAddress, newID);

        return newID;
    }

    function getAllGifts(address owner) public view returns (Gift[] memory) {

        Gift[] memory result = new Gift[](ownerGifts[owner].length);

        for (uint256 i = 0; i < ownerGifts[owner].length; i++) {
            result[i] = gifts[ownerGifts[owner][i]];
        }

        return result;
    }

    function redeem(uint256 tokenID) public returns (uint256) {
        Gift memory gift = gifts[tokenID];
        require(gift.redeemed == false, "Gift has already been redeemed");

        address tokenOwner = ownerOf(tokenID);
        require(tokenOwner == msg.sender, "You do not own this gift");

        if(gift.redeem_at > 0){
            require(gift.redeem_at < block.timestamp, "Gift can't be redeemed yet");
        }

        payable(msg.sender).transfer(gift.amount);
        gifts[tokenID].redeemed = true;

        return gift.amount;
    }

    function transferToken(
        address from,
        address to,
        uint256 tokenID
    ) public returns (bool) {
        super.safeTransferFrom(from, to, tokenID);
        return true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return super.ownerOf(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function overrideRedeemTime(uint256 tokenID, uint256 timestamp) public onlyOwner returns(Gift memory)  {
        gifts[tokenID].redeem_at = timestamp;
        return gifts[tokenID];
    }
}