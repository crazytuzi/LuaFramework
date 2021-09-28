-- GroupBuyGoodsItem.lua
local GroupBuyCommon         = require("app.scenes.groupbuy.GroupBuyCommon")

local GroupBuyGoodsItem = class("GroupBuyGoodsItem",function ()
	return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/groupbuy_GoodsItem.json")
end)

function GroupBuyGoodsItem:ctor(id, buttonName, ...)
	self._id = id
	self._name = buttonName

	local item = G_Me.groupBuyData:getGoodsItemById(self._id)
	if item == nil then return end
	local goods = G_Goods.convert(item.type, item.value, item.size)
	if goods == nil then return end

	local itemButton = UIHelper:seekWidgetByName(self,"Button_Item")
    itemButton = tolua.cast(itemButton,"Button")
    itemButton:setTouchEnabled(true)
    itemButton:setName(buttonName)
    itemButton:loadTextureNormal(G_Path.getEquipColorImage(goods.quality, goods.type))
    itemButton:loadTexturePressed(G_Path.getEquipColorImage(goods.quality, goods.type))

    local bgImage = UIHelper:seekWidgetByName(self,"Image_Item_BG")
    bgImage = tolua.cast(bgImage,"ImageView")
    bgImage:loadTexture(G_Path.getEquipIconBack(goods.quality))

    local iconImage = UIHelper:seekWidgetByName(self,"Image_Icon")
    iconImage = tolua.cast(iconImage,"ImageView")
    iconImage:loadTexture(goods.icon)

    self._selectImage = UIHelper:seekWidgetByName(self,"Image_Select")
    self._selectImage = tolua.cast(self._selectImage,"ImageView")
    self._selectImage:setVisible(false)

    self:updateData()

end

function GroupBuyGoodsItem:updateData()
    local item = G_Me.groupBuyData:getGoodsItemById(self._id)
    if item == nil then return end
    local offLabel = UIHelper:seekWidgetByName(self,"Label_Off")
    offLabel = tolua.cast(offLabel,"Label")
    local buyTimesData = G_Me.groupBuyData:getItemBuyTimesInfoById(self._id) or {}
    local nowBuyNum = buyTimesData.server_count or 0
    local pre = GroupBuyCommon.calProgressRatio(item, nowBuyNum)
    local offLevel = math.floor(pre / 25)
    local off = item.initial_off / 100
    if offLevel > 0 then
        off = item[string.format("off_price_%d", offLevel)] / 100
    end
    offLabel:setText(off .. G_lang:get("LANG_GROUP_BUY_AWARD_OFF"))
    if off >= 7 then
        offLabel:setColor(Colors.qualityColors[3])
    else
        offLabel:setColor(Colors.qualityColors[7])
    end
    offLabel:createStroke(Colors.strokeBlack, 1)
end

function GroupBuyGoodsItem:getWidth()
	local width = self:getContentSize().width
	return width
end

function GroupBuyGoodsItem:getButtonName()
	return self._name
end

function GroupBuyGoodsItem:setSelected(flag)
	self._selectImage:setVisible(flag)
end

function GroupBuyGoodsItem:getItemId()
	return self._id
end

return GroupBuyGoodsItem
