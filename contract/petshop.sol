//SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract petShop {
    uint internal petCount;
    uint256 internal adoptionFEE;
    address internal petShopOwner;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    constructor(uint256 _adoptionFEE) {
        petShopOwner = payable(msg.sender);
        adoptionFEE = _adoptionFEE * (10**18);
    }

    struct pet {
        uint id;
        string petName;
        string imageURL;
        uint age;
        string breed;
        string attributes;
        string location;
        bool adopted;
        address adopter;
    }

    modifier onlyOwner() {
        require(msg.sender == petShopOwner, "Function can only be accessed by owner.");
        _;
    }

    mapping(uint => pet) internal pets;

    // Create pet details
    function createPetDetails(
        string memory _petName,
        string memory _imageURL,
        uint _age,
        string memory _breed,
        string memory _attributes,
        string memory _location
    ) onlyOwner() public {
        uint _id = petCount;
        pet storage _pet = pets[_id];
        _pet.id = _id;
        _pet.petName = _petName;
        _pet.imageURL = _imageURL;
        _pet.age = _age;
        _pet.breed = _breed;
        _pet.attributes = _attributes;
        _pet.location = _location;
        petCount++;
    }

    // Get Pet details
    function getPetDetails(uint _id) public view returns (
        string memory,
        string memory,
        uint,
        string memory,
        string memory,
        string memory,
        bool,
        address
    ){
        return (
            pets[_id].petName,
            pets[_id].imageURL,
            pets[_id].age,
            pets[_id].breed,
            pets[_id].attributes,
            pets[_id].location,
            pets[_id].adopted,
            pets[_id].adopter
        );
    }

    // Adopting a pet
    function adopt(uint _petID) public payable {
        require(pets[_petID].adopted == false, "Pet has already been adopted");
        require(IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                address(this),
                adoptionFEE
            ),
            "Transfer failed"
        );
        pets[_petID].adopter = msg.sender;
        pets[_petID].adopted = true;
    }

    function getAdoptionFee() public view returns(uint256){
        return adoptionFEE;
    }

    function petShopBalance() public view returns(uint256){
        return IERC20Token(cUsdTokenAddress).balanceOf(address(this));
    }

    function checkOwner() public view returns(bool) {
        if (msg.sender == petShopOwner) {
            return true;
        } else {
            return false;
        }
    }

    function withdraw(uint256 amount) onlyOwner public {
        require(IERC20Token(cUsdTokenAddress).balanceOf(address(this)) >= amount, "Insuffcient Contract Balance");
        require(IERC20Token(cUsdTokenAddress).transfer(petShopOwner, amount),"Withdrawal failed");
    }

    function getPetCount() public view returns (uint) {
        return (petCount);
    }

}