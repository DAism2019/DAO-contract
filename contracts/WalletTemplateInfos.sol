pragma solidity ^0.5.0;
import "./Ownable.sol";

contract WalletTemplateInfos is Ownable {
    address[] public allTemplates;              // all address of wallet_template
    mapping(address => bool) public isFrozen;   // template is frozen or not
    mapping(address => uint) public templateIndexes;        // all indexes of templates

    event addTemplateSuc(uint _index,address _address);
    event frozenTemplateSuc(uint _index,address _address);
    event unFrozenTemplateSuc(uint _index,address _address);

    function getTemplateCount() external view returns(uint){
        /**
            @dev Get the amount of all templates
        */
        return allTemplates.length;
    }

    function isTemplate(address _template) public view returns(bool) {
        /**
            @dev Judge a address is wallet_template or not
            @param _template The address to judge
        */
        if(allTemplates.length == 0){
            return false;
        }else{
            return allTemplates[templateIndexes[_template]] == _template;
        }
    }

    function addTemplate(address template) external onlyOwner {
        /**
            @dev Add a template
            @param template The address of template
        */
        require(template != address(0),"WalletTemplateInfos: zero_address");
        require(!isTemplate(template),"WalletTemplateInfos: template has existed");
        uint index = allTemplates.length;
        templateIndexes[template] = index;
        allTemplates.push(template);
        emit addTemplateSuc(index,template);
    }

    function frozenTemplateByIndex(uint index) external onlyOwner {
        /**
            @dev Frozen a template to prevent been used;
            @param index The index of template
        */
        require(index < allTemplates.length,"WalletTemplateInfos: global index out of bounds");
        address template = allTemplates[index];
        require(!isFrozen[template],"WalletTemplateInfos: template has been frozen");
        isFrozen[template] = true;
        emit frozenTemplateSuc(index,template);
    }

    function unFrozenTemlateByIndex(uint index) external onlyOwner {
        /**
            @dev Unfrozen a template to be used;
            @param index The index of template
        */
        require(index < allTemplates.length,"WalletTemplateInfos: global index out of bounds");
        address template = allTemplates[index];
        require(isFrozen[template],"WalletTemplateInfos: template has not been frozen");
        isFrozen[template] = false;
        emit unFrozenTemplateSuc(index,template);
    }
}
