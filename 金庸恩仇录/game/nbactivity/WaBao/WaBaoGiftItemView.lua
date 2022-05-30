local data_item_item = require("data.data_item_item")
local btnGetRes = {
normal = "#btn_get_n.png",
pressed = "#btn_get_p.png",
disabled = "#btn_get_p.png"
}

local WaBaoGiftItemView = class("WaBaoGiftItemView", function()
	return display.newLayer("WaBaoGiftItemView")
end)

function WaBaoGiftItemView:ctor(size, data, mainscene, parent)
	self:setContentSize(size)
	self:load()
	self._leftToRightOffset = 5
	self._topToDownOffset = 2
	self._frameSize = size
	self._containner = nil
	self._padding = {
	left = 15,
	right = 15,
	top = 15,
	down = 20
	}
	self._data = data
	self:setUpView()
	self._mainMenuScene = mainscene
	self._parent = parent
	self._icon = nil
end

function WaBaoGiftItemView:setUpView()
	self._containner = display.newScale9Sprite("#reward_item_bg.png", 0, 0, cc.size(self._frameSize.width - self._leftToRightOffset * 2, self._frameSize.height - self._topToDownOffset * 2)):pos(self._frameSize.width / 2, self._frameSize.height / 2 + 30)
	local containnerSize = self._containner:getContentSize()
	self._containner:align(display.CENTER)
	self:addChild(self._containner)
	local titleBngHeight = 40
	local marginTop = 5
	local offset = 10
	local marginRight = 120
	local itemsViewBngs = display.newScale9Sprite("#heroinfo_cost_st_bg.png", 0, 0, cc.size(containnerSize.width - self._padding.left - self._padding.right, containnerSize.height - self._padding.top - self._padding.down - marginTop)):pos(self._padding.left, self._padding.down):addTo(self._containner)
	itemsViewBngs:setAnchorPoint(cc.p(0, 0))
	self._icons = {}
	for i = 1, #self._data do
		table.insert(self._icons, self:createItem(i, itemsViewBngs, itemsViewBngs:getContentSize(), self._data[i]))
	end
end

function WaBaoGiftItemView:getIcon(index)
	return self._icons[index], self._data[index]
end

function WaBaoGiftItemView:getIconNum()
	return #self._data
end

function WaBaoGiftItemView:createItem(index, itemsViewBngs, containnerSize, data)
	local marginTop = 60
	local marginLeft = 10
	local offset = 130
	if tonumber(data.type) == ITEM_TYPE.zhenqi then
		self._icon = require("game.Spirit.SpiritIcon").new({
		resId = tonumber(data.id),
		bShowName = false
		})
	else
		self._icon = ResMgr.refreshIcon({
		id = tonumber(data.id),
		resType = ResMgr.getResType(tonumber(data.type)),
		iconNum = data.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = cc.c3b(0, 255, 0),
		numLblOutColor = cc.c3b(0, 0, 0),
		itemType = tonumber(data.type)
		})
	end
	self._icon:setAnchorPoint(cc.p(0, 0.5))
	index = index - 1
	local paddingLeft = 27
	if math.floor(index / 4) == 0 then
		self._icon:setPosition(cc.p(paddingLeft + (index % 4 == 0 and 0 or index % 4) * offset, containnerSize.height - marginTop - math.floor(index / 4) * 100))
	else
		self._icon:setPosition(cc.p(paddingLeft + (index % 4 == 0 and 0 or index % 4) * offset, containnerSize.height - marginTop - math.floor(index / 4) * 100 - 30 * math.floor(index / 4)))
	end
	local iconSize = self._icon:getContentSize()
	local iconPosX = self._icon:getPositionX()
	local iconPosY = self._icon:getPositionY()
	if data.type == ITEM_TYPE.zhenqi then
		self._icon:setPositionY(self._icon:getPositionY() - 10)
	end
	local nameColor = ResMgr.getItemNameColorByType(tonumber(data.id), ResMgr.getResType(tonumber(data.type)))
	local name = ResMgr.getItemNameByType(tonumber(data.id), ResMgr.getResType(tonumber(data.type)))
	local nameLabel = ui.newTTFLabelWithShadow({
	text = name,
	size = 20,
	color = nameColor,
	shadowColor = cc.c3b(0, 0, 0),
	font = FONTS_NAME.font_fzcy,
	})
	
	nameLabel:align(display.TOP_CENTER, iconSize.width/2, -5)
	self._icon:addChild(nameLabel)
	
	if tonumber(data.type) == ITEM_TYPE.zhenqi then
		nameLabel:setPositionY(nameLabel:getPositionY() + 10)
		self._icon:setPositionY(self._icon:getPositionY() + 10.5)
		self._icon:setScale(0.98)
	end
	itemsViewBngs:addChild(self._icon)
	return self._icon
end

function WaBaoGiftItemView:load()
	display.addSpriteFramesWithFile("ui/ui_reward.plist", "ui/ui_reward.png")
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
end

return WaBaoGiftItemView