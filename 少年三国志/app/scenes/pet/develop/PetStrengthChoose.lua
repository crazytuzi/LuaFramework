--PetStrengthChoose.lua
local BaseChooseLayer = require("app.scenes.common.BaseChooseLayer")
local PetStrengthChoose = class ("PetStrengthChoose", function ( )
    return BaseChooseLayer.create()
end )

function PetStrengthChoose:getSupplyExp( item )
    return item.info.item_value
end

function PetStrengthChoose:checkItem( items)
    return false
end

function PetStrengthChoose:getItem( item , index)
    return require("app.scenes.pet.develop.PetStrengthChooseItem").new(list, index)
end

function PetStrengthChoose:checkChooseItem( item , isSelected)
    local length = table.nums(self._selectedItems)
    if length >= 5 and isSelected then
        G_MovingTip:showMovingTip(G_lang:get("LANG_PET_FOOD_TOO_MUCH"))
        return false
    end

    if self._totalExp > G_Me.bagData.petData:getStrengthLeftExp(self._item) and isSelected then
        G_MovingTip:showMovingTip(G_lang:get("LANG_ENOUGH_EXP_TIPS"))
        return false
    end
    
    if G_Me.bagData.petData:getStrengthMoney(self._item,self._totalExp + item.info.item_value) > G_Me.userData.money and isSelected then
        G_MovingTip:showMovingTip(G_lang:get("LANG_MONEY_NOTENOUGH_TIPS"))
        return false
    end
    return true
end

function PetStrengthChoose:setBaseItem( item )
    self._item = item
end

function PetStrengthChoose:getHighTxt( )
    return G_lang:get("LANG_QIANGHUA_HAS_HIGH_LEVEL_CAILIAO")
end

function PetStrengthChoose.showPetChooseLayer( parent, itemList, selectedItems, curItem, func )
    local chooseLayer = PetStrengthChoose.new()
    uf_sceneManager:getCurScene():addChild(chooseLayer)   
    local needExp = G_Me.bagData.petData:getStrengthNextLevelExp(curItem) - G_Me.bagData.petData:getLeftStrengthExp(curItem)
    chooseLayer:setBaseItem(curItem)
    chooseLayer:initItemList(itemList, selectedItems, needExp, func)
end

return PetStrengthChoose

