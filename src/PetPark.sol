//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract PetPark is Ownable {

    uint256 constant _MIN_AGE_W_FISH = 40;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Parrot,
        Rabbit
    }

    enum Gender {
        Male,
        Female
    }

    struct Borrower {
        Gender gender;
        uint256 age;
        AnimalType borrowed;
    }

    event Added (AnimalType, uint256);
    event Borrowed (AnimalType);

    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => Borrower) internal _borrowers;


    function add(AnimalType animalType, uint256 number) external onlyOwner {
        require(animalType != AnimalType.None, "Invalid animal");
        animalCounts[animalType] += number;
        emit Added(animalType, number);
    }

    function borrow(uint256 age, Gender gender, AnimalType animalType) external {
        _validateInputs(age, animalType, gender);

        if (gender == Gender.Male) {
            _manBorrows(animalType);
        } else {
            _womanBorrows(animalType, age);
        }

        _borrowers[msg.sender] = Borrower(gender, age, animalType);
        animalCounts[animalType]--;

        emit Borrowed(animalType);
    }

    function giveBackAnimal() external onlyOwner {
        AnimalType borrowedAnimalType = _borrowers[msg.sender].borrowed;
        require(borrowedAnimalType != AnimalType.None, "No borrowed pets");

        animalCounts[borrowedAnimalType] += 1;
        _borrowers[msg.sender].borrowed = AnimalType.None;
    }

    // INTERNAL FUNCTIONS

    function _manBorrows(AnimalType animalType) internal pure {
        require(animalType == AnimalType.Dog || animalType == AnimalType.Fish, "Invalid animal for men");
    }

    function _womanBorrows(AnimalType animalType, uint256 age) internal pure {
        require(!(animalType == AnimalType.Cat && age < _MIN_AGE_W_FISH), "Invalid animal for women under 40");
    }

    function _validateInputs(uint256 age, AnimalType animalType, Gender gender) internal view {
        require(animalType != AnimalType.None, "Invalid animal type");
        require(age != 0, "Age cannot be zero");

        if(_borrowers[msg.sender].age != 0) {
            require(_borrowers[msg.sender].age == age, "Invalid Age");
            require(_borrowers[msg.sender].gender == gender, "Invalid Gender");
        }

        require(animalCounts[animalType] != 0, "Selected animal not available");
        require(_borrowers[msg.sender].borrowed == AnimalType.None, "Already adopted a pet");
    }

}