pragma solidity ^0.4.18;

import './math/SafeMath.sol';
import './ownership/Ownable.sol';

contract StagedCrowdsale is Ownable {

  using SafeMath for uint;

  struct Milestone {
    uint hardcap;
    uint price;
    uint invested;
    uint closed;
  }

  uint public totalPeriod;

  Milestone[] public milestones;

  function milestonesCount() public view returns(uint) {
    return milestones.length;
  }

  function addMilestone(uint hardcap, uint price) public onlyOwner {
    require(hardcap > 0 && price > 0);
    Milestone memory milestone = Milestone(hardcap.mul(1 ether), price, 0, 0);
    milestones.push(milestone);
    totalHardcap = totalHardcap.add(milestone.hardcap);
  }

  function removeMilestone(uint8 number) public onlyOwner {
    require(number >=0 && number < milestones.length);
    Milestone storage milestone = milestones[number];
    totalHardcap = totalHardcap.sub(milestone.hardcap);
    delete milestones[number];
    for (uint i = number; i < milestones.length - 1; i++) {
      milestones[i] = milestones[i+1];
    }
    milestones.length--;
  }

  function changeMilestone(uint8 number, uint hardcap, uint price) public onlyOwner {
    require(number >= 0 &&number < milestones.length);
    Milestone storage milestone = milestones[number];
    totalHardcap = totalHardcap.sub(milestone.hardcap);
    milestone.hardcap = hardcap.mul(1 ether);
    milestone.price = price;
    totalHardcap = totalHardcap.add(milestone.hardcap);
  }

  function insertMilestone(uint8 numberAfter, uint hardcap, uint price) public onlyOwner {
    require(numberAfter < milestones.length);
    Milestone memory milestone = Milestone(hardcap.mul(1 ether), price, 0, 0);
    totalHardcap = totalHardcap.add(milestone.hardcap);
    milestones.length++;
    for (uint i = milestones.length - 2; i > numberAfter; i--) {
      milestones[i + 1] = milestones[i];
    }
    milestones[numberAfter + 1] = milestone;
  }

  function clearMilestones() public onlyOwner {
    for (uint i = 0; i < milestones.length; i++) {
      delete milestones[i];
    }
    milestones.length -= milestones.length;
    totalHardcap = 0;
  }

  function lastSaleDate(uint start) public view returns(uint) {
    return start + totalPeriod * 1 days;
  }

  function currentMilestone() public view returns(uint) {
    for(uint i=0; i < milestones.length; i++) {
      if(milestones[i].closed == 0) {
        return i;
      }
    }
    revert();
  }

}
