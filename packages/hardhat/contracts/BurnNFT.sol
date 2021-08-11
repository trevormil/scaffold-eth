// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import 'base64-sol/base64.sol';
import "@openzeppelin/contracts/utils/Strings.sol";

contract BurnNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    event NewToken(address _minter, uint256 _tokenId, uint256 _baseFee);

    uint public limit;
    uint256 public price;
    address public beneficiary;
    uint256 public maxBaseFeePerGas;

    mapping(uint256 => uint256) public tokenBaseFee;

    constructor(uint _limit, uint256 _price, address _beneficiary, uint256 _maxBaseFeePerGas) ERC721("BurnyBoy", "BURN") {
      limit = _limit;
      price = _price;
      beneficiary = _beneficiary;
      maxBaseFeePerGas = _maxBaseFeePerGas;
    }

    function claimToken() public payable returns (uint256) {

        require(msg.value >= price, "insufficient value");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        require(newItemId <= limit, "limit reached");

        _mint(msg.sender, newItemId);

        uint256 baseFee = block.basefee;
        tokenBaseFee[newItemId] = baseFee;

        if(baseFee > maxBaseFeePerGas) {
          maxBaseFeePerGas = baseFee;
        }

        emit NewToken(msg.sender, newItemId, baseFee);

        return newItemId;
    }

    function withdrawFunds() public {
      require(msg.sender == beneficiary, 'only beneficiary can withdraw');
      // get the amount of Ether stored in this contract
      uint amount = address(this).balance;

      // send all Ether to owner
      // Owner can receive Ether since the address of owner is payable
      (bool success,) = beneficiary.call{value: amount}("");
      require(success, "Failed to send Ether");
    }

    function totalSupply() public view returns (uint256) {
      return _tokenIds.current();
    }

    function generateSVGofTokenById(uint256 _tokenId) public virtual view returns (string memory) {

        uint height = 323;
        uint fireHeight = height*(uint(100)-(uint(100)*tokenBaseFee[_tokenId]/maxBaseFeePerGas)) / uint(100);

        string memory svg = string(abi.encodePacked(
          '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 200 323.6"><defs><style><![CDATA[#Fire_to_move {transform: translate(0px,',
          Strings.toString(fireHeight),
          'px)}]]></style><linearGradient id="linear-gradient" x1="100" x2="100" y2="323.6" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#524984"/><stop offset="1" stop-color="#1b1a38"/></linearGradient><linearGradient id="linear-gradient-2" x1="100" y1="323.6" x2="100" y2="151.933" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#ffbd58"/><stop offset="1" stop-color="#f6ec47"/></linearGradient><clipPath id="clip-path"><rect y="0.419" width="200" height="151.587" fill="none"/></clipPath><linearGradient id="linear-gradient-3" x1="27.34" y1="22.637" x2="27.34" y2="153.025" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#f16e5c"/><stop offset="1" stop-color="#ffbd58"/></linearGradient><linearGradient id="linear-gradient-4" x1="30.946" y1="55.833" x2="30.946" y2="156.043" xlink:href="#linear-gradient-2"/><linearGradient id="linear-gradient-5" x1="101.387" y1="22.637" x2="101.387" y2="153.025" xlink:href="#linear-gradient-3"/><linearGradient id="linear-gradient-6" x1="104.992" y1="55.833" x2="104.992" y2="156.043" xlink:href="#linear-gradient-2"/><linearGradient id="linear-gradient-7" x1="175.433" y1="22.637" x2="175.433" y2="153.025" xlink:href="#linear-gradient-3"/><linearGradient id="linear-gradient-8" x1="179.038" y1="55.833" x2="179.038" y2="156.043" xlink:href="#linear-gradient-2"/><linearGradient id="linear-gradient-9" x1="35.977" y1="279.671" x2="164.023" y2="279.671" xlink:href="#linear-gradient"/></defs><g id="Layer_2" data-name="Layer 2"><rect width="200" height="323.6" fill="url(#linear-gradient)"/><g id="Fire_to_move" data-name="Fire to move"><rect y="151.933" width="200" height="171.667" fill="url(#linear-gradient-2)"/><g clip-path="url(#clip-path)"><path d="M-6.277,151.056c-.441-10.632-16.813-27.431-9.259-42.713S4.609,97.109,7.442,82.218c0,0,9.916,8.384,1.1,18.834,0,0,12.748-3.29,12.275-12.7s1.417-13.715-7.082-15.674S-7.509,56.616,4.767,41.725c0,0,2.36,12.54,13.22,7.054s19.83-22.728.944-23.12c0,0,11.8-7.054,18.886.392s-8.971,23.512-3.3,27.43S47.732,58.576,47.26,67.2,32.151,83.655,37.345,87.574,55.87,88.88,56.19,84.644c.314-4.171-7.514-9.218-.9-17.447A16.349,16.349,0,0,0,63.9,77.516c9.443,4.833,11.69,15.543,2.245,23.381-6.452,5.356-14.321-3-15.266,5.094-.547,4.7,20.081,11.343,18.183,25.39C65.574,157.2,77.943,152.73,37.345,152.73-8.194,152.73-6.277,151.056-6.277,151.056Z" fill="url(#linear-gradient-3)"/><path d="M31.38,156.043c-59.517,0-32.292-6.3-25.806-14.088C16.848,128.411-4.676,128.72-4.2,116.964a23.853,23.853,0,0,1,8.5-17.634s-4.957,13.911,2.125,14.3S20.964,109.039,24.6,96.055c6.374-22.784.472-35.128-8.027-40.222a37.474,37.474,0,0,1,17.871,8.475c5.68,5.143-4.452,15.03-4.179,23.266.709,21.361,33.365,4.31,30.375-5.095,0,0,9.128,12.932-2.754,14.891C36.43,100.908,37.345,115.2,45.371,119.9s5.792,14.23,13.04,21.478C67.969,150.94,83.3,156.043,31.38,156.043Z" fill="url(#linear-gradient-4)"/><path d="M67.769,151.056c-.441-10.632-16.813-27.431-9.258-42.713S78.656,97.109,81.488,82.218c0,0,9.916,8.384,1.1,18.834,0,0,12.747-3.29,12.275-12.7s1.416-13.715-7.082-15.674S66.537,56.616,78.813,41.725c0,0,2.361,12.54,13.22,7.054s19.83-22.728.944-23.12c0,0,11.8-7.054,18.886.392s-8.971,23.512-3.3,27.43,13.22,5.095,12.748,13.716S106.2,83.655,111.391,87.574s18.525,1.306,18.845-2.93c.315-4.171-7.514-9.218-.9-17.447a16.349,16.349,0,0,0,8.614,10.319c9.443,4.833,11.69,15.543,2.246,23.381-6.453,5.356-14.322-3-15.266,5.094-.548,4.7,20.081,11.343,18.182,25.39-3.488,25.814,8.881,21.349-31.717,21.349C65.853,152.73,67.769,151.056,67.769,151.056Z" fill="url(#linear-gradient-5)"/><path d="M105.426,156.043c-59.517,0-32.292-6.3-25.806-14.088,11.274-13.544-10.25-13.235-9.778-24.991a23.853,23.853,0,0,1,8.5-17.634s-4.958,13.911,2.124,14.3,14.546-4.594,18.178-17.578c6.374-22.784.472-35.128-8.026-40.222a37.473,37.473,0,0,1,17.87,8.475c5.681,5.143-4.451,15.03-4.178,23.266.708,21.361,33.365,4.31,30.374-5.095,0,0,9.128,12.932-2.754,14.891-21.453,3.538-20.538,17.83-12.512,22.533s5.792,14.23,13.04,21.478C142.016,150.94,157.351,156.043,105.426,156.043Z" fill="url(#linear-gradient-6)"/><path d="M141.816,151.056c-.441-10.632-16.813-27.431-9.259-42.713S152.7,97.109,155.535,82.218c0,0,9.915,8.384,1.1,18.834,0,0,12.747-3.29,12.275-12.7s1.417-13.715-7.082-15.674-21.246-16.067-8.971-30.958c0,0,2.361,12.54,13.22,7.054s19.83-22.728.945-23.12c0,0,11.8-7.054,18.885.392s-8.97,23.512-3.3,27.43,13.22,5.095,12.748,13.716-15.108,16.458-9.915,20.377,18.526,1.306,18.845-2.93c.315-4.171-7.513-9.218-.9-17.447a16.349,16.349,0,0,0,8.614,10.319c9.443,4.833,11.689,15.543,2.245,23.381-6.453,5.356-14.322-3-15.266,5.094-.548,4.7,20.081,11.343,18.183,25.39-3.489,25.814,8.881,21.349-31.718,21.349C139.9,152.73,141.816,151.056,141.816,151.056Z" fill="url(#linear-gradient-7)"/><path d="M179.472,156.043c-59.516,0-32.291-6.3-25.806-14.088,11.275-13.544-10.25-13.235-9.777-24.991a23.853,23.853,0,0,1,8.5-17.634s-4.957,13.911,2.125,14.3,14.545-4.594,18.177-17.578c6.374-22.784.472-35.128-8.026-40.222a37.478,37.478,0,0,1,17.871,8.475c5.68,5.143-4.452,15.03-4.179,23.266.708,21.361,33.365,4.31,30.375-5.095,0,0,9.128,12.932-2.754,14.891-21.453,3.538-20.539,17.83-12.512,22.533s5.791,14.23,13.039,21.478C216.062,150.94,231.4,156.043,179.472,156.043Z" fill="url(#linear-gradient-8)"/></g></g></g><g id="Layer_3" data-name="Layer 3"><g opacity="0.7"><polygon points="100 221.366 100 277.295 32.114 178.129 100 221.366" fill="#6ca8f8"/><path d="M100,277.8a.5.5,0,0,1-.413-.218L31.7,178.412a.5.5,0,0,1,.681-.7l67.887,43.236a.5.5,0,0,1,.231.422V277.3a.5.5,0,0,1-.352.477A.507.507,0,0,1,100,277.8Zm-66.092-97.93L99.5,275.679V221.64Z" fill="#fff"/><polygon points="167.886 178.129 100 277.295 100 221.366 167.886 178.129" fill="#ce9efa"/><path d="M100,277.8a.507.507,0,0,1-.148-.023.5.5,0,0,1-.352-.477V221.366a.5.5,0,0,1,.232-.422l67.886-43.236a.5.5,0,0,1,.681.7l-67.886,99.165A.5.5,0,0,1,100,277.8Zm.5-56.155v54.039l65.592-95.814Z" fill="#fff"/><polygon points="167.886 164.16 100 125.585 100 207.397 167.886 164.16" fill="#ce9efa"/><path d="M100,207.9a.509.509,0,0,1-.241-.062.5.5,0,0,1-.259-.438V125.585a.5.5,0,0,1,.747-.434l67.886,38.575a.5.5,0,0,1,.022.856l-67.886,43.236A.5.5,0,0,1,100,207.9Zm.5-81.453v80.041l66.417-42.3Z" fill="#fff"/><polygon points="167.886 164.16 100 46.305 100 125.585 167.886 164.16" fill="#87fcda"/><path d="M167.886,164.66a.5.5,0,0,1-.247-.065L99.753,126.02a.5.5,0,0,1-.253-.435V46.305a.5.5,0,0,1,.933-.249l67.886,117.855a.5.5,0,0,1-.433.749ZM100.5,125.294l66.036,37.524L100.5,48.175Z" fill="#fff"/><polygon points="100 46.305 100 125.585 32.114 164.16 100 46.305" fill="#ce9efa"/><path d="M32.114,164.66a.5.5,0,0,1-.355-.147.5.5,0,0,1-.078-.6L99.567,46.056a.5.5,0,0,1,.933.249v79.28a.5.5,0,0,1-.253.435L32.361,164.6A.5.5,0,0,1,32.114,164.66ZM99.5,48.175,33.464,162.818,99.5,125.294Z" fill="#fff"/><polygon points="100 125.585 100 207.397 32.114 164.16 100 125.585" fill="#6ca8f8"/><path d="M100,207.9a.5.5,0,0,1-.268-.079L31.845,164.582a.5.5,0,0,1,.022-.856l67.886-38.575a.5.5,0,0,1,.747.434V207.4a.5.5,0,0,1-.5.5ZM33.083,164.185l66.417,42.3V126.444Z" fill="#fff"/></g><path d="M100,277.8a.5.5,0,0,1-.413-.218L31.7,178.412a.5.5,0,0,1,.681-.7l67.887,43.236a.5.5,0,0,1,.231.422V277.3a.5.5,0,0,1-.352.477A.507.507,0,0,1,100,277.8Zm-66.092-97.93L99.5,275.679V221.64Z" fill="#fff"/><path d="M100,277.8a.507.507,0,0,1-.148-.023.5.5,0,0,1-.352-.477V221.366a.5.5,0,0,1,.232-.422l67.886-43.236a.5.5,0,0,1,.681.7l-67.886,99.165A.5.5,0,0,1,100,277.8Zm.5-56.155v54.039l65.592-95.814Z" fill="#fff"/><path d="M100,207.9a.509.509,0,0,1-.241-.062.5.5,0,0,1-.259-.438V125.585a.5.5,0,0,1,.747-.434l67.886,38.575a.5.5,0,0,1,.022.856l-67.886,43.236A.5.5,0,0,1,100,207.9Zm.5-81.453v80.041l66.417-42.3Z" fill="#fff"/><path d="M167.886,164.66a.5.5,0,0,1-.247-.065L99.753,126.02a.5.5,0,0,1-.253-.435V46.305a.5.5,0,0,1,.933-.249l67.886,117.855a.5.5,0,0,1-.433.749ZM100.5,125.294l66.036,37.524L100.5,48.175Z" fill="#fff"/><path d="M32.114,164.66a.5.5,0,0,1-.355-.147.5.5,0,0,1-.078-.6L99.567,46.056a.5.5,0,0,1,.933.249v79.28a.5.5,0,0,1-.253.435L32.361,164.6A.5.5,0,0,1,32.114,164.66ZM99.5,48.175,33.464,162.818,99.5,125.294Z" fill="#fff"/><path d="M100,207.9a.5.5,0,0,1-.268-.079L31.845,164.582a.5.5,0,0,1,.022-.856l67.886-38.575a.5.5,0,0,1,.747.434V207.4a.5.5,0,0,1-.5.5ZM33.083,164.185l66.417,42.3V126.444Z" fill="#fff"/><path d="M17.806,278.974v30.333a174.191,174.191,0,0,1,31.75-7.458V271.515A174.135,174.135,0,0,0,17.806,278.974Z" fill="#4f4680" stroke="#fff" stroke-linecap="round" stroke-linejoin="round"/><path d="M49.556,295.4v6.454s-4.64-3.487-13.579-3.755A80.194,80.194,0,0,1,49.556,295.4Z" fill="#baacd1" stroke="#fff" stroke-linecap="round" stroke-linejoin="round"/><path d="M182.194,278.974v30.333a174.191,174.191,0,0,0-31.75-7.458V271.515A174.135,174.135,0,0,1,182.194,278.974Z" fill="#232042" stroke="#fff" stroke-linecap="round" stroke-linejoin="round"/><path d="M150.444,295.4v6.454s4.64-3.487,13.579-3.755A80.194,80.194,0,0,0,150.444,295.4Z" fill="#baacd1" stroke="#fff" stroke-linecap="round" stroke-linejoin="round"/><path d="M100,261.248c-39.532,0-64.023,6.512-64.023,6.512v30.334s24.491-6.512,64.023-6.512,64.023,6.512,64.023,6.512V267.76S139.532,261.248,100,261.248Z" stroke="#fff" stroke-linecap="round" stroke-linejoin="round" fill="url(#linear-gradient-9)"/><path d="M190.494,314.176H9.506a.5.5,0,0,1-.5-.5V9.924a.5.5,0,0,1,.5-.5H190.494a.5.5,0,0,1,.5.5V313.676A.5.5,0,0,1,190.494,314.176Zm-180.488-1H189.994V10.424H10.006Z" fill="#fff"/><path d="M52.059,271.445l12.311-1.374.4,3.586-8.112.906.261,2.339,7.347-.82.374,3.345-7.348.821.271,2.427,8.222-.918.4,3.608-12.42,1.387Z" fill="#fff"/><path d="M67.1,269.871l4.254-.349,1.261,15.349-4.254.349Z" fill="#fff"/><path d="M74.506,269.25l6.614-.349c3.867-.2,6.478,1.663,6.656,5.047l0,.044c.193,3.647-2.5,5.706-6.3,5.907l-2.131.112.232,4.395-4.263.225Zm6.71,7.314c1.494-.079,2.4-.942,2.332-2.15l0-.044c-.07-1.319-1.05-1.95-2.567-1.87l-2.021.107.214,4.064Z" fill="#fff"/><path d="M89.323,275.249l7.213-.145.073,3.65L89.4,278.9Z" fill="#fff"/><path d="M100.46,272.257l-2.6.607-.8-3.3,4.515-1.261,3.1.011-.053,15.512-4.2-.015Z" fill="#fff"/><path d="M106.524,281.669l2.548-2.768a5.764,5.764,0,0,0,3.675,1.812c1.407.052,2.269-.62,2.311-1.719v-.044c.042-1.122-.856-1.816-2.2-1.866a4.663,4.663,0,0,0-2.491.677l-2.475-1.524.731-7.767,10.291.386-.132,3.518-6.927-.26-.219,2.326a5.417,5.417,0,0,1,2.484-.457c2.77.1,5.219,1.736,5.093,5.079v.044c-.128,3.407-2.822,5.377-6.56,5.236A8.588,8.588,0,0,1,106.524,281.669Z" fill="#fff"/><path d="M120.3,282.2l2.668-2.651a5.764,5.764,0,0,0,3.591,1.973c1.4.115,2.294-.519,2.384-1.615l0-.044c.092-1.118-.776-1.851-2.113-1.961a4.652,4.652,0,0,0-2.519.566l-2.4-1.632,1.076-7.727,10.262.843-.289,3.508-6.907-.567-.322,2.314a5.422,5.422,0,0,1,2.5-.347c2.763.227,5.136,1.967,4.862,5.3l0,.044c-.279,3.4-3.058,5.245-6.785,4.939A8.587,8.587,0,0,1,120.3,282.2Z" fill="#fff"/><path d="M143.355,280.209a4.656,4.656,0,0,1-3.415.816c-2.945-.387-4.884-2.529-4.491-5.518l.006-.044c.442-3.36,3.325-5.2,6.816-4.742a6.024,6.024,0,0,1,4.459,2.385c.967,1.258,1.457,3.1,1.087,5.914l0,.043c-.654,4.975-3.592,8.074-8.152,7.474a8.372,8.372,0,0,1-5.108-2.513l2.37-2.664a5.138,5.138,0,0,0,3.112,1.653C142.26,283.305,143.085,281.416,143.355,280.209Zm.54-3.769,0-.044a2.069,2.069,0,0,0-1.906-2.382,2.017,2.017,0,0,0-2.411,1.792l-.006.044a2.016,2.016,0,0,0,1.919,2.294A1.985,1.985,0,0,0,143.9,276.44Z" fill="#fff"/></g></svg>'
          ));

        return svg;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {

        require(_exists(id), "ERC721: token does not exist");

        string memory name = string(abi.encodePacked('Burny boy ',Strings.toString(id)));
        string memory description = string(abi.encodePacked('From when the basefee was ',Strings.toString(tokenBaseFee[id]/uint(1000000000))));
        string memory image = Base64.encode(bytes(generateSVGofTokenById(id)));

        return
            string(
                abi.encodePacked(
                    'data:application/json,',
                            abi.encodePacked(
                                '{"name":"',
                                name,
                                '", "description":"',
                                description,
                                '", "image": "',
                                'data:image/svg+xml;base64,',
                                image,
                                '"}'
                            )
                )
            );
    }
}
