--
-- Author: xurui
-- Date: 2016-07-26 14:35:49
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstoneBackPackDetail = class("QUIWidgetGemstoneBackPackDetail", QUIWidget)

local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetGemstoneBackPackDetail:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_Packsack2.ccbi"
	local callBacks = {}
	QUIWidgetGemstoneBackPackDetail.super.ctor(self, ccbFile, callBacks, options)

	self._stoneItem = {}
end

function QUIWidgetGemstoneBackPackDetail:setDetailInfo(props, stoneInfos, effects , gemQuality)
	self._height = 320
	local suitId = nil
	local itemId = nil
	local index = 0
	for i = 1, 6 do
		self._ccbOwner["tf_prop_"..i]:setVisible(true)
		if props[i] ~= nil then
			self._ccbOwner["tf_prop_"..i]:setString(props[i].name.." +"..props[i].value)
			index = index + 1
		else
			self._ccbOwner["tf_prop_"..i]:setVisible(false)
		end
	end
	if index <= 2 then
		self._ccbOwner.node_content:setPositionY(40)
		self._height = self._height - 80
	elseif index <= 4 then
		self._ccbOwner.node_content:setPositionY(0)
		self._height = self._height - 40
	else
		self._ccbOwner.node_content:setPositionY(-40)
	end

	for i = 1, 4 do
		if self._stoneItem[i] == nil then
			self._stoneItem[i] = QUIWidgetGemstonesBox.new()
			self._ccbOwner["node_stone_"..i]:addChild(self._stoneItem[i])
			self._ccbOwner["node_stone_"..i]:setScale(0.75)
			self._stoneItem[i]:addEventListener(QUIWidgetGemstonesBox.EVENT_CLICK, handler(self, self._clickEvent))
		end
        self._stoneItem[i]:setState(remote.gemstone.GEMSTONE_ICON)
		itemId = stoneInfos[i].id
		if gemQuality <= APTITUDE.S then	--普通的a与s级魂骨
			self._stoneItem[i]:setItemIdByData(stoneInfos[i].id , 0 , 0)
			self._ccbOwner["tf_name_"..i]:setString(stoneInfos[i].name or "")
		elseif gemQuality == APTITUDE.SS then	--只化神的SS魂骨
			self._ccbOwner["tf_name_"..i]:setString(stoneInfos[i].name or "")
			self._stoneItem[i]:setItemId(stoneInfos[i].id )
		elseif gemQuality == APTITUDE.SSR then	-- SS+魂骨
			self._stoneItem[i]:setItemIdByData(stoneInfos[i].id , 0 , 1)
			local name = stoneInfos[i].name or ""
			self._ccbOwner["tf_name_"..i]:setString("SS+"..name)
		end
	end

	local itemConfig = db:getItemByID(itemId)
	if itemConfig then
		local descTbl = {}
		local descOtherTbl = {}
		if gemQuality <= APTITUDE.S then	--普通的a与s级魂骨
			local suitInfos = db:getGemstoneSuitEffectBySuitId(itemConfig.gemstone_set_index)
			for index,suitInfo in ipairs(suitInfos) do
				table.insert(descTbl , {desc = suitInfo.set_desc, number = suitInfo.set_number})
			end
		elseif gemQuality == APTITUDE.SS then	--只化神的SS魂骨
			local suitInfos = db:getGemstoneSuitEffectBySuitId(itemConfig.gemstone_set_index)
			for index,suitInfo in ipairs(suitInfos) do
				table.insert(descTbl , {desc = suitInfo.set_desc, number = suitInfo.set_number})
			end
		elseif gemQuality == APTITUDE.SSR then	-- SS+魂骨
			local mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(itemId, 1)
			if mixConfig and mixConfig.gem_suit then
				for i=1,3 do
					local suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, i + 1,1)
					if suitSkill then
						table.insert(descTbl ,{desc = suitSkill.set_desc, number = suitSkill.suit_num})
					else
						table.insert(descTbl , {})
					end
				end
			end
			-- local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(itemId, GEMSTONE_MAXADVANCED_LEVEL)
			-- if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
			-- 	local suitInfos = db:getGemstoneSuitEffectBySuitId(gemstoneInfo_ss.gem_evolution_new_set)
			-- 	for index,suitInfo in ipairs(suitInfos) do
			-- 		table.insert(descOtherTbl , suitInfo.set_desc )
			-- 	end
			-- end
		end


		index = 1
		local height = 0
		for i = 1, 4 do
			if descTbl[i] then
				local descText = descTbl[i].desc
				local number = descTbl[i].number or 0
				local descOtherText = descOtherTbl[i] 
				if descOtherText then
					descOtherText= ";"..descOtherText
				else
					descOtherText= ""
				end
				if descText then
					self._ccbOwner["tf_effect_"..index]:setString("【"..number.."件效果】"..descText..descOtherText)
					self._ccbOwner["tf_effect_"..index]:setPositionY(-47-height)
					height = height + self._ccbOwner["tf_effect_"..index]:getContentSize().height
					index = index + 1
				end
			end
		end
		for i = index, 4 do
			self._ccbOwner["tf_effect_"..i]:setVisible(false)
		end

		self._height = self._height + height
	
		-- if index < 5 then
		-- 	self._height = self._height - (5-index)*30
		-- end
	end
	self._ccbOwner.tf_suit_name:setString("套装属性")
	self._ccbOwner.tf_dec_content:setVisible(false)
end 

function QUIWidgetGemstoneBackPackDetail:getContentSize()
	return CCSize(100, self._height)
end

function QUIWidgetGemstoneBackPackDetail:_clickEvent(event)
	if event == nil then return end 
	app.sound:playSound("common_small")
	local itemCraft = db:getItemCraftByItemId(event.itemID)
	if itemCraft then
		QQuickWay:addQuickWay(QQuickWay.SYNTHETIC_DROP_WAY, event.itemID, nil, nil, false)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, event.itemID, nil, nil, false)
	end
end

return QUIWidgetGemstoneBackPackDetail