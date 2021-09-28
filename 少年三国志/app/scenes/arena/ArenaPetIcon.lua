local ArenaPetIcon = class("ArenaPetIcon",function ()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/treasure_TreasureComposeTreasureItem.json")
end)
require("app.cfg.pet_info")

function ArenaPetIcon:ctor(_id,...)
    self._name = "buttonName" .. _id
    local petInfo = pet_info.get(_id)
    local petImage = UIHelper:seekWidgetByName(self, "ImageView_treasureItem")
    petImage = tolua.cast(petImage, "ImageView")
    petImage:loadTexture(G_Path.getPetIcon(petInfo.res_id), UI_TEX_TYPE_LOCAL)
    local itemButton = UIHelper:seekWidgetByName(self,"Button_treasureItem")
    itemButton = tolua.cast(itemButton,"Button")
    itemButton:setTouchEnabled(true)
    itemButton:setName(self._name)

    itemButton:loadTextureNormal("ui/zhengrong/chongwu_touxiangkuang.png")
    itemButton:loadTexturePressed("ui/zhengrong/chongwu_touxiangkuang.png")
end

function ArenaPetIcon:getButtonName()
    return self._name
end 

--是否显示背景图片
function ArenaPetIcon:showBackgroundImage(isShow)
    local bgImage = UIHelper:seekWidgetByName(self,"ImageView_bg")
    bgImage:setVisible(isShow)
end

function ArenaPetIcon:getWidth()
	local width = self:getContentSize().width
	return width
end

return ArenaPetIcon
