--TreasureStrengthChoose.lua
local BaseChooseLayer = require("app.scenes.common.BaseChooseLayer")
local TreasureStrengthChoose = class ("TreasureStrengthChoose", function ( )
    return BaseChooseLayer.create()
end )

function TreasureStrengthChoose:getSupplyExp( item )
    return item:getSupplyExp()
end

function TreasureStrengthChoose:checkItem( items)
    for key, value in pairs(items) do 
            local treasureBaseInfo = value:getInfo()
            if treasureBaseInfo and treasureBaseInfo.quality >= 4 and treasureBaseInfo.type ~= 3 then
                return true
            end
    end
    return false
end

function TreasureStrengthChoose:getItem( item , index)
    return require("app.scenes.treasure.develope.TreasureStrengthChooseItem").new(list, index)
end

function TreasureStrengthChoose:checkChooseItem( item , isSelected)
    local length = table.nums(self._selectedItems)
    if length >= 5 and isSelected then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TREASURE_TOO_MUCH"))
        return false
    end

    if self._totalExp > self._item:getStrengthLeftExp() and isSelected then
        G_MovingTip:showMovingTip(G_lang:get("LANG_ENOUGH_EXP_TIPS"))
        return false
    end

    if self._item:getStrengthMoney(self._totalExp + item:getSupplyExp()) > G_Me.userData.money and isSelected then
        G_MovingTip:showMovingTip(G_lang:get("LANG_MONEY_NOTENOUGH_TIPS"))
        return false
    end
    return true
end

function TreasureStrengthChoose:setBaseItem( item )
    self._item = item
end

function TreasureStrengthChoose:getHighTxt( )
    return G_lang:get("LANG_QIANGHUA_HAS_HIGH_LEVEL_CAILIAO")
end

function TreasureStrengthChoose.showTreasureChooseLayer( parent, itemList, selectedItems, curItem, func )
    local chooseLayer = TreasureStrengthChoose.new()
    uf_sceneManager:getCurScene():addChild(chooseLayer)   
    local needExp = curItem:getStrengthNextLevelExp() - curItem:getLeftStrengthExp()
    chooseLayer:setBaseItem(curItem)
    chooseLayer:initItemList(itemList, selectedItems, needExp, func)
end

return TreasureStrengthChoose

