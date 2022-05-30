local data_item_item = require("data.data_item_item")
local data_taozhuang_taozhuang = require("data.data_taozhuang_taozhuang")

local EquipSuitInfo = class("EquipSuitInfo", function()
	return display.newNode()
end)

function EquipSuitInfo:ctor(param)
	self.curId = param.curId
	self.suitId = data_item_item[self.curId].Suit
	self.suitData = data_taozhuang_taozhuang[self.suitId]
	self.itemType = param.itemType
	self.count = 0
	for i = 1, 3 do
		if self.suitData["nature" .. i] ~= nil then
			self.count = self.count + checkint(#self.suitData["nature" .. i] / 2)
		end
	end
	dump("self.count " .. self.count)
	self.height = self.count * 45 + 200
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("equip/suit_info.ccbi", proxy, self._rootnode, self, cc.size(640, self.height))
	node:setAnchorPoint(cc.p(0.5, 1))
	self:addChild(node)
	self._rootnode.suit_name:setString(self.suitData.name)
	self.member = self.suitData.member
	for i = 1, #self.member do
		local iconBg = self._rootnode["icon_bg_" .. i]
		local weaponIcon = display.newSprite()
		local isExist
		if self.itemType == 3 then
			isExist = false
		else
			isExist = HeroSettingModel.isEquipExist(self.member[i])
		end
		ResMgr.refreshIcon({
		itemBg = weaponIcon,
		id = self.member[i],
		resType = ResMgr.EQUIP,
		isGray = not isExist
		})
		weaponIcon:setPosition(iconBg:getContentSize().width / 2, iconBg:getContentSize().height * 0.58)
		iconBg:addChild(weaponIcon)
		self.weaponName = ui.newTTFLabelWithShadow({
		text = "",
		size = 20,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_CENTER,
		dimensions = cc.size(100, 60),
		valign = ui.TEXT_ALIGN_TOP,
		color = display.COLOR_WHITE,
		shadowColor = display.COLOR_BLACK,
		})
		ResMgr.refreshItemName({
		label = self.weaponName,
		resId = self.member[i]
		})
		self.weaponName:setPosition(iconBg:getContentSize().width / 2, 0)
		iconBg:addChild(self.weaponName)
	end
	self.itemTable = {}
	local nums = {
	2,
	3,
	4
	}
	for i = 1, 3 do
		if self.suitData["nature" .. i] ~= nil then
			local item = require("game.Equip.EquipSuitItem").new({
			equipNum = nums[i],
			natureTable = self.suitData["nature" .. i],
			valTable = self.suitData["num" .. i],
			suitId = self.suitId
			})
			self._rootnode.item_node:addChild(item)
			if i ~= 1 then
				item:setPosition(0, self.itemTable[i - 1]:getPositionY() - self.itemTable[i - 1]:getHeight())
			end
			self.itemTable[#self.itemTable + 1] = item
		end
	end
end

function EquipSuitInfo:getHeight()
	return self.height
end

return EquipSuitInfo