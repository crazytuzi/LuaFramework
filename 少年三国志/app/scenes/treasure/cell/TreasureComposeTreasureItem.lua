local TreasureComposeTreasureItem = class("TreasureComposeTreasureItem",function ()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/treasure_TreasureComposeTreasureItem.json")
end)
require("app.cfg.treasure_info")
require("app.cfg.treasure_compose_info")
local EffectNode = require "app.common.effects.EffectNode"

function TreasureComposeTreasureItem:ctor(_id,buttonName,...)
    self._name = buttonName
    self._composeId = _id 
    local compose = treasure_compose_info.get(_id)
    local treasure = treasure_info.get(compose.treasure_id)
    local treasureImage = UIHelper:seekWidgetByName(self,"ImageView_treasureItem")

    local bgImage = UIHelper:seekWidgetByName(self,"Image_item_bg")
    bgImage = tolua.cast(bgImage,"ImageView")
    bgImage:loadTexture(G_Path.getEquipIconBack(treasure.quality))
    treasureImage = tolua.cast(treasureImage,"ImageView")
    treasureImage:loadTexture(G_Path.getTreasureIcon(treasure.res_id),UI_TEX_TYPE_LOCAL)
    local itemButton = UIHelper:seekWidgetByName(self,"Button_treasureItem")
    itemButton = tolua.cast(itemButton,"Button")
    itemButton:setTouchEnabled(true)
    itemButton:setName(buttonName)
    itemButton:loadTextureNormal(G_Path.getEquipColorImage(treasure.quality,G_Goods.TYPE_TREASURE))
    itemButton:loadTexturePressed(G_Path.getEquipColorImage(treasure.quality,G_Goods.TYPE_TREASURE))
    self:showTips()
end

function TreasureComposeTreasureItem:getButtonName()
    return self._name
end 

function TreasureComposeTreasureItem:showTips()
    local tips = UIHelper:seekWidgetByName(self,"Image_tips")
    if tips ~= nil then
        tips:setVisible(self:checkFragment())
    end
end



--检查碎片是否足够合成
function TreasureComposeTreasureItem:checkFragment()
    local CheckFunc = require("app.scenes.common.CheckFunc")
    return CheckFunc.checkTreasureComposeByComposeId(self._composeId)
end 

--是否显示背景图片
function TreasureComposeTreasureItem:showBackgroundImage(isShow)
    local bgImage = UIHelper:seekWidgetByName(self,"ImageView_bg")
    bgImage:setVisible(isShow)
end

function TreasureComposeTreasureItem:getWidth()
	local width = self:getContentSize().width
	return width
end

function TreasureComposeTreasureItem:playLightEffect(duration, callback)
    if not self._lightEffect then
        self._lightEffect = EffectNode.new("effect_around1", function() end)
        self._lightEffect:setScale(1.7)
        self._lightEffect:play()
        UIHelper:seekWidgetByName(self, "ImageView_32743"):addNode(self._lightEffect)
    end

    uf_funcCallHelper:callAfterDelayTimeOnObj(self, duration, nil, function()
        if self._lightEffect then
            self._lightEffect:removeFromParentAndCleanup(true)
            self._lightEffect = nil
        end

        if callback then
            callback()
        end
    end)
end

return TreasureComposeTreasureItem
