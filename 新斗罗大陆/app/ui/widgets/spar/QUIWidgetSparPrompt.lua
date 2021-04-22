-- @Author: xurui
-- @Date:   2017-04-08 18:37:51
-- @Last Modified by:   vicentboo
-- @Last Modified time: 2019-09-02 14:31:48
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparPrompt = class("QUIWidgetSparPrompt", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetSparBox = import(".QUIWidgetSparBox")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetSparPromptSuitClient = import("...widgets.spar.QUIWidgetSparPromptSuitClient")

function QUIWidgetSparPrompt:ctor(options)
	local ccbFile = "ccb/Dialog_spar_tips.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetSparPrompt.super.ctor(self, ccbFile, callBack, options)

	if options then
		self._itemId = options.itemId
		self._itemType = options.itemType
		self._sparInfo = options.sparInfo
	end

	self._suitClient = {}
end

function QUIWidgetSparPrompt:onEnter()
	self:setSparInfo()

	self:setSuitClient()
end

function QUIWidgetSparPrompt:onExit()
end

function QUIWidgetSparPrompt:setSparInfo()
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	if itemInfo == nil then return end

	local itemType = ITEM_TYPE.ITEM
	local haveNum = ""
	local prop = {}
	if itemInfo.type == ITEM_CONFIG_TYPE.SPAR_PIECE then
	  	local crafts = remote.items:getItemsByMaterialId(tonumber(self._itemId)) or {}
	  	local needNum = crafts[1].component_num_1 or 0
	  	local goodsNum = remote.items:getItemsNumByID(self._itemId)
  		haveNum = goodsNum.."/"..needNum

  		self._sparItemId = crafts[1].item_id

		if self._item == nil then
			self._item = QUIWidgetItemsBox.new()
			self._ccbOwner.node_spar:addChild(self._item)
			self._ccbOwner.node_spar:setScale(0.8)
		end
		self._item:setGoodsInfo(self._itemId, itemType, 0, false)
	else
		itemType = ITEM_TYPE.SPAR
		self._ccbOwner.node_have_num:setVisible(false)
  		self._sparItemId = tonumber(self._itemId)

		if q.isEmpty(self._sparInfo) then
	  		self._sparItemId = tonumber(self._itemId)
			if self._item == nil then
				self._item = QUIWidgetItemsBox.new()
				self._ccbOwner.node_spar:addChild(self._item)
				self._ccbOwner.node_spar:setScale(0.8)
			end
			self._item:setGoodsInfo(self._itemId, itemType, 0, false)

			prop = remote.spar:countSparProp({itemId = self._itemId, level = 1, grade = 0}).prop
		else
			if self._item == nil then
				self._item = QUIWidgetSparBox.new()
				self._ccbOwner.node_spar:addChild(self._item)
				self._ccbOwner.node_spar:setScale(0.8)
			end
			local sparPos = 1
			if itemInfo.type == ITEM_CONFIG_TYPE.OBSIDIAN then
				sparPos = 2
			end
			self._item:setGemstoneInfo(self._sparInfo, sparPos)
			self._item:setNameVisible(false)

			prop = self._sparInfo.prop
		end
	end

	self._ccbOwner.node_spar_prop:setVisible(false)
	if q.isEmpty(prop) == false then

		local propStr = remote.spar:setPropInfo(prop,true,true)


		self._ccbOwner.node_spar_prop:setVisible(true)
		local index = 1
		local connectStr = function (str)
			if self._ccbOwner["tf_prop"..index] then
				self._ccbOwner["tf_prop"..index]:setString(str)
			end
		end


		for i,v in ipairs(propStr) do
			connectStr(v.name.."+"..v.value)
			index = index + 1
		end

		-- if prop.hp_value then
		-- 	connectStr("生命＋"..prop.hp_value)
		-- 	index = index + 1
		-- end
		-- if prop.attack_value then
		-- 	connectStr("攻击＋"..prop.attack_value)
		-- 	index = index + 1
		-- end
		-- if prop.armor_physical then
		-- 	connectStr("物防＋"..prop.armor_physical)
		-- 	index = index + 1
		-- end
		-- if prop.armor_magic then
		-- 	connectStr("法防＋"..prop.armor_magic)
		-- 	index = index + 1
		-- end
		-- if prop.hp_percent then
		-- 	connectStr(string.format("生命＋%d%%", (prop.hp_percent or 0)*100))
		-- 	index = index + 1
		-- end
		-- if prop.attack_percent then
		-- 	connectStr(string.format("攻击＋%d%%", (prop.attack_percent or 0)*100))
		-- 	index = index + 1
		-- end
		-- if prop.armor_physical_percent then
		-- 	connectStr(string.format("物防＋%d%%", (prop.armor_physical_percent or 0)*100))
		-- 	index = index + 1
		-- end
		-- if prop.armor_magic_percent then
		-- 	connectStr(string.format("法防＋%d%%", (prop.armor_magic_percent or 0)*100))
		-- 	index = index + 1
		-- end
	end

	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemInfo.colour]] or COLORS.j
	self._ccbOwner.tf_spar_name:setColor(fontColor)
	self._ccbOwner.tf_spar_name:setString(itemInfo.name)
	self._ccbOwner.tf_spar_num:setString(haveNum)
end

function QUIWidgetSparPrompt:setSuitClient()
	local suitInfo = remote.spar:getSparSuitInfosBySparId(self._sparItemId, 0)
	local row = 0
	local contentSize = CCSize(0, 0)
	for i = 1, #suitInfo do
		if self._suitClient[i] == nil then
			self._suitClient[i] = QUIWidgetSparPromptSuitClient.new()
			self._ccbOwner.node_suit_client:addChild(self._suitClient[i])

		end
		contentSize = self._suitClient[i]:getContentSize()
		self._suitClient[i]:setPositionY(row*(-contentSize.height) - 10)
		self._suitClient[i]:setPositionX(-5)
		self._suitClient[i]:setSuitInfo(suitInfo[i])
		row = row + 1
	end
	row = row - 1

	local offsetY = row*contentSize.height
	local positionY = self._ccbOwner.node_spar_info:getPositionY()
	self._ccbOwner.node_spar_info:setPositionY(positionY+(offsetY/2))
	local bgContentSize = self._ccbOwner.background:getContentSize()
	self._ccbOwner.background:setContentSize(CCSize(bgContentSize.width, bgContentSize.height + offsetY))
end

return QUIWidgetSparPrompt